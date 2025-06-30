//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Алина on 05.04.2025.
//
import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
