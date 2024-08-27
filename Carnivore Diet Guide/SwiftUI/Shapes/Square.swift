//
//  Square.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import Foundation
import SwiftUI

@frozen public struct Square : Shape {
    public func path(in rect: CGRect) -> Path {
        let size = min(rect.width, rect.height)
        
        let xOffset = (size == rect.width) ? 0 : (rect.width - size) / 2
        let yOffset = (size == rect.height) ? 0 : (rect.height - size) / 2
        
        let topLeftCorner = CGPoint(x: xOffset, y: yOffset)
        let topRightCorner = CGPoint(x: xOffset + size, y: yOffset)
        let bottomRightCorner = CGPoint(x: xOffset + size, y: yOffset + size)
        let bottomLeftCorner = CGPoint(x: xOffset, y: yOffset + size)

        var path = Path()
        path.move(to: topLeftCorner)
        path.addLine(to: topRightCorner)
        path.addLine(to: bottomRightCorner)
        path.addLine(to: bottomLeftCorner)
        path.addLine(to: topLeftCorner)
        return path
    }
    
}
