//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Алина on 22.03.2025.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(with model: AlertModel) {
        let alert = UIAlertController (title: model.title,
                                       message: model.message,
                                       preferredStyle: .alert)
        
        let actionOne = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(actionOne)
        
        if model.hasSecondButton {
            let actionTwo = UIAlertAction(title: model.secondButtonText, style: .cancel) { _ in
                model.secondButtonCompletion?()
            }
            alert.addAction(actionTwo)
        }
        
        viewController?.present(alert, animated: true, completion: nil)
        
#if DEBUG
        alert.view.accessibilityIdentifier = "AlertPresenter"
#endif
    }
}
