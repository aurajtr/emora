import SwiftUI
import PhotosUI
import UIKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profileUsername") private var savedUsername = ""
    @AppStorage("profileImageVersion") private var profileImageVersion = 0
    @State private var draftUsername = ""
    @State private var draftImageData: Data?
    @State private var pendingImageData: Data?
    @State private var removesSavedPhoto = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showsPhotoOptions = false
    @State private var showsPhotoPicker = false
    @State private var showsPhotoConfirmation = false

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            VStack(spacing: AppSpacing.group) {
                VStack(spacing: 10) {
                    Button {
                        if hasPhotoChoice {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                showsPhotoOptions.toggle()
                            }
                        } else {
                            showsPhotoPicker = true
                        }
                    } label: {
                        VStack(spacing: 12) {
                            ProfileAvatarView(
                                size: 112,
                                previewImageData: draftImageData,
                                hidesSavedImage: removesSavedPhoto
                            )

                            Text(photoActionTitle)
                                .font(.system(.subheadline, design: .default, weight: .semibold))
                                .foregroundStyle(AppColor.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(photoActionTitle)

                    if showsPhotoOptions {
                        photoOptions
                            .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .sectionTitleStyle()

                    TextField("Enter username", text: $draftUsername)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .font(.system(.body, design: .default))
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(14)
                        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                                .stroke(AppColor.border, lineWidth: 0.5)
                        }
                        .submitLabel(.done)
                        .onSubmit(normalizeDraftUsername)
                        .accessibilityLabel("Username")
                }

                Button {
                    saveProfile()
                } label: {
                    Text("Save")
                        .font(.system(.body, design: .default, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(AppColor.accent)
                .accessibilityHint("Saves your profile changes")

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.group)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .photosPicker(isPresented: $showsPhotoPicker, selection: $selectedPhoto, matching: .images)
        .sheet(isPresented: $showsPhotoConfirmation) {
            if let pendingImageData {
                ProfilePhotoConfirmationView(imageData: pendingImageData) {
                    cancelPendingPhoto()
                } onConfirm: {
                    confirmPendingPhoto()
                }
            }
        }
        .onAppear {
            draftUsername = savedUsername
            draftImageData = nil
            pendingImageData = nil
            removesSavedPhoto = false
            showsPhotoOptions = false
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                await loadSelectedPhoto(newItem)
            }
        }
    }

    private var photoOptions: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    showsPhotoOptions = false
                }
                showsPhotoPicker = true
            } label: {
                Label("Change Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }

            Button(role: .destructive) {
                removeDraftPhoto()
            } label: {
                Label("Remove Photo", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.system(.subheadline, design: .default, weight: .semibold))
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }

    private var hasPhotoChoice: Bool {
        draftImageData != nil || (!removesSavedPhoto && ProfileImageStore.exists)
    }

    private var photoActionTitle: String {
        hasPhotoChoice ? "Change Photo" : "Add Photo"
    }

    private func normalizeDraftUsername() {
        draftUsername = draftUsername.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removeDraftPhoto() {
        withAnimation(.easeInOut(duration: 0.18)) {
            draftImageData = nil
            pendingImageData = nil
            removesSavedPhoto = true
            selectedPhoto = nil
            showsPhotoOptions = false
        }
    }

    private func saveProfile() {
        normalizeDraftUsername()
        savedUsername = draftUsername

        if removesSavedPhoto {
            do {
                try ProfileImageStore.delete()
                profileImageVersion += 1
            } catch {
                // Keep the existing saved photo if deleting fails.
            }
        } else if let draftImageData {
            do {
                try ProfileImageStore.save(draftImageData)
                profileImageVersion += 1
            } catch {
                // Keep the existing saved photo if writing fails.
            }
        }

        dismiss()
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data),
                let profileData = image.profileImageData()
            else { return }

            await MainActor.run {
                pendingImageData = profileData
                selectedPhoto = nil
                showsPhotoConfirmation = true
            }
        } catch {
            // Keep the current draft image if loading fails.
        }
    }

    private func cancelPendingPhoto() {
        pendingImageData = nil
        showsPhotoConfirmation = false
    }

    private func confirmPendingPhoto() {
        guard let pendingImageData else { return }
        draftImageData = pendingImageData
        removesSavedPhoto = false
        self.pendingImageData = nil
        showsPhotoConfirmation = false
    }
}

private struct ProfilePhotoConfirmationView: View {
    let imageData: Data
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.backgroundGradient.ignoresSafeArea()

                VStack(spacing: AppSpacing.group) {
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(AppColor.border, lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                    }

                    Text("Use this photo?")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                .padding(AppSpacing.screenHorizontal)
            }
            .navigationTitle("Profile Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: onConfirm) {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel("Use photo")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct ProfileAvatarView: View {
    @AppStorage("profileImageVersion") private var profileImageVersion = 0
    let size: CGFloat
    var previewImageData: Data? = nil
    var hidesSavedImage = false

    var body: some View {
        avatarContent
            .frame(width: size, height: size)
            .background(AppColor.surface, in: Circle())
            .clipShape(Circle())
            .overlay {
                Circle().stroke(AppColor.border, lineWidth: 0.5)
            }
            .contentShape(Circle())
            .id(profileImageVersion)
    }

    @ViewBuilder
    private var avatarContent: some View {
        if let previewImageData, let uiImage = UIImage(data: previewImageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if !hidesSavedImage, let uiImage = ProfileImageStore.load() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.46, weight: .regular))
                .foregroundStyle(AppColor.textTertiary)
        }
    }
}

enum ProfileImageStore {
    private static let fileName = "profile-photo.jpg"

    static var exists: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    static func save(_ data: Data) throws {
        try data.write(to: fileURL, options: [.atomic])
    }

    static func delete() throws {
        guard exists else { return }
        try FileManager.default.removeItem(at: fileURL)
    }

    static func load() -> UIImage? {
        UIImage(contentsOfFile: fileURL.path)
    }

    private static var fileURL: URL {
        URL.documentsDirectory.appending(path: fileName)
    }
}

private extension UIImage {
    func profileImageData(maxDimension: CGFloat = 720) -> Data? {
        let largestSide = max(size.width, size.height)
        let scale = min(1, maxDimension / largestSide)
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage.jpegData(compressionQuality: 0.78)
    }
}

#Preview("Profile") {
    NavigationStack {
        ProfileView()
    }
}
