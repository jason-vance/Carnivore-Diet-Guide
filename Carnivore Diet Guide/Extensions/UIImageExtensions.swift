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
}
