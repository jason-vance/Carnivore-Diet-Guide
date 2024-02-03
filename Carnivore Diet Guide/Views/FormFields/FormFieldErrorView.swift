//
//  FormFieldErrorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/1/24.
//

import SwiftUI

struct FormFieldErrorView: View {
    
    @State var icon: String
    @State var text: String
    @State var color: Color
    
    static let none = FormFieldErrorView(
        icon: "square",
        text: "",
        color: .clear
    )
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.text)
            Spacer()
        }
        .frame(height: 20)
        .padding(.horizontal)
    }
}

#Preview {
    FormFieldErrorView(
        icon: "circle.fill",
        text: "Something is wrong",
        color: Color.red
    )
}
