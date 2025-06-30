//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Алина on 16.02.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    //MARK: - Delegate
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private lazy properties
    private lazy var logoOfUnsplashImageView: UIImageView = {
        let logoOfUnsplashImageView = UIImageView(image: UIImage(named: "auth_screen_logo"))
        logoOfUnsplashImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoOfUnsplashImageView
    }()
    
    private lazy var activeButton: UIButton = {
        let activeButton = UIButton(type: .system)
        activeButton.backgroundColor = .ypWhite
        activeButton.layer.cornerRadius = 16
        activeButton.layer.masksToBounds = true
        
        activeButton.setTitle("Войти", for: .normal)
        activeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        activeButton.setTitleColor(.ypLightBlack, for: .normal)
        activeButton.titleLabel?.textAlignment = .center
        
        activeButton.addTarget(self, action: #selector(didTapActiveButton), for: .touchUpInside)
        
        activeButton.translatesAutoresizingMaskIntoConstraints = false
        return activeButton
    }()
    
    //MARK: - Private properties
    private let oauth2Service = OAuth2Service.shared
    private lazy var errorAlert = AlertPresenter(viewController: self)
    
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypLightBlack
        setupUI()
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Private methods
    private func setupUI(){
        configureConstraintsLogoOfUnsplashImageView()
        configureActiveButton()
        configureBackButton()
    }
    
    private func configureConstraintsLogoOfUnsplashImageView(){
        view.addSubview(logoOfUnsplashImageView)
        
        NSLayoutConstraint.activate([
            logoOfUnsplashImageView.heightAnchor.constraint(equalToConstant: 60),
            logoOfUnsplashImageView.widthAnchor.constraint(equalToConstant: 60),
            logoOfUnsplashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoOfUnsplashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureActiveButton(){
        view.addSubview(activeButton)
        
        NSLayoutConstraint.activate([
            activeButton.heightAnchor.constraint(equalToConstant: 48),
            activeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            activeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            activeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "#1A1B22")
    }
    
    //MARK: - Action
    @objc private func didTapActiveButton(){
        let webViewVC = WebViewViewController()
        webViewVC.delegate = self
        
        let navigationController = UINavigationController(rootViewController: webViewVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

//MARK: - Extension
extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true, completion: nil)
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage.storage.token = token
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("❌ Ошибка получения токена: \(error)")
                let alertModel = AlertModel(title: "Что-то пошло не так(",
                                            message: "Не удалось войти в систему",
                                            buttonText: "OK",
                                            completion: nil,
                                            secondButtonText: nil,
                                            secondButtonCompletion: nil)
                errorAlert.showAlert(with: alertModel)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
