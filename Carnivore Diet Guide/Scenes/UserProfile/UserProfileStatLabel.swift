//
//  UserProfileStatLabel.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/27/24.
//

import SwiftUI

struct UserProfileStatLabel: View {
    
    public let value: Int?
    public let title: String
    
    @State private var _value: Int? = nil
    @State private var _title: String = ""
    
    private var valueString: String {
        if let _value = _value {
            return "\(_value)"
        }
        return "-"
    }
    
    var body: some View {
        VStack {
            StatValue()
            StatTitle()
        }
        .onChange(of: value, initial: true) { oldValue, newValue in
            self._value = newValue
        }
        .onChange(of: title, initial: true) { oldTitle, newTitle in
            self._title = newTitle
        }
    }
    
    @ViewBuilder func StatValue() -> some View {
        Text(valueString)
            .font(.body.bold())
            .foregroundStyle(Color.text)
            .opacity((_value ?? 0) > 0 ? 1.0 : 0.5)
    }
    
    @ViewBuilder func StatTitle() -> some View {
        Text(_title)
            .font(.body)
            .foregroundStyle(Color.text)
    }
    
}

#Preview {
    StatefulPreviewContainer(0) { count in
        Button {
            count.wrappedValue = count.wrappedValue + 1
        } label: {
            UserProfileStatLabel(value: count.wrappedValue, title: "Title")
        }
    }
}
