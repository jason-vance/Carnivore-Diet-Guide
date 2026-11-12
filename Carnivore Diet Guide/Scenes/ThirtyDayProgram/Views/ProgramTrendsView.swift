//
//  ProgramTrendsView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/11/26.
//

import Charts
import SwiftUI

/// A chart of one metric across the user's check-ins, with how far it has moved since the start.
struct ProgramTrendsView: View {

    let progress: ProgramProgress

    @State private var metric: ProgramMetric = .energy

    private var points: [(day: Int, rating: Int)] {
        progress.orderedCheckIns.map { (day: $0.day, rating: $0.checkIn.rating(for: metric)) }
    }

    private var lastDay: Int {
        max(points.last?.day ?? 1, 7)
    }

    /// Up to about six evenly spaced day labels, always including the last day.
    private var dayTicks: [Int] {
        let step = max(1, Int((Double(lastDay - 1) / 5).rounded(.up)))
        var ticks = Array(stride(from: 1, through: lastDay, by: step))
        if ticks.last != lastDay {
            if let last = ticks.last, lastDay - last < step / 2 + 1 { ticks.removeLast() }
            ticks.append(lastDay)
        }
        return ticks
    }

    var body: some View {
        ProgramCard {
            ProgramCardHeading(title: String(localized: "Your trends"), systemImage: "chart.line.uptrend.xyaxis")
            if points.count < 2 {
                Text("Check in on two different days to start seeing your trends.")
                    .font(.subheadline)
                    .foregroundStyle(Color.text.opacity(0.7))
            } else {
                Picker("Measure", selection: $metric) {
                    ForEach(ProgramMetric.allCases) { metric in
                        Text(metric.title).tag(metric)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                Chart {
                    ForEach(points, id: \.day) { point in
                        LineMark(
                            x: .value("Day", Double(point.day)),
                            y: .value(metric.title, point.rating)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color.accentColor)
                        PointMark(
                            x: .value("Day", Double(point.day)),
                            y: .value(metric.title, point.rating)
                        )
                        .foregroundStyle(Color.accentColor)
                    }
                }
                .chartYScale(domain: 1...5)
                // Half a day of padding on each side so the first and last day labels fit when centered.
                .chartXScale(domain: 0.5...(Double(lastDay) + 0.5))
                .chartYAxis {
                    AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let rating = value.as(Int.self) {
                                Text(metric.label(forRating: rating))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: dayTicks.map(Double.init)) { value in
                        AxisGridLine()
                        AxisValueLabel(anchor: .top) {
                            if let day = value.as(Double.self) {
                                Text("Day \(Int(day))")
                            }
                        }
                    }
                }
                .frame(height: 160)
                .accessibilityLabel(Text("\(metric.title) by day"))
                if let trend = ProgramTrend.trend(for: metric, in: progress) {
                    TrendSummary(trend)
                }
            }
        }
    }

    @ViewBuilder private func TrendSummary(_ trend: ProgramTrend) -> some View {
        let change = trend.change
        let from = metric.label(forRating: Int(trend.from.rounded()))
        let to = metric.label(forRating: Int(trend.to.rounded()))
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: change > 0.25 ? "arrow.up.right" : change < -0.25 ? "arrow.down.right" : "arrow.right")
                .foregroundStyle(change < -0.25 ? Color.text.opacity(0.6) : Color.accentColor)
            if abs(change) <= 0.25 {
                Text("No big change in \(metric.title.lowercased()) yet.")
            } else {
                Text("\(metric.title): \(from.lowercased()) at the start, \(to.lowercased()) lately.")
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.text)
    }
}

#Preview {
    ProgramTrendsView(progress: .sample(currentDay: 12))
        .padding()
        .background(Color.background)
}
