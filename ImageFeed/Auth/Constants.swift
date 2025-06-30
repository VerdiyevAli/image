//
//  Constants.swift
//  ImageFeed
//
//  Created by Алина on 15.02.2025.
//
import Foundation

enum Constants {
    static let accessKey: String = "wjMXyfVMnJpxxoQ6rnlRrohVvYFJZAe0k02KdwRh7iQ"
    static let secretKey: String = "pFcDZ-E1oi2FRYEqzq_73Z684QHIDEvhWtcvQYPJ6So"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let defaultBaseURL: URL? = URL(string: "https://api.unsplash.com/")
}
