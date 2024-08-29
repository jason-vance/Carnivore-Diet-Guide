//
//  PublicationDateView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct PublicationDateView: View {
    
    public let date: Date
    
    init(resource: Resource) {
        self.date = resource.publicationDate
    }
    
    init(date: Date) {
        self.date = date
    }
    
    var body: some View {
        Text(date.toBasicUiString())
            .font(.caption)
            .foregroundStyle(Color.text)
    }
}

#Preview {
    PublicationDateView(resource: .sample)
}
