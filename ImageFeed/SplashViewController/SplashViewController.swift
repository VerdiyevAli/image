import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private lazy properties
    private lazy var splashImage: UIImageView = {
        let splashImage = UIImageView(image:UIImage(named: "Vector"))
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        return splashImage
    }()
    
    //MARK: - Private properties
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.storage
    private lazy var showErrorAlert = AlertPresenter(viewController: self)
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypLightBlack
        configureConstraintsSplashImage()
    }
    
    // MARK: - Override methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.validateAuthorization()
        }
    }
    
    //MARK: - Private methods
    private func configureConstraintsSplashImage(){
        view.addSubview(splashImage)
        
        NSLayoutConstraint.activate([
            splashImage.widthAnchor.constraint(equalToConstant: 72),
            splashImage.heightAnchor.constraint(equalToConstant: 75),
            splashImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func validateAuthorization(){
        if let token = storage.token {
            print("Токен найден, загружаем профиль")
            fetchProfile(token: token)
        } else {
            print("Токен отсутствует, переход на AuthViewController")
            let authViewController = AuthViewController()
            authViewController.delegate = self
            navigationController?.pushViewController(authViewController, animated: true)
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        print("Переход на \(TabBarController.identifier)")
        
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("Профиль успешно загружен: \(profile.userName)")
                // Запускаем загрузку аватара
                ProfileImageService.shared.fetchProfileImageURL(username: profile.userName) { result in
                    switch result {
                    case .success(let avatarURL):
                        print("Аватар успешно загружен: \(avatarURL)")
                    case .failure(let error):
                        print("Ошибка загрузки аватара: \(error)")
                    }
                }
                self.switchToTabBarController()
            case .failure(let error):
                print("Ошибка при загрузке профиля: \(error)")
                // Если ошибка связана с токеном, очищаем его и переходим на авторизацию
                if case .httpStatusCode(let statusCode) = error, statusCode == 401 {
                    print("Токен недействителен, очищаем и переходим на авторизацию")
                    self.storage.token = nil
                    self.validateAuthorization()
                } else {
                    let alertModel = AlertModel(title: "Что-то пошло не так(",
                                                message: "Не удалось войти в систему",
                                                buttonText: "OK",
                                                completion: nil)
                    self.showErrorAlert.showAlert(with: alertModel)
                }
            }
        }
    }
}

//MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else {
            return
        }
        fetchProfile(token: token)
    }
}
