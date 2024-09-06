//
//  TimeFramePicker.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/6/24.
//

import SwiftUI

struct TimeFramePicker: View {
    
    @Binding public var timeFrame: TimeFrame
    
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 2) {
            PickerButton(String(localized: "24 Hours"), timeFrame: .past24Hours)
            PickerButton(String(localized: "7 Days"), timeFrame: .past7Days)
            PickerButton(String(localized: "4 Weeks"), timeFrame: .past4Weeks)
        }
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                .foregroundStyle(Color.accent)
                .matchedGeometryEffect(id: "SELECTED", in: namespace, isSource: false)
        }
    }
    
    @ViewBuilder func PickerButton(_ text: String, timeFrame: TimeFrame) -> some View {
        let isSelected = self.timeFrame == timeFrame
        
        Button {
            withAnimation(.snappy) {
                self.timeFrame = timeFrame
            }
        } label: {
            Text(text)
                .foregroundStyle(isSelected ? Color.background : Color.accent)
                .font(.caption2.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, .paddingVerticalButtonSmall)
                .padding(.horizontal, .paddingHorizontalButtonSmall)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusSmall, style: .continuous)
                        .foregroundStyle(Color.accent.opacity(0.1))
                        .matchedGeometryEffect(id: isSelected ? "SELECTED" : text, in: namespace, isSource: true)
                }
        }
        .disabled(isSelected)
    }
}

#Preview {
    StatefulPreviewContainer(TimeFrame.past24Hours) { timeFrame in
        TimeFramePicker(timeFrame: timeFrame)
    }
}
