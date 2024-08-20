//
//  KnowledgeBaseView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import SwiftUI

struct KnowledgeBaseView: View {
    
    @StateObject private var model = KnowledgeBaseViewModel()
    
    var body: some View {
        VStack {
            ScreenTitleBar(String(localized: "Knowledge Base"))
            Spacer()
        }
        .background(Color.background)
    }
}

#Preview {
    KnowledgeBaseView()
}
