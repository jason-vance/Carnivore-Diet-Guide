//
//  UIImageExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation
import UIKit

extension UIImage {
    func resizeToMinSideWithMaxLength(of maxLength: CGFloat) -> UIImage? {
        // Determine the scale factor that keeps the aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            // Landscape orientation
            guard size.height > maxLength else { return self }
            newSize = CGSize(width: maxLength * aspectRatio, height: maxLength)
        } else {
            // Portrait orientation
            guard size.width > maxLength else { return self }
            newSize = CGSize(width: maxLength, height: maxLength / aspectRatio)
        }

        // Create a new rectangle with the new size
        let rect = CGRect(origin: .zero, size: newSize)

        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        
        // Get the resized image from the context
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
    
    func scaledToFill(aspectRatio: CGFloat) -> UIImage? {
        let originalSize = size
        let originalAspectRatio = originalSize.width / originalSize.height
        
        var cropRect: CGRect
        
        if originalAspectRatio > aspectRatio {
            // Image is wider than the target aspect ratio, crop the width
            let newWidth = originalSize.height * aspectRatio
            let xOffset = (originalSize.width - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: originalSize.height)
        } else {
            // Image is taller than the target aspect ratio, crop the height
            let newHeight = originalSize.width / aspectRatio
            let yOffset = (originalSize.height - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: originalSize.width, height: newHeight)
        }
        
        // Crop the image using the calculated crop rect
        if let cgImage = cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        
        return nil
    }
}
