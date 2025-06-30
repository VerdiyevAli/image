//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алина on 22.02.2025.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue = newValue else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    static let storage = OAuth2TokenStorage()
    
    private let tokenKey = "oauthToken"
    
    func clearToken() {
        let removed = KeychainWrapper.standard.removeAllKeys()
        print("Удаление токена из Keychain: \(removed ? "успешно" : "не удалось")")
    }
    
    private init() { }
}
