//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Алина on 20.02.2025.
//
import Foundation

final class OAuth2Service {
    
    //MARK: - Static properties
    static let shared = OAuth2Service ()
    
    //MARK: - Private properties
    private let oAuth2TokenStorage = OAuth2TokenStorage.storage
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    //MARK: - Init
    private init(){ }
    
    //MARK: Private methods
    func makeOAuthTokenRequest(code: String) -> Result<URLRequest, OAuthTokenRequestError> {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("❌ Ошибка: Неверный базовый URL")
            return.failure(.invalidBaseURL)
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("❌ Ошибка: Неверный URL")
            return.failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return.success(request)
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let currentTask = task {
            if lastCode == code {
                completion(.failure(OAuthTokenRequestError.invalidRequest))
                return
            }
            currentTask.cancel()
        }
        
        lastCode = code
        
        switch makeOAuthTokenRequest(code: code) {
        case .success(let request):
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self.oAuth2TokenStorage.token = response.accessToken
                        completion(.success(response.accessToken))
                    case .failure(let error):
                        print("❌ Ошибка сети: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                    self.task = nil
                    self.lastCode = nil
                }
            }
            self.task = task
            task.resume()
            
        case.failure(let error):
            print("❌ Ошибка создания запроса fetchOAuthToken: \(error)")
            completion(.failure(error))
        }
    }
}

// MARK: - Extension
extension URLSession {
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    print("Успешный ответ от сервера, получено данных: \(data.count) байт")
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Ошибка: статус код \(statusCode), тело ответа: \(responseString)")
                    }
                    print("❌ Ошибка: статус код \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("❌ Ошибка URL запроса: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("❌ Ошибка: неизвестная ошибка URLSession")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(for request: URLRequest,completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("❌ Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
}
