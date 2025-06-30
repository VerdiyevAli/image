//
//  UserResult.swift
//  ImageFeed
//
//  Created by Алина on 27.03.2025.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
}
