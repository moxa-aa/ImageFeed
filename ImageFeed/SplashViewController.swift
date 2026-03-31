//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Moxa on 18/03/26.
//

import UIKit

final class SplashViewController: UIViewController {
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    private let logoImageView: UIImageView = {
        let image = UIImage(resource: .splashScreenLogo)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypBlack")
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController,
              let authViewController = navigationController.viewControllers.first as? AuthViewController else {
            assertionFailure("Failed to instantiate NavigationController or AuthViewController from Storyboard")
            return
        }
        
        authViewController.delegate = self
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oauth2TokenStorage.token else { return }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                break
            }
        }
    }
}
