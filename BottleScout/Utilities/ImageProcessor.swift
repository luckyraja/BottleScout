import UIKit

struct ImageProcessor {
    /// Resize image to fit within max dimension while maintaining aspect ratio
    static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let maxDim = max(size.width, size.height)

        // If already smaller than max, return original
        guard maxDim > maxDimension else {
            return image
        }

        let scale = maxDimension / maxDim
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Compress image to JPEG with specified quality
    static func compress(_ image: UIImage, quality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }

    /// Resize and compress image for API submission
    static func prepareForAPI(_ image: UIImage) -> Data? {
        guard let resized = resize(image, maxDimension: Config.maxImageDimension) else {
            return nil
        }
        return compress(resized, quality: Config.apiImageQuality)
    }

    /// Compress image for local storage
    static func prepareForStorage(_ image: UIImage) -> Data? {
        return compress(image, quality: Config.storageImageQuality)
    }

    /// Convert image data to base64 string for API
    static func toBase64(_ imageData: Data) -> String {
        return imageData.base64EncodedString()
    }

    /// Convert UIImage to base64 string (convenience method)
    static func imageToBase64(_ image: UIImage, quality: CGFloat = Config.apiImageQuality) -> String? {
        guard let data = compress(image, quality: quality) else {
            return nil
        }
        return toBase64(data)
    }
}
