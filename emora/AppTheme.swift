import SwiftUI

enum AppColor {
    static let accent = Color(hex: "A85574")
    static let accentSoft = Color(hex: "D98FA8")
    static let destructive = Color(hex: "C23B3B")

    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "5C5C5C")
    static let textTertiary = Color(hex: "8A8A8A")

    static let border = Color.black.opacity(0.08)
    static let surface = Color(.tertiarySystemFill)
    static let chipSurface = Color(hex: "EDE9EC")
    static let backgroundGradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "FFFFFF"), location: 0),
            Gradient.Stop(color: Color(hex: "FFFDFC"), location: 0.32),
            Gradient.Stop(color: Color(hex: "FDF1F6"), location: 0.68),
            Gradient.Stop(color: Color(hex: "FAE8EF"), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AppSpacing {
    static let screenHorizontal: CGFloat = 24
    static let section: CGFloat = 24
    static let group: CGFloat = 16
    static let screenVertical: CGFloat = 20
    static let compact: CGFloat = 8
    static let cardRadius: CGFloat = 16
    static let minimumTapTarget: CGFloat = 44
}

extension View {
    func pageTitleStyle() -> some View {
        font(.system(.title2, design: .default, weight: .bold))
            .foregroundStyle(AppColor.textPrimary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    func sectionTitleStyle() -> some View {
        font(.system(.headline, design: .default, weight: .semibold))
            .foregroundStyle(AppColor.textPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    func bodyTextStyle(color: Color = AppColor.textPrimary) -> some View {
        font(.system(.body, design: .default))
            .foregroundStyle(color)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    func secondaryTextStyle() -> some View {
        font(.system(.subheadline, design: .default))
            .foregroundStyle(AppColor.textSecondary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    func captionTextStyle(color: Color = AppColor.textSecondary) -> some View {
        font(.system(.caption, design: .default))
            .foregroundStyle(color)
    }

    func cardBackground() -> some View {
        background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 0.5)
            }
    }
}

extension Color {
    init(hex: String) {
        let normalized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
