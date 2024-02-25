//
//  FontExtensions.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/22/24.
//

import SwiftUI

extension Font {
    static let titleRegular: Font = .system(size: .textSizeTitle)
    static let titleBold: Font = .system(size: .textSizeTitle, weight: .bold)
    
    static let headerRegular: Font = .system(size: .textSizeHeader)
    static let headerSemibold: Font = .system(size: .textSizeHeader, weight: .semibold)
    
    static let subHeaderRegular: Font = .system(size: .textSizeSubHeader)
    static let subHeaderBold: Font = .system(size: .textSizeSubHeader, weight: .bold)
    
    static let bodyText: Font = .system(size: .textSizeBody)
}
