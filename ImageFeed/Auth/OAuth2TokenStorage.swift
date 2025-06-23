import Foundation

final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    static let storage = OAuth2TokenStorage()
    
    private let tokenKey = "oauthToken"
    
    private init() { }
}
