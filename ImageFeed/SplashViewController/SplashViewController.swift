import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private lazy properties
    private lazy var splashImage: UIImageView = {
        let splashImage = UIImageView(image:UIImage(named: "Vector"))
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        return splashImage
    }()
    
    //MARK: - Private properties
    private let idAuthViewController = "showAuthVCID"
    private let idTabBarControllerScene = "TabBarViewController"
    
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
            splashImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 228),
            splashImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func validateAuthorization(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if OAuth2TokenStorage.storage.token != nil {
            print("Токен прошел авторизацию")
            switchToTabBarController()
        } else {
            print("Токен отсутствует, переход на AuthViewController")
            if let authViewController = storyboard.instantiateViewController(withIdentifier: idAuthViewController) as? AuthViewController {
                print("Переход на AuthViewController")
                authViewController.delegate = self
                navigationController?.pushViewController(authViewController, animated: true)
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: idTabBarControllerScene)
        
        window.rootViewController = tabBarController
    }
}

//MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        switchToTabBarController()
    }
}
