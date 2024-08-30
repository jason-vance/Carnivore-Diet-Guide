//
//  ContentCreationImageData.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import Foundation
import UIKit

struct ContentCreationImageData: Identifiable {
    let id: String
    let image: UIImage
    let url: URL?
    
    init(image: UIImage) {
        self.id = UUID().uuidString
        self.image = image
        self.url = nil
    }
    
    init(id: String, image: UIImage, url: URL?) {
        self.id = id
        self.image = image
        self.url = url
    }
}
