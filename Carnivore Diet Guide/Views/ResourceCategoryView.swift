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
    private var highlightNamespace: Namespace.ID?

    init(_ category: Resource.Category) {
        self.category = category
        self.isHighlighted = false
    }

    /// With a namespace shared by a row of chips, the highlight glides from the old chip to the new one.
    func highlighted(_ isHighlighted: Bool = true, glidingIn namespace: Namespace.ID? = nil) -> ResourceCategoryView {
        var view = self
        view.isHighlighted = isHighlighted
        view.highlightNamespace = namespace
        return view
    }

    var body: some View {
        HStack(spacing: 4) {
            if let image = category.image {
                Image(systemName: image)
                    .frame(height: 16)
            }
            Text(category.name)
        }
        .font(.caption.bold())
        .foregroundStyle(isHighlighted ? Color.background : Color.accent)
        .padding(.horizontal, .paddingHorizontalButtonMedium)
        .padding(.vertical, .paddingVerticalButtonMedium)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(Color.accent.opacity(0.1))
                if isHighlighted {
                    Highlight()
                }
            }
        }
    }

    @ViewBuilder private func Highlight() -> some View {
        let shape = RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
            .foregroundStyle(Color.accent)
        if let highlightNamespace {
            shape.matchedGeometryEffect(id: "categoryHighlight", in: highlightNamespace)
        } else {
            shape
        }
    }
}

#Preview {
    VStack {
        ResourceCategoryView(.samples.first!)
        ResourceCategoryView(.samples.dropFirst().first!)
            .highlighted()

    }
}
