//
//  KeywordItemView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import SwiftUI

struct KeywordItemButton: View {
    
    @State public var keyword: SearchKeyword
    @State public var accessoryImage: String
    public let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 0) {
                Text("\(keyword.text) (\(keyword.score))")
                    .padding(.horizontal, .paddingHorizontalButtonXSmall)
                    .padding(.vertical, .paddingVerticalButtonXSmall)
                Image(systemName: accessoryImage)
                    .padding(.horizontal, .paddingHorizontalButtonXSmall)
                    .padding(.vertical, .paddingVerticalButtonXSmall)
                    .opacity(0.5)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .frame(width: 0.25)
                            .opacity(0.25)
                    }
                    .background(Color.text.opacity(0.1))
            }
            .font(.footnote)
            .foregroundStyle(Color.text)
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                    .stroke(style: .init(lineWidth: .borderWidthMedium))
                    .foregroundStyle(Color.text)
            }
            .clipShape(.rect(cornerRadius: .cornerRadiusSmall, style: .continuous))
        }
    }
}

#Preview {
    KeywordItemButton(
        keyword: .samples.max { $0.text.count < $1.text.count }!,
        accessoryImage: "basket"
    ) {
        
    }
}
