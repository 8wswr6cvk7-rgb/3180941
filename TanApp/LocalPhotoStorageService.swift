import Foundation
import AVFoundation
import UIKit

protocol PhotoStorageService {
    func saveImage(_ image: UIImage, caption: String?) async throws -> PhotoAttachment
    func saveVideo(at sourceURL: URL, thumbnail: UIImage, caption: String?) async throws -> PhotoAttachment
    func deletePhoto(_ attachment: PhotoAttachment) async throws
    func loadImage(_ attachment: PhotoAttachment, thumbnail: Bool) async -> UIImage?
    func loadVideoURL(_ attachment: PhotoAttachment) async -> URL?
}

actor LocalPhotoStorageService: PhotoStorageService {
    private let rootURL: URL
    private let imagesURL: URL
    private let videosURL: URL
    private let thumbnailsURL: URL
    private let resourceBundle: Bundle

    init(rootURL: URL? = nil, resourceBundle: Bundle = .main) {
        let baseURL: URL
        if let rootURL {
            baseURL = rootURL
        } else {
            baseURL = (try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ))?.appendingPathComponent("TanUrbanEcho", isDirectory: true)
                ?? FileManager.default.temporaryDirectory.appendingPathComponent("TanUrbanEcho", isDirectory: true)
        }
        self.rootURL = baseURL
        self.resourceBundle = resourceBundle
        imagesURL = baseURL.appendingPathComponent("Images", isDirectory: true)
        videosURL = baseURL.appendingPathComponent("Videos", isDirectory: true)
        thumbnailsURL = baseURL.appendingPathComponent("Thumbnails", isDirectory: true)
    }

    func saveImage(_ image: UIImage, caption: String?) async throws -> PhotoAttachment {
        try makeDirectoriesIfNeeded()

        let id = UUID()
        let mainFilename = "\(id.uuidString).jpg"
        let thumbnailFilename = "\(id.uuidString)_thumb.jpg"
        guard
            let mainData = Self.jpegData(for: image, maxPixel: 2_048, quality: 0.86),
            let thumbnailData = Self.jpegData(for: image, maxPixel: 480, quality: 0.76)
        else {
            throw LocalPhotoStorageError.encodingFailed
        }

        try mainData.write(to: imagesURL.appendingPathComponent(mainFilename), options: .atomic)
        do {
            try thumbnailData.write(to: thumbnailsURL.appendingPathComponent(thumbnailFilename), options: .atomic)
        } catch {
            try? FileManager.default.removeItem(at: imagesURL.appendingPathComponent(mainFilename))
            throw error
        }

        return PhotoAttachment(
            id: id,
            localFilename: mainFilename,
            thumbnailFilename: thumbnailFilename,
            caption: caption
        )
    }

    func saveVideo(at sourceURL: URL, thumbnail: UIImage, caption: String?) async throws -> PhotoAttachment {
        try makeDirectoriesIfNeeded()

        let id = UUID()
        let sourceExtension = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension.lowercased()
        let videoFilename = "\(id.uuidString).\(sourceExtension)"
        let thumbnailFilename = "\(id.uuidString)_thumb.jpg"
        let destinationURL = videosURL.appendingPathComponent(videoFilename)

        guard let thumbnailData = Self.jpegData(for: thumbnail, maxPixel: 720, quality: 0.8) else {
            throw LocalPhotoStorageError.encodingFailed
        }

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            try thumbnailData.write(
                to: thumbnailsURL.appendingPathComponent(thumbnailFilename),
                options: .atomic
            )
        } catch {
            try? FileManager.default.removeItem(at: destinationURL)
            try? FileManager.default.removeItem(at: thumbnailsURL.appendingPathComponent(thumbnailFilename))
            throw error
        }

        let duration = try? await AVURLAsset(url: destinationURL).load(.duration)
        let seconds = duration.map(CMTimeGetSeconds) ?? .nan
        return PhotoAttachment(
            id: id,
            localFilename: videoFilename,
            thumbnailFilename: thumbnailFilename,
            caption: caption,
            mediaType: .video,
            videoDuration: seconds.isFinite ? seconds : nil
        )
    }

    func deletePhoto(_ attachment: PhotoAttachment) async throws {
        let manager = FileManager.default
        let storedFiles = [
            (
                attachment.localFilename,
                attachment.resolvedMediaType == .video ? videosURL : imagesURL
            ),
            (attachment.thumbnailFilename, thumbnailsURL)
        ]
        for (filename, directory) in storedFiles where !filename.isEmpty {
            let url = directory.appendingPathComponent(filename)
            guard manager.fileExists(atPath: url.path) else { continue }
            try manager.removeItem(at: url)
        }
    }

    func loadImage(_ attachment: PhotoAttachment, thumbnail: Bool) async -> UIImage? {
        let shouldUseThumbnail = thumbnail || attachment.resolvedMediaType == .video
        let filename = shouldUseThumbnail ? attachment.thumbnailFilename : attachment.localFilename
        let directory = shouldUseThumbnail ? thumbnailsURL : imagesURL
        if !filename.isEmpty,
           let localImage = UIImage(contentsOfFile: directory.appendingPathComponent(filename).path) {
            return localImage
        }

        guard let resourceName = attachment.bundledResourceName else { return nil }
        let resourceURL = resourceBundle.url(
            forResource: resourceName,
            withExtension: nil,
            subdirectory: "SeedPhotos"
        ) ?? resourceBundle.url(forResource: resourceName, withExtension: nil)
        guard let resourceURL else { return nil }
        return UIImage(contentsOfFile: resourceURL.path)
    }

    func loadVideoURL(_ attachment: PhotoAttachment) async -> URL? {
        guard attachment.resolvedMediaType == .video else { return nil }
        if !attachment.localFilename.isEmpty {
            let localURL = videosURL.appendingPathComponent(attachment.localFilename)
            if FileManager.default.fileExists(atPath: localURL.path) {
                return localURL
            }
        }

        guard let resourceName = attachment.bundledResourceName else { return attachment.remoteURL }
        return resourceBundle.url(
            forResource: resourceName,
            withExtension: nil,
            subdirectory: "SeedPhotos"
        ) ?? resourceBundle.url(forResource: resourceName, withExtension: nil)
    }

    private func makeDirectoriesIfNeeded() throws {
        let manager = FileManager.default
        try manager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try manager.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        try manager.createDirectory(at: videosURL, withIntermediateDirectories: true)
        try manager.createDirectory(at: thumbnailsURL, withIntermediateDirectories: true)
    }

    private static func jpegData(for image: UIImage, maxPixel: CGFloat, quality: CGFloat) -> Data? {
        let normalizedSize = image.size
        guard normalizedSize.width > 0, normalizedSize.height > 0 else { return nil }
        let longestSide = max(normalizedSize.width, normalizedSize.height)
        let scale = min(1, maxPixel / longestSide)
        let targetSize = CGSize(
            width: max(1, (normalizedSize.width * scale).rounded()),
            height: max(1, (normalizedSize.height * scale).rounded())
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let normalized = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return normalized.jpegData(compressionQuality: quality)
    }
}

enum LocalPhotoStorageError: Error {
    case encodingFailed
}
