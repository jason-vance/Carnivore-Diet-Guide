//
//  ProgramMilestoneView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/17/26.
//

import SwiftUI

/// The celebration after checking in on the last day of a week, or day 30: the day number stamps down, and the
/// user's counts roll up.
struct ProgramMilestoneView: View {

    let milestone: ProgramMilestone
    let onDone: () -> Void

    var body: some View {
        CelebrationView(
            title: milestone.title,
            message: milestone.message,
            buttonTitle: milestone.isFinish ? String(localized: "See Your 30 Days") : String(localized: "Keep Going"),
            badgeLabel: String(localized: "\(milestone.day) days"),
            badge: {
                VStack(spacing: -6) {
                    Text("\(milestone.day)")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                    Text("Days")
                        .font(.subheadline.weight(.bold))
                        .textCase(.uppercase)
                }
            },
            details: { isShown in
                Stats(isShown: isShown)
            },
            onDone: onDone
        )
    }

    @ViewBuilder private func Stats(isShown: Bool) -> some View {
        HStack(spacing: 0) {
            Stat(value: milestone.checkInCount, label: String(localized: "Check-ins"), isShown: isShown)
            Divider()
                .frame(height: 36)
            Stat(value: milestone.tasksDone, label: String(localized: "Tasks done"), isShown: isShown)
        }
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .foregroundStyle(Color.text.opacity(0.06))
        }
    }

    @ViewBuilder private func Stat(value: Int, label: String, isShown: Bool) -> some View {
        VStack(spacing: 2) {
            // Zero until the details show, so the numbers roll up as they appear.
            RollingNumber(value: isShown ? value : 0)
                .font(.title.bold())
                .foregroundStyle(Color.text)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Week 1") {
    ProgramMilestoneView(milestone: ProgramMilestone(day: 7, checkInCount: 6, tasksDone: 5)) { }
}

#Preview("Day 30") {
    ProgramMilestoneView(milestone: ProgramMilestone(day: 30, checkInCount: 27, tasksDone: 24)) { }
}
