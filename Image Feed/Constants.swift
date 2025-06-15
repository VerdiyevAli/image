import Foundation

/// Константы приложения
enum Constants {
    /// API константы для работы с Unsplash
    enum API {
        static let defaultBaseURL: URL = {
            guard let url = URL(string: "https://api.unsplash.com") else {
                fatalError("Failed to create base URL")
            }
            return url
        }()
        
        static let accessKey = "S-5kWb2JOLUERhUrddgO58BjdEnONLIyd4AdprXnc5U"
        static let secretKey = "PARV2GUTX3j9pZAuNqFJqxmIWsf0ezMF9lyRAhqGyrI"
        static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
        static let accessScope = "public+read_user+write_likes"
    }
}
