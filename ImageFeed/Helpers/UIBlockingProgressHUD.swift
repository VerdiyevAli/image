//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Алина on 02.03.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD: UIViewController {
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show(){
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss(){
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
