//
//  PreviewContainerWithSetup.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import SwiftUI

struct PreviewContainerWithSetup<Content: View>: View {
    
    var content: () -> Content
    
    var body: some View {
        content()
    }
    
    init(
        setup: @escaping () -> Void,
        content: @escaping () -> Content) {
            
        setup()
        self.content = content
    }
}
