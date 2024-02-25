//
//  FlowLayout.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/23/24.
//

import SwiftUI

struct FlowLayout<Item, ItemContent>: View where Item: Hashable, ItemContent: View {
    
    enum Mode {
        case scrollable, vstack
    }
    
    @State private var totalHeight: CGFloat
    @State private var mode: Mode
    @Binding private var items: [Item]
    private var viewMapping: (Item) -> ItemContent
    
    init(
        mode: Mode,
        items: Binding<[Item]>,
        viewMapping: @escaping (Item) -> ItemContent
    ) {
        _totalHeight = State(initialValue: (mode == .scrollable) ? .zero : .infinity)
        _mode = State(initialValue: mode)
        _items = items
        self.viewMapping = viewMapping
    }
    
    var body: some View {
        let stack = VStack {
            GeometryReader { geometry in
                self.content(in: geometry)
            }
        }
        return Group {
            if mode == .scrollable {
                stack.frame(height: totalHeight)
            } else {
                stack.frame(maxHeight: totalHeight)
            }
        }
    }
    
    @ViewBuilder func content(in geo: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                viewMapping(item)
                    .padding(4)
                    .alignmentGuide(.leading) { dimens in
                        if (abs(width - dimens.width) > geo.size.width) {
                            width = 0
                            height -= dimens.height
                        }
                        let result = width
                        if item == self.items.last {
                            width = 0
                        } else {
                            width -= dimens.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == self.items.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geo.frame(in: .local).size.height
            }
            return .clear
        }
    }
}

#Preview {
    let items = [
        "Some long item here",
        "And then some longer one",
        "Short", "Items", "Here", "And", "A", "Few", "More",
        "And then a very very very long one"
    ]
    
    return StatefulPreviewContainer(items) { items in
        VStack {
            HStack {
                Button("Add Item") {
                    items.wrappedValue.append("New Item \(items.count)")
                }.buttonStyle(.borderedProminent)
            }
            FlowLayout(
                mode: .scrollable,
                items: items
            ) { item in
                Button {
                    items.wrappedValue.removeAll { $0 == item }
                } label: {
                    Text(item)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .border(Color.gray)
                                .foregroundColor(Color.gray)
                        }
                }
            }
            .padding()
        }
    }
}
