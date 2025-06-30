//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алина on 28.03.2025.
//

import UIKit

final class ImagesListService: ImagesListServiceProtocol {
    //MARK: - Private variables
    private(set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private var isFetching = false
    private let oAuth2TokenStorage = OAuth2TokenStorage.storage
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    static let shared = ImagesListService()
    private init(){}
    
    //MARK: - Private methods
    func makePhotosNextPage(token: String) -> Result<URLRequest, OAuthTokenRequestError>{
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let baseURL = Constants.defaultBaseURL else {
            print("❌ Ошибка: baseURL отсутствует")
            return .failure(.invalidRequest)
        }
        
        let photosPath = baseURL.appendingPathComponent("photos")
        
        var urlComponents = URLComponents(url: photosPath, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
            
        ]
        
        guard let url = urlComponents?.url else {
            print("❌ Ошибка: Неверный URL PhotosNextPage")
            return .failure(.invalidRequest)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return .success(request)
    }
    
    func fetchPhotosNextPage(completion: ((Result<[Photo], Error>) -> Void)? = nil){
        assert(Thread.isMainThread)
        
        guard !isFetching else { return }
        isFetching = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = oAuth2TokenStorage.token else {
            print("❌ Ошибка: Токен отсутствует")
            isFetching = false
            return
        }
        
        task?.cancel()
        
        print("Запрос на загрузку следующей страницы с токеном \(token)")
        
        switch makePhotosNextPage(token: token){
        case .failure(let error):
            print("❌ Ошибка создания запроса makeProfileRequest: \(error)")
            isFetching = false
            completion?(.failure(error))
            
        case .success(let request):
            let task = urlSession.objectTask(for: request){ [weak self ] (result: Result<[PhotoResult], Error>) in
                guard let self = self else { return }
                self.isFetching = false
                
                switch result {
                case .success(let photoResult):
                    print("Загружено \(photoResult.count) фотографий")
                    
                    let newPhotos = Photo.makeArray(from: photoResult)
                    let uniquePhotos = newPhotos.filter { newPhoto in
                        !self.photos.contains { $0.id == newPhoto.id }
                    }
                    
                    DispatchQueue.main.async {
                        self.photos.append(contentsOf: uniquePhotos)
                        self.lastLoadedPage = nextPage
                        
                        
                        print("✅ Фотографии загружены, отправляем уведомление")
                        self.sentNotification()
                        completion?(.success(uniquePhotos))
                    }
                    
                case .failure(let error):
                    print("❌ Ошибка при загрузке фотографий: \(error)")
                    completion?(.failure(error))
                }
                
            }
            self.task = task
            task.resume()
        }
    }
    
    func makeChangeLikeRequest(photoId: String, token: String, isLiked: Bool) -> Result<URLRequest, OAuthTokenRequestError> {
        guard let url = URL(string: "photos/\(photoId)/like", relativeTo: Constants.defaultBaseURL) else {
            print("❌ Ошибка: Неверный URL makeChangeLikeRequest")
            return.failure(.invalidBaseURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return .success(request)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, NetworkError>) -> Void) {
        
        guard !isFetching else {
            print("Запрос уже выполняется")
            return
        }
        
        isFetching = true
        
        guard let token = oAuth2TokenStorage.token else {
            print("❌ Ошибка: Токен отсутствует")
            completion(.failure(.missingToken))
            isFetching = false
            return
        }
        
        switch makeChangeLikeRequest(photoId: photoId, token: token, isLiked: isLike){
            
        case .failure(let error):
            print("❌ Ошибка создания запроса makeChangeLikeRequest: \(error)")
            completion(.failure(.urlRequestError(error)))
            isFetching = false
            
        case .success(let request):
            let task = urlSession.objectTask(for: request){ [weak self ] (result: Result<LikeResult, Error>) in
                guard let self = self else { return }
                self.isFetching = false
                
                DispatchQueue.main.async {
                    print("JSON response: \(String(describing: result))")
                    switch result {
                    case .failure(let error):
                        print("❌ Ошибка сети makeProfileImageRequest: \(error.localizedDescription)")
                        completion(.failure(.urlRequestError(error)))
                        
                    case .success:
                        print("✅ Успешный ответ от API")
                        if let index = self.photos.firstIndex(where: {$0.id == photoId}){
                            let photo = self.photos[index]
                            
                            let newPhoto = Photo(id: photo.id,
                                                 size: photo.size,
                                                 createdAt: photo.createdAt,
                                                 welcomeDescription: photo.welcomeDescription,
                                                 thumbImageURL: photo.thumbImageURL,
                                                 largeImageURL: photo.largeImageURL,
                                                 isLiked: !photo.isLiked)
                            
                            self.photos[index] = newPhoto
                        }
                        completion(.success(()))
                    }
                }
            }
            task.resume()
        }
    }
    
    func sentNotification() {
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
    
    func cleanImageList(){
        photos.removeAll()
        lastLoadedPage = 0
    }
}
