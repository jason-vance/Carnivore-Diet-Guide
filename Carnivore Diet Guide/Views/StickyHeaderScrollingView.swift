//
//  StickyHeaderScrollingView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/6/24.
//

import SwiftUI
import Kingfisher

struct StickyHeaderScrollingView<HeaderContent: View, HeaderBackground: View, ScrollableContent: View>: View {
    
    @ViewBuilder var headerContent: (CGFloat) -> HeaderContent
    @ViewBuilder var headerBackground: () -> HeaderBackground
    @ViewBuilder var scrollableContent: () -> ScrollableContent
        
    @State var scrollOffset: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geoProxy in
            OffsetObservingScrollView(offset: $scrollOffset) {
                VStack(spacing: 0) {
                    HeaderView(size: geoProxy.size, safeArea: geoProxy.safeAreaInsets)
                        .zIndex(1000)
                    scrollableContent()
                }
            }
        }
    }
    
    @ViewBuilder func HeaderView(size: CGSize, safeArea: EdgeInsets) -> some View {
        let maxHeaderHeight = size.height * 0.3 + safeArea.top
        let headerHeight = max(64, maxHeaderHeight - scrollOffset.y)
        let progress = (headerHeight - 64) / (maxHeaderHeight - 64)
        
        GeometryReader { _ in
            ZStack(alignment: .bottom) {
                headerBackground()
                    .frame(width: size.width, height: headerHeight + safeArea.top)
                    .clipped()
                    .offset(y: -safeArea.top/2)
                headerContent(progress)
                    .offset(y: -safeArea.top/2)
            }
            .frame(height: headerHeight)
            .offset(y: scrollOffset.y)
        }
        .frame(height: maxHeaderHeight)
    }
}

#Preview {
    StickyHeaderScrollingView { progress in
        Text("Title")
            .font(.system(size: 32 + (32 * progress), weight: .bold))
            .foregroundStyle(.white)
            .padding()
    } headerBackground: {
        KFImage(URL(string:"https://static1.cbrimages.com/wordpress/wp-content/uploads/2023/06/final-fantasy-xvi-clive-profile.jpg"))
            .resizable()
            .scaledToFill()
    } scrollableContent: {
        VStack {
            ForEach(1...25, id: \.self) { asdf in
                Text("\(asdf)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(.gray))
            }
        }
        .padding()
    }
}
