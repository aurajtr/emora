import SwiftUI

struct PlaceholderTabView: View {
    let title: String
    let systemImage: String

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            ContentUnavailableView(title, systemImage: systemImage)
                .foregroundStyle(AppColor.textPrimary, AppColor.accent)
                .accessibilityLabel(title)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
