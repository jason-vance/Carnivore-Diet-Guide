//
//  TextWall.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/21/25.
//

import SwiftUI
import MarkdownUI

struct TextWall: View {
    
    private let markdownContent: String
    
    init(_ markdownContent: String) {
        self.markdownContent = markdownContent
    }
    
    var body: some View {
        ScrollView {
            Markdown(markdownContent)
                .markdownTextStyle { ForegroundColor(Color.text) }
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(Color.background)
    }
}

#Preview {
    TextWall(TermsOfService.markdownContent)
}
