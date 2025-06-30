//
//  Photo.swift
//  ImageFeed
//
//  Created by Алина on 28.03.2025.
//

import Foundation

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: URL
    let largeImageURL: URL
    var isLiked: Bool
}

extension Photo {
    static func makeArray(from photoResults: [PhotoResult]) -> [Photo] {
        return photoResults.map { result in
            Photo(
                id: result.id,
                size: CGSize(width: result.width, height: result.height),
                createdAt: result.createdAt,
                welcomeDescription: result.description,
                thumbImageURL: result.urls.thumb,
                largeImageURL: result.urls.full,
                isLiked: result.likedByUser
            )
        }
    }
}
