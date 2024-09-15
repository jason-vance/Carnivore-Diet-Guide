//
//  RecipesView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/20/24.
//

import Combine
import SwiftUI
import SwinjectAutoregistration

struct RecipesView: View {
    
    @StateObject private var model = RecipesViewModel()
    
    @State private var showAds: Bool = false
    private var showAdsPublisher: AnyPublisher<Bool,Never> {
        (iocContainer~>SubscriptionLevelProvider.self)
            .subscriptionLevelPublisher
            .map { $0 == SubscriptionLevelProvider.SubscriptionLevel.none }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(String(localized: "Recipes"))
            if showAds { AdRow() }
            Spacer()
        }
        .background(Color.background)
        .onReceive(showAdsPublisher) { showAds = $0 }
    }
}

#Preview {
    PreviewContainerWithSetup {
        setupMockIocContainer(iocContainer)
    } content: {
        RecipesView()
    }
}
