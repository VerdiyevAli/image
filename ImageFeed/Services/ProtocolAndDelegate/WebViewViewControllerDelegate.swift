//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Алина on 16.02.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
