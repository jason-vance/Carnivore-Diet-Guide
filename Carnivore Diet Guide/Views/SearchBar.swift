//
//  SearchBar.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct SearchBar: View {
    
    @State var prompt: String
    @Binding var searchText: String
    @Binding var searchPresented: Bool
    var action: ()->()
    @FocusState private var focus
    
    @State private var showCancel: Bool = false
    
    var body: some View {
        HStack {
            TextField(prompt, text: $searchText)
                .onSubmit(of: .text) {
                    action()
                }
                .preferredColorScheme(.light)
                .focused($focus)
                .textFieldStyle(.plain)
                .overlay(alignment: .trailing) {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.text.opacity(0.33))
                    }
                    .opacity(showCancel ? 1 : 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundStyle(Color.text.opacity(0.1))
                }
            if showCancel {
                Button(action: {
                    searchText = ""
                    focus = false
                }) {
                    Text("Cancel")
                        .foregroundColor(Color.accent)
                }
                .transition(.asymmetric(
                    insertion: .push(from: .trailing),
                    removal: .push(from: .leading)
                ))
            }
        }
        .onChange(of: focus, initial: true) { oldFocus, newFocus in
            searchPresented = newFocus
            withAnimation(.snappy) {
                showCancel = newFocus
            }
        }
    }
}

#Preview {
    StatefulPreviewContainer("") { searchText in
        StatefulPreviewContainer(false) { searchedPresented in
            VStack {
                SearchBar(
                    prompt: "Search prompt",
                    searchText: searchText,
                    searchPresented: searchedPresented,
                    action: { }
                )
                Text("searchedPresented: \(searchedPresented.wrappedValue)")
                Spacer()
            }
        }
    }
}
