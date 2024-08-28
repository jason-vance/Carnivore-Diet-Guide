//
//  AppVersionRow.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct AppVersionRow: View {
    
    var appVersion: String { "\(AppVersion.appVersion ?? "???") (\(AppVersion.buildNumber ?? "???"))" }

    var body: some View {
        Section {
            LabeledContent("App Version") { Text(appVersion) }
                .font(.callout.bold())
                .foregroundStyle(Color.text.opacity(0.25))
                .padding(.horizontal)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    AppVersionRow()
}
