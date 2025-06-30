//
//  OAuthTokenRequestError.swift
//  ImageFeed
//
//  Created by Алина on 22.03.2025.
//

//MARK: - Enums
enum OAuthTokenRequestError: Error {
    case invalidBaseURL
    case invalidURL
    case invalidRequest
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidResponseData
    case missingToken
    case requestFailed
}

enum ImagesListServiceError: Error {
    case missingToken
    case urlRequestError(Error)
}
