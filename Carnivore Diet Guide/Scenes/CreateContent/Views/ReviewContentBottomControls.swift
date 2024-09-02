//
//  ReviewContentBottomControls.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/1/24.
//

import SwiftUI

struct ReviewContentBottomControls: View {
    
    @State var editAction: () -> ()
    @State var approvedAction: () -> ()
    
    var body: some View {
        HStack {
            BackButton()
            LooksGoodButton()
        }
        .padding()
        .frame(height: .barHeight)
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            editAction()
        } label: {
            HStack {
                Image(systemName: "chevron.backward")
                Text("Edit")
            }
            .foregroundStyle(Color.accent)
            .bold()
            .padding(.vertical, .paddingVerticalButtonMedium)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(style: .init(lineWidth: .borderWidthMedium))
                    .foregroundStyle(Color.accent)
            }
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(Color.background)
            }
        }
    }
    
    @ViewBuilder func LooksGoodButton() -> some View {
        Button {
            approvedAction()
        } label: {
            HStack {
                Image(systemName: "hand.thumbsup")
                Text("Looks Good")
            }
            .foregroundStyle(Color.background)
            .bold()
            .padding(.vertical, .paddingVerticalButtonMedium)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .foregroundStyle(Color.accent)
            }
        }
    }
}

#Preview {
    ReviewContentBottomControls(
        editAction: {},
        approvedAction: {}
    )
}
