//
//  LimitedTimeOfferButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/18/25.
//

import SwiftUI
import SwinjectAutoregistration

struct LimitedTimeOfferButton: View {
    
    let subscriptionManager = iocContainer~>SubscriptionLevelProvider.self
    
    @State private var showMarketingView: Bool = false
    @State private var isLimitedTimeOfferValid: Bool = false
    @State private var animateTimer: Bool = false
    @State private var timeRemaining: String = "..."
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var limitedTimeOfferEndDate: Date? {
        // 86400 seconds = 24 hours
        return subscriptionManager.limitedTimeOfferStartDate?.addingTimeInterval(86400)
    }
    
    private func updateRemainingTime() {
        if let limitedTimeOfferEndDate {
            isLimitedTimeOfferValid = limitedTimeOfferEndDate > .now && subscriptionManager.subscriptionLevel == .none
        } else {
            isLimitedTimeOfferValid = false
        }
        
        guard let targetDate = limitedTimeOfferEndDate else {
            timeRemaining = "..."
            return
        }
        
        let now = Date()
        
        // Calculate the interval between now and the target date
        let remaining = targetDate.timeIntervalSince(now)
        
        if remaining > 0 {
            // We have time left, so format it
            timeRemaining = format(duration: remaining)
        } else {
            // Countdown has finished
            timeRemaining = "00:00:00"
            timer.upstream.connect().cancel() // Optional: Stop the timer
        }
    }
    
    private func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional // Gives "HH:MM:SS"
        formatter.zeroFormattingBehavior = .pad // Adds leading zeros, e.g., "01" vs "1"
        
        return formatter.string(from: duration) ?? "00:00:00"
    }

    var body: some View {
        VStack {
            if isLimitedTimeOfferValid {
                TheActualButton()
            } else {
                EmptyView()
            }
        }
        .onReceive(timer) { _ in updateRemainingTime() }
        .onAppear { updateRemainingTime() }
    }
    
    @ViewBuilder private func TheActualButton() -> some View {
        Button {
            showMarketingView = true
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("Limited Time Offer!")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.text)
                    Text("Lock in 75% off Carnivore+")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                Text(timeRemaining)
                    .font(.title.bold())
                    .fontWidth(.condensed)
                    .foregroundStyle(Color.accentColor)
                    .opacity(animateTimer ? 0.3 : 1.0)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.background)
                        .shadow(color: Color.black.opacity(0.6), radius: 4)
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(Color.accentColor, style: .init(lineWidth: 2))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            .padding(.top, 12)
            .animation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true),
                value: animateTimer
            )
            .onAppear { animateTimer = true }
        }
        .fullScreenCover(isPresented: $showMarketingView) {
            MarketingView()
        }
    }
}

#Preview {
    LimitedTimeOfferButton()
}
