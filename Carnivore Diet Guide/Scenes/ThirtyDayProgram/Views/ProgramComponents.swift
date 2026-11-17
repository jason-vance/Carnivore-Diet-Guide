//
//  ProgramComponents.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import SwiftUI

/// The rounded, lightly tinted card used throughout the program screens.
struct ProgramCard<Content: View>: View {

    var tint: Color = Color.text
    var tintOpacity: Double = 0.06
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .foregroundStyle(tint.opacity(tintOpacity))
        }
    }
}

/// A small icon-and-caption heading inside a `ProgramCard`.
struct ProgramCardHeading: View {

    let title: String
    let systemImage: String
    var color: Color = Color.accentColor

    var body: some View {
        Label {
            Text(title)
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(Color.text.opacity(0.7))
        } icon: {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
        }
    }
}

struct ProgramPrimaryButtonLabel: View {

    let title: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
        .font(.headline)
        .foregroundStyle(Color.background)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .foregroundStyle(Color.accentColor.gradient)
        }
    }
}

struct ProgramSecondaryButtonLabel: View {

    let title: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color.accentColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                .stroke(Color.accentColor, lineWidth: .borderWidthMedium)
        }
    }
}

/// How far through the 30 days the user is. It fills from empty when it appears, then moves as days pass.
struct ProgramProgressBar: View {

    let day: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shownDay: Double = 0

    private var fraction: Double {
        min(max(shownDay / Double(ProgramSchedule.length), 0), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundStyle(Color.text.opacity(0.1))
                Capsule()
                    .foregroundStyle(Color.accentColor.gradient)
                    .frame(width: max(geometry.size.height, geometry.size.width * fraction))
                    .opacity(shownDay > 0 ? 1 : 0)
            }
        }
        .frame(height: 6)
        .onAppear {
            guard !reduceMotion else {
                shownDay = Double(day)
                return
            }
            withAnimation(.easeOut(duration: 0.9).delay(0.2)) { shownDay = Double(day) }
        }
        .onChange(of: day) { _, newValue in
            withAnimation(.snappy) { shownDay = Double(newValue) }
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Progress"))
        .accessibilityValue(Text("Day \(day) of 30"))
    }
}

/// Lays out views left to right and wraps onto new lines, for chips.
struct ProgramFlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews: subviews, maxWidth: proposal.width ?? .infinity)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews: subviews, maxWidth: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let neededWidth = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            if neededWidth > maxWidth && !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty {
            rows.append(current)
        }
        return rows
    }
}

/// The shared "not medical advice" footer.
struct ProgramDisclaimer: View {
    var body: some View {
        Text(FirstThirtyDays.disclaimer)
            .font(.caption)
            .foregroundStyle(Color.text.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
}
