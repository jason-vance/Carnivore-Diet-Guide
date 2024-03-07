//
//  MicrowaveTimeEntryDialog.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 3/6/24.
//

import SwiftUI

struct MicrowaveTimeEntryDialog: View {
    
    private let buttonSize: CGFloat = 48
    
    @Environment(\.dismiss) private var dismiss
    
    @State var prompt: String
    @Binding var microwaveTime: MicrowaveTime
    
    @State private var numberString: String = ""
    
    private var myMicrowaveTime: MicrowaveTime {
        var hours = 0
        var minutes = 0
        let initializer = { (hours:Int, minutes:Int) in
            MicrowaveTime(hours: hours, minutes: minutes) ?? .zero
        }
        
        if numberString.count <= 2 {
            minutes = Int(numberString) ?? 0
        } else {
            let hoursDigits = numberString.count - 2
            hours = Int(numberString.prefix(hoursDigits)) ?? 0
            minutes = Int(numberString.suffix(2)) ?? 0
        }
        
        return initializer(hours, minutes)
    }
    
    private var myMicrowaveTimeString: String {
        var hours = 0
        var minutes = 0
        let formatter = { (hours:Int, minutes:Int) in
            String.init(format: "%d:%02d", hours, minutes)
        }
        
        if numberString.count <= 2 {
            minutes = Int(numberString) ?? 0
        } else {
            let hoursDigits = numberString.count - 2
            hours = Int(numberString.prefix(hoursDigits)) ?? 0
            minutes = Int(numberString.suffix(2)) ?? 0
        }
        
        return formatter(hours, minutes)
    }
    
    func setMicrowaveTime() {
        microwaveTime = myMicrowaveTime
    }
    
    func appendNumber(_ number: Int) {
        numberString += "\(number)"
    }
    
    func deleteNumber() {
        if numberString.isEmpty {
            return
        }
        numberString.removeLast()
    }
    
    var body: some View {
        VStack {
            TitleBar()
            Spacer()
            ValueDisplay()
            KeyPad()
            Spacer()
            OkCancelButtons()
        }
        .padding()
        .presentationDetents([.medium])
        .presentationBackground(Color.background)
        .onAppear {
            numberString = microwaveTime.formatted().filter({ $0.isNumber })
        }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        Text(prompt)
            .font(.headerSemibold)
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func ValueDisplay() -> some View {
        Text(myMicrowaveTimeString)
            .font(.titleBold)
            .foregroundStyle(Color.text)
    }
    
    @ViewBuilder func KeyPad() -> some View {
        VStack {
            HStack {
                NumberButton(1)
                NumberButton(2)
                NumberButton(3)
            }
            HStack {
                NumberButton(4)
                NumberButton(5)
                NumberButton(6)
            }
            HStack {
                NumberButton(7)
                NumberButton(8)
                NumberButton(9)
            }
            HStack {
                NumberButton(0)
                    .hidden()
                NumberButton(0)
                BackspaceButton()
            }
        }
    }
    
    @ViewBuilder func NumberButton(_ number: Int) -> some View {
        Button {
            appendNumber(number)
        } label: {
            Text("\(number)")
                .font(.headerSemibold)
                .foregroundStyle(Color.text)
                .frame(maxWidth: .infinity, minHeight: buttonSize, maxHeight: buttonSize)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                        .stroke(lineWidth: .buttonStrokeWidthDefault)
                        .foregroundStyle(Color.accentColor)
                }
        }
    }
    
    @ViewBuilder func BackspaceButton() -> some View {
        Button {
            deleteNumber()
        } label: {
            Image(systemName: "delete.left.fill")
                .font(.headerSemibold)
        }
        .frame(maxWidth: .infinity, minHeight: buttonSize, maxHeight: buttonSize)
    }
    
    @ViewBuilder func OkCancelButtons() -> some View {
        HStack {
            TextButton("Cancel") {
                dismiss()
            }
            TextButton("OK") {
                setMicrowaveTime()
                dismiss()
            }
        }
    }
    
    @ViewBuilder func TextButton(_ text: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Text(text)
                .bold()
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity, minHeight: buttonSize, maxHeight: buttonSize)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusDefault, style: .continuous)
                        .foregroundStyle(Color.accentColor)
                }
        }
    }
}

#Preview {
    StatefulPreviewContainer(true) { isShown in
        StatefulPreviewContainer(MicrowaveTime.zero) { time in
            Button {
                isShown.wrappedValue = true
            } label: {
                Text(time.wrappedValue.formatted())
            }
            .sheet(isPresented: isShown) {
                MicrowaveTimeEntryDialog(
                    prompt: "Microwave Time",
                    microwaveTime: time
                )
            }
        }
    }
}
