//
//  SeedUserCreatorView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 10/14/25.
//

import SwiftUI

struct SeedUserCreatorView: View {
    
    private let imageSize: CGFloat = 128
    
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    @EnvironmentObject private var seedUserCreator: SeedUserCreator
    
    @State private var isWorking: Bool = false

    @State private var showImagePicker: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var userImage: UIImage? = nil
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var whyCarnivore: String = ""
    @State private var carnivoreSince: Date = .now
    
    private func show(alert: String) {
        showAlert = true
        alertMessage = alert
    }
    
    private var formIsValid: Bool {
        return userData != nil && userImage != nil
    }
    
    private var userData: UserData? {
        guard let username = Username(username) else { return nil }
        guard let bio = UserBio(bio) else { return nil }
        guard let whyCarnivore = WhyCarnivore(whyCarnivore) else { return nil }
        guard let carnivoreSince = CarnivoreSince(carnivoreSince) else { return nil }

        return .init(
            id: UUID().uuidString,
            username: username,
            bio: bio,
            whyCarnivore: whyCarnivore,
            carnivoreSince: carnivoreSince
        )
    }
    
    private func saveAndDismiss() {
        isWorking = true
        Task {
            do {
                guard let userData = userData else {
                    throw NSError(domain: "userData is nil", code: 1234)
                }
                guard let image = userImage else {
                    throw NSError(domain: "userData is nil", code: 1234)
                }
                
                try await seedUserCreator.create(
                    seedUser: userData,
                    withProfileImage: image
                )
                
                userImage = nil
                username = ""
                bio = ""
                whyCarnivore = ""
                carnivoreSince = .now
            } catch {
                let msg = "Failed to create seed user: \(error.localizedDescription)"
                print(msg)
                show(alert: msg)
            }
            isWorking = false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBar()
            List {
                ImageField()
                UsernameField()
                BioField()
                WhyCarnivoreField()
                CarnivoreSinceField()
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.background)
        .alert(alertMessage, isPresented: $showAlert) {}
        .animation(.snappy, value: isWorking)
        .overlay {
            if isWorking {
                BlockingSpinnerView()
            }
        }
    }
    
    @ViewBuilder func TitleBar() -> some View {
        ScreenTitleBar(
            primaryContent: { Text("Seed User") },
            leadingContent: BackButton,
            trailingContent: SaveAndDismissButton
        )
    }
    
    @ViewBuilder func BackButton() -> some View {
        Button {
            dismiss()
        } label: {
            ResourceMenuButtonLabel(sfSymbol: "xmark")
        }
    }
    
    @ViewBuilder func SaveAndDismissButton() -> some View {
        NextButton { saveAndDismiss() }
            .disabled(!formIsValid)
    }
    
    @ViewBuilder func ImageField() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                if let userImage {
                    ImageCarouselItem(userImage)
                } else {
                    AddImageButton()
                }
            }
            .scrollTargetLayout()
            .padding(.vertical)
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .listRowInsets(EdgeInsets())    // Must be last or scrollContent margins will be messed up
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder private func ImageCarouselItem(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                    .stroke(style: .init(lineWidth: .borderWidthMedium))
                    .foregroundStyle(Color.accent)
            }
    }
    
    @ViewBuilder private func AddImageButton() -> some View {
        Button {
            showImagePicker = true
        } label: {
            Image(systemName: "photo")
                .foregroundStyle(Color.accent)
                .frame(width: imageSize, height: imageSize)
                .background {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .foregroundStyle(Color.background)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: .cornerRadiusMedium, style: .continuous)
                        .stroke(style: .init(lineWidth: .borderWidthMedium))
                        .foregroundStyle(Color.accent)
                }
                .overlay(alignment: .bottomTrailing) {
                    ImageAccessory("plus")
                }
        }
        .sheet(isPresented: $showImagePicker, content: ImagePicker)
    }
    
    @ViewBuilder private func ImageAccessory(_ name: String) -> some View {
        Image(systemName: name)
            .foregroundStyle(Color.background)
            .frame(width: .cornerRadiusMedium * 3, height: .cornerRadiusMedium * 2)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: .cornerRadiusMedium, bottomTrailing: .cornerRadiusMedium),
                    style: .continuous
                )
                .foregroundStyle(Color.accent)
            }
    }
    
    @ViewBuilder func ImagePicker() -> some View {
        ImagePickerView { selectedImage in
            showImagePicker = false
            userImage = selectedImage
        } didCancel: {
            showImagePicker = false
        }
    }
    
    @ViewBuilder func UsernameField() -> some View {
        TextField(
            "Username",
            text: $username,
            prompt: Text("Username").foregroundStyle(Color.text.opacity(0.3))
        )
        .textInputAutocapitalization(.never)
        .font(.title.bold())
        .foregroundStyle(Color.text)
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func BioField() -> some View {
        ZStack(alignment: .topLeading) {
            Text("Bio")
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .padding(.vertical, 8)
                .padding(.horizontal, 5)
                .opacity(bio.isEmpty ? 1 : 0)
            TextEditor(text: $bio)
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(Color.text)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func WhyCarnivoreField() -> some View {
        ZStack(alignment: .topLeading) {
            Text("Why carnivore")
                .foregroundStyle(Color.text)
                .opacity(0.3)
                .padding(.vertical, 8)
                .padding(.horizontal, 5)
                .opacity(whyCarnivore.isEmpty ? 1 : 0)
            TextEditor(text: $whyCarnivore)
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(Color.text)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder func CarnivoreSinceField() -> some View {
        HStack {
            Text("Carnivore Since")
                .foregroundStyle(Color.text)
                .padding(.vertical, 8)
                .padding(.horizontal, 5)
            Spacer()
            DatePicker("", selection: $carnivoreSince, displayedComponents: [.date])
        }
        .listRowBackground(Color.background)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    SeedUserCreatorView()
        .environmentObject(SeedUserCreator.forTesting)
}
