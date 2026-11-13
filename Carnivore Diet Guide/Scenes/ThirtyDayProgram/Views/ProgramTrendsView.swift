//
//  ProgramTrendsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Charts
import SwiftUI

/// A chart of one measure across the user's check-ins, with how far it has moved since the start.
struct ProgramTrendsView: View {

    let progress: ProgramProgress
    /// The user's own trackers are Carnivore+.
    var includesTrackers: Bool = false

    @State private var measureId: String = ProgramMetric.energy.rawValue

    private var measures: [ProgramMeasure] {
        progress.measures(includingTrackers: includesTrackers)
    }

    /// Falls back to the first measure if the chosen tracker was removed.
    private var measure: ProgramMeasure {
        measures.first { $0.id == measureId } ?? measures[0]
    }

    /// Only days that rated this measure, so a tracker added on day 12 starts on day 12.
    private var points: [(day: Int, rating: Int)] {
        progress.orderedCheckIns.compactMap { entry in
            measure.rating(in: entry.checkIn).map { (day: entry.day, rating: $0) }
        }
    }

    private var firstDay: Int {
        points.first?.day ?? 1
    }

    private var lastDay: Int {
        max(points.last?.day ?? 1, firstDay + 6)
    }

    /// Up to about six evenly spaced day labels, always including the first and last day.
    ///
    /// Day labels start at their grid line and run right, except the last, which ends at its line so it
    /// stays inside the chart. That leaves the last two labels facing each other, so the one before the last
    /// is dropped when it's less than one and a half steps away.
    private var dayTicks: [Int] {
        let step = max(1, Int((Double(lastDay - firstDay) / 5).rounded(.up)))
        var ticks = Array(stride(from: firstDay, to: lastDay, by: step))
        while ticks.count > 1, let previous = ticks.last, Double(lastDay - previous) < Double(step) * 1.5 {
            ticks.removeLast()
        }
        return ticks + [lastDay]
    }

    var body: some View {
        ProgramCard {
            ProgramCardHeading(title: String(localized: "Your trends"), systemImage: "chart.line.uptrend.xyaxis")
            if progress.checkIns.count < 2 {
                Text("Check in on two different days to start seeing your trends.")
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.7))
            } else {
                MeasurePicker()
                    .padding(.vertical, 4)
                if points.count < 2 {
                    Text("Rate \(measure.inlineTitle) on two different days to see its chart.")
                        .font(.subheadline)
                        .foregroundStyle(Color.text.opacity(0.7))
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
                        .multilineTextAlignment(.center)
                } else {
                    TrendChart()
                    if let trend = ProgramTrend.trend(for: measure, in: progress) {
                        TrendSummary(trend)
                    }
                }
            }
        }
    }

    /// The segmented control fits the built-in four. With trackers there are too many, so it becomes a row of chips.
    @ViewBuilder private func MeasurePicker() -> some View {
        if measures.count <= ProgramMetric.allCases.count {
            Picker("Measure", selection: $measureId) {
                ForEach(measures) { measure in
                    Text(measure.title).tag(measure.id)
                }
            }
            .pickerStyle(.segmented)
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(measures) { option in
                        let isSelected = option.id == measure.id
                        Button {
                            withAnimation(.snappy) { measureId = option.id }
                        } label: {
                            Text(option.title)
                                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Color.background : Color.text)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    Capsule().foregroundStyle(isSelected ? Color.accentColor : Color.text.opacity(0.08))
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder private func TrendChart() -> some View {
        Chart {
            ForEach(points, id: \.day) { point in
                LineMark(
                    x: .value("Day", Double(point.day)),
                    y: .value(measure.title, point.rating)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(Color.accentColor)
                PointMark(
                    x: .value("Day", Double(point.day)),
                    y: .value(measure.title, point.rating)
                )
                .foregroundStyle(Color.accentColor)
            }
        }
        .chartYScale(domain: 1...5)
        // Half a day of padding on each side keeps the first and last points off the edges.
        .chartXScale(domain: (Double(firstDay) - 0.5)...(Double(lastDay) + 0.5))
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let rating = value.as(Int.self) {
                        Text(measure.label(forRating: rating))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: dayTicks.map(Double.init)) { value in
                AxisGridLine()
                // Labels start at their line and run right, so the last one would hang past the edge and
                // Charts would drop it ("Day 10" went missing). It ends at its line instead.
                AxisValueLabel(anchor: value.index == value.count - 1 ? .topTrailing : .top) {
                    if let day = value.as(Double.self) {
                        Text("Day \(Int(day))")
                    }
                }
            }
        }
        .frame(height: 160)
        .accessibilityLabel(Text("\(measure.title) by day"))
    }

    @ViewBuilder private func TrendSummary(_ trend: ProgramTrend) -> some View {
        let change = trend.change
        let from = measure.label(forRating: Int(trend.from.rounded()))
        let to = measure.label(forRating: Int(trend.to.rounded()))
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: change > 0.25 ? "arrow.up.right" : change < -0.25 ? "arrow.down.right" : "arrow.right")
                .foregroundStyle(change < -0.25 ? Color.text.opacity(0.6) : Color.accentColor)
            if abs(change) <= 0.25 {
                Text("No big change in \(measure.inlineTitle) yet.")
            } else {
                Text("\(measure.title): \(from.lowercased()) at the start, \(to.lowercased()) lately.")
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.text)
    }
}

#Preview("Built-in") {
    ProgramTrendsView(progress: .sample(currentDay: 12))
        .padding()
        .background(Color.background)
}

#Preview("With trackers") {
    var progress = ProgramProgress.sample(currentDay: 12)
    let sinuses = progress.addTracker(named: "Sinuses", now: .now)!
    progress.addTracker(named: "Joints", now: .now)
    for day in 4..<12 {
        progress.checkIns[day]?.trackerRatings = [sinuses.id: min(5, 1 + (day - 4) / 2)]
    }
    return ProgramTrendsView(progress: progress, includesTrackers: true)
        .padding()
        .background(Color.background)
}
