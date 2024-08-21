//
//  CreatePostImageData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation
import UIKit

struct CreatePostImageData: Identifiable {
    let id: UUID
    let image: UIImage
    let url: URL?
    
    init(image: UIImage) {
        self.id = UUID()
        self.image = image
        self.url = nil
    }
    
    init(id: UUID, image: UIImage, url: URL?) {
        self.id = id
        self.image = image
        self.url = url
    }
}
