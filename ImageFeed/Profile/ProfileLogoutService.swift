//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Алина on 05.04.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    private let oAuth2TokenStorage = OAuth2TokenStorage.storage
    private let imagesListService = ImagesListService.shared
    
    static let shared = ProfileLogoutService()
    private init(){}
    
    func logout(){
        oAuth2TokenStorage.clearToken()
        imagesListService.cleanImageList()
        cleanCookies()
    }
    
    private func cleanCookies(){
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler:{})
            }
        }
    }
}
