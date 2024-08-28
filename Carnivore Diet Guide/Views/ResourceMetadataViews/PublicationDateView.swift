//
//  PublicationDateView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/28/24.
//

import SwiftUI

struct PublicationDateView: View {
    
    public let resource: Resource
    
    var body: some View {
        Text(resource.publicationDate.toBasicUiString())
            .font(.caption)
            .foregroundStyle(Color.text)
    }
}

#Preview {
    PublicationDateView(resource: .sample)
}
