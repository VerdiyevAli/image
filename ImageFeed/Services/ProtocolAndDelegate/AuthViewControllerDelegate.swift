//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Алина on 27.03.2025.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
