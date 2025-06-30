//
//  ViewController.swift
//  ImageFeed
//
//  Created by Алина on 26.01.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    //MARK: - Private variables
    private let currentDate = Date()
    private let imagesListService: ImagesListServiceProtocol = ImagesListService.shared
    private var imageListServiceObserver: Any?
    private lazy var errorAlert = AlertPresenter(viewController: self)
    
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private lazy var serverDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.isOpaque = true
        tableView.clearsContextBeforeDrawing = true
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.isEditing = false
        tableView.allowsSelection = true
        tableView.backgroundColor = .ypLightBlack
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.contentMode = .scaleToFill
        view.backgroundColor = .ypLightBlack
        setupTableView()
        
        imageListObserver()
        imagesListService.fetchPhotosNextPage { result in
            switch result {
            case .success:
                self.updateTableViewAnimated()
            case .failure(let error):
                print("❌ Ошибка при загрузке фотографий: \(error)")
            }
        }
    }
    
    // MARK: - Override methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private methods
    private func setupTableView(){
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func updateCellHeight(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        let newPhotos = imagesListService.photos.suffix(newCount - oldCount)
        photos.append(contentsOf: newPhotos)
        
        DispatchQueue.main.async {
            if oldCount != newCount {
                self.tableView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                } completion: { _ in }
            }
        }
    }
    
    private func imageListObserver(){
        imageListServiceObserver = NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main){ [weak self] _ in
            guard let self = self else{ return }
            self.updateTableViewAnimated()
        }
    }
    
    // MARK: - deinit
    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

//MARK: - Extension
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row < imagesListService.photos.count else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        let thumbImageURL = photo.thumbImageURL
        
        cell.setImage(from: thumbImageURL)
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage { result in
                switch result {
                case .success(_):
                    self.updateTableViewAnimated()
                case .failure(let error):
                    print("❌ Ошибка при загрузке следующих фотографий: \(error)")
                }
            }
        }
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else {
            print("❌ Ошибка: indexPath.row (\(indexPath.row)) выходит за границы массива photos.count (\(photos.count))")
            return
        }
        
        let photo = photos[indexPath.row]
        
        let url = photo.thumbImageURL
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        
        if let dateString = photo.createdAt, let date = serverDateFormatter.date(from: dateString) {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.isHidden = true
        }
        
        cell.cellImage.backgroundColor = .ypDarkGray
        cell.setImage(from: url)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateCellHeight(at: indexPath)
        
        let image = photos[indexPath.row]
        
        let singleImageVC = SingleImageViewController()
        singleImageVC.image = image
        singleImageVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(singleImageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else {
            return 0
        }
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        assert(Thread.isMainThread)
        
        print("Нажата кнопка лайк в ячейке \(cell)")
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        let newIsLiked = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                let alertModel = AlertModel(title: "Ошибка",
                                            message: "Не удалось изменить лайк.",
                                            buttonText: "OK",
                                            completion: nil,
                                            secondButtonText: nil,
                                            secondButtonCompletion: nil)
                errorAlert.showAlert(with: alertModel)
                print("❌ Ошибка при изменении лайка: \(error.localizedDescription)")
            }
        }
    }
}
