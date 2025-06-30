//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алина on 01.02.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage(named: "Photo")
        let avatarImageView = UIImageView(image: avatarImage)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        return avatarImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .ypWhite
        return nameLabel
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textAlignment = .left
        loginNameLabel.textColor = .ypLightGray
        return loginNameLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .ypWhite
        return descriptionLabel
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton(type: .custom)
        if let exitImage = UIImage(named: "Exit"){
            logoutButton.setImage(exitImage, for: .normal)
        }
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.tintColor = .ypCoral
        return logoutButton
    }()
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private lazy var errorAlert = AlertPresenter(viewController: self)
    
    //MARK: - Deinit
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileDetails()
        addProfileImageObserver()
        updateAvatar()
    }
    
    //MARK: - Override methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    // MARK: - Private methods
    private func setupUI(){
        configureConstraintsAvatarImageView()
        configureConstraintsNameLabel()
        configureConstraintsLoginNameLabel()
        configureConstraintsDescriptionLabel()
        configureConstraintsLogoutButton()
    }
    
    private func configureConstraintsAvatarImageView(){
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureConstraintsNameLabel(){
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureConstraintsLoginNameLabel(){
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureConstraintsDescriptionLabel(){
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureConstraintsLogoutButton(){
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func updateProfileDetails() {
        if let profile = profileService.profile {
            print("Profile loaded: \(profile.name), \(profile.loginName), \(String(describing: profile.bio))")
            nameLabel.text = profile.name
            loginNameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
            updateAvatar()
        } else {
            print("Профиль не загружен")
        }
    }
    
    private func updateAvatar(){
        guard let profileImageURL = ProfileImageService.shared.avatarURL, let updateUrl = URL(string: profileImageURL) else {
            print("❌ Ошибка: avatarURL отсутствует или невалидный")
            return
        }
        print("Обновляем аватар: \(updateUrl.absoluteString)")
        avatarImageView.kf.setImage(with: updateUrl, placeholder: UIImage(named: "PlaceholderAvatar"))
    }
    
    private func addProfileImageObserver(){
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    private func resetToDefaultProfileData() {
        let cleanURL: URL? = nil
        self.avatarImageView.kf.setImage(with: cleanURL, placeholder: UIImage(named: "PlaceholderAvatar"))
        
        DispatchQueue.main.async {
            let defaultImage = UIImage(named: "Photo")
            let defaultName = "Екатерина Новикова"
            let defaultLoginName = "@ekaterina_nov"
            let defaultDescription = "Hello, world!"
            
            self.avatarImageView.image = defaultImage
            self.nameLabel.text = defaultName
            self.loginNameLabel.text = defaultLoginName
            self.descriptionLabel.text = defaultDescription
        }
    }
    
    //MARK: - Action
    @objc private func didTapLogoutButton() {
        print("Logout button tapped")
        let alertmodel = AlertModel(title: "Пока, пока!",
                                    message: "Уверены что хотите выйти?",
                                    buttonText: "Нет",
                                    completion: nil,
                                    secondButtonText: "Да",
                                    secondButtonCompletion: {
            self.resetToDefaultProfileData()
            ProfileLogoutService.shared.logout()

            let splashViewController = SplashViewController()
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = splashViewController
                window.makeKeyAndVisible()
            }
        })
        errorAlert.showAlert(with: alertmodel)
    }
}
