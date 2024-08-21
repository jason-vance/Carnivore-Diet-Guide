//
//  Shimmer.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/21/24.
//

import SwiftUI

struct Shimmer: ViewModifier {
    
    private static let defaultAnimation = Animation
        .linear(duration: 1.5)
        .repeatForever(autoreverses: false)
    
    private let animation: Animation = defaultAnimation
    @State private var phase: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .mask { AnimatableMask(phase: phase) }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.1
                }
            }
    }
    
    private struct AnimatableMask: Animatable, View {
        
        var phase: CGFloat = -0.1
        
        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }
        
        var body: some View {
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0.3), location: phase - 0.1),
                    .init(color: Color.black, location: phase),
                    .init(color: Color.black.opacity(0.3), location: phase + 0.1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    @ViewBuilder func shimmering(isActive: Bool = true) -> some View {
        if isActive {
            modifier(Shimmer())
        } else {
            self
        }
    }
}

#Preview {
    StatefulPreviewContainer(true) { isActive in
        ZStack {
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .stroke(lineWidth: 1.0)
                .foregroundStyle(Color.indigo)
                .frame(width: 100, height: 100)
            Button("Tap to turn\non and off") {
                isActive.wrappedValue.toggle()
            }
        }
        .shimmering(isActive: isActive.wrappedValue)
    }
}
