//
//  ContinueWithGoogleButton.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 11/24/26.
//

import SwiftUI
import UIKit

/// "Continue with Google", sized and shaped like `SignInWithAppleButton` so the two sit together.
/// Follows Google's branding guidelines: the standard "G" logo on white with a gray outline, or on
/// Google's dark gray in the dark style.
struct ContinueWithGoogleButton: View {

    enum Style {
        case light
        case dark
    }

    var style: Style = .light
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let logo = Self.logo {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .accessibilityHidden(true)
                }
                Text("Continue with Google", comment: "Button that signs in with a Google account")
                    .font(.system(size: 19, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(style == .light ? Self.lightText : Self.darkText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(style == .light ? Color.white : Self.darkFill)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(style == .light ? Self.lightOutline : Self.darkOutline, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // Colors from Google's sign-in branding guidelines.
    private static let lightText = Color(red: 0x1F / 255, green: 0x1F / 255, blue: 0x1F / 255)
    private static let lightOutline = Color(red: 0x74 / 255, green: 0x77 / 255, blue: 0x75 / 255)
    private static let darkText = Color(red: 0xE3 / 255, green: 0xE3 / 255, blue: 0xE3 / 255)
    private static let darkFill = Color(red: 0x13 / 255, green: 0x13 / 255, blue: 0x14 / 255)
    private static let darkOutline = Color(red: 0x8E / 255, green: 0x91 / 255, blue: 0x8F / 255)

    /// Google's "G", from the resource bundle the GoogleSignIn package adds to the app.
    private static let logo: UIImage? = {
        guard let url = Bundle.main.url(forResource: "GoogleSignIn_GoogleSignIn", withExtension: "bundle"),
              let bundle = Bundle(url: url) else {
            return nil
        }
        return UIImage(named: "google", in: bundle, with: nil)
    }()
}

#Preview {
    VStack(spacing: 16) {
        ContinueWithGoogleButton { }
            .frame(height: 48)
        ContinueWithGoogleButton(style: .dark) { }
            .frame(height: 48)
    }
    .padding()
    .background(Color.accent)
}
