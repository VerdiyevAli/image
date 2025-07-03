import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
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
    
    private init() { }
}
