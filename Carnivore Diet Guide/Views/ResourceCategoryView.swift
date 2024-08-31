//
//  ResourceCategoryView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import SwiftUI

struct ResourceCategoryView: View {
    
    @State public var category: Resource.Category
    private var isHighlighted: Bool
    
    init(_ category: Resource.Category) {
        self.category = category
        self.isHighlighted = false
    }
    
    func highlighted(_ isHighlighted: Bool = true) -> ResourceCategoryView {
        var view = self
        view.isHighlighted = isHighlighted
        return view
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let image = category.image {
                Image(systemName: image)
            }
            Text(category.name)
        }
        .font(.caption.bold())
        .foregroundStyle(isHighlighted ? Color.background : Color.accent)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(isHighlighted ? Color.accent : Color.accent.opacity(0.1))
        }
    }
}

#Preview {
    VStack {
        ResourceCategoryView(.samples[0])
        ResourceCategoryView(.samples[1])
            .highlighted()
        ResourceCategoryView(.samples[2])

    }
}
