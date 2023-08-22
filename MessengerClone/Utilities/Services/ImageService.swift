//
//  ImageManager.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/20/23.
//

import PhotosUI
import UIKit

protocol ImageServiceProtocol {
    var imageCachingManager: PHCachingImageManager { get set }
    func downsample(imageAt imageURL: URL?, to pointSize: CGSize, scale: CGFloat) -> UIImage?
    func downSample(data: Data?, pointSize: CGSize, scale: CGFloat) -> UIImage?
    func getImageUrlFrom(asset: PHAsset) async throws -> URL
    func getThumbnailImage(asset: PHAsset) async throws -> UIImage?
    func getHighQulityImage(asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode) async throws -> UIImage?
}

final class ImageService: ImageServiceProtocol {
    // singleton
    static let shared = ImageService()

    // manager that will fetch and cache photos
    var imageCachingManager = PHCachingImageManager()
}

// MARK: - downSampleImage
extension ImageService {
    func downsample(
        imageAt imageURL: URL?,
        to pointSize: CGSize,
        scale: CGFloat = UIScreen.main.scale
    )
    -> UIImage? {
        guard let imageURL else { return nil }

        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
        }

        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
    }

    func downSample(data: Data?, pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard let data else { return nil }
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else { return nil }
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
        [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage)
    }
}

// MARK: - getImageUrlFrom
extension ImageService {
    func getImageUrlFrom(asset: PHAsset) async throws -> URL {
        return try await withCheckedThrowingContinuation({ continuation in
            asset.requestContentEditingInput(with: nil, completionHandler: { input, _ in
                if let url = input?.fullSizeImageURL {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: MessengerError.someThingWentWrong)
                }
            })
        })
    }
}

// MARK: - getImages
extension ImageService {
    func getThumbnailImage(asset: PHAsset) async throws -> UIImage? {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            // Use the imageCachingManager to fetch the image
            self?.imageCachingManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 100, height: 100),
                contentMode: .aspectFit,
                options: nil,
                resultHandler: { image, info in
                    // image is of type UIImage
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }

    // highQuality
    func getHighQulityImage(
        asset: PHAsset,
        targetSize: CGSize = PHImageManagerMaximumSize,
        contentMode: PHImageContentMode = .default
    )
    async throws -> UIImage? {
        //        let options = PHImageRequestOptions()
        //        options.deliveryMode = .highQualityFormat
        //        options.resizeMode = .exact
        //        options.isNetworkAccessAllowed = true
        //        options.isSynchronous = true
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            // Use the imageCachingManager to fetch the image

            self?.imageCachingManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: nil,
                resultHandler: { image, info in
                    // image is of type UIImage
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: image)
                }
            )
        }
    }
}
