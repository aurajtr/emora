import SwiftUI
import UIKit

enum AppColor {
    static let accent = Color(hex: "A85574", darkHex: "E6A1BB")
    static let accentSoft = Color(hex: "D98FA8", darkHex: "6A3448")
    static let destructive = Color(hex: "C23B3B", darkHex: "FF6961")

    static let textPrimary = Color(hex: "1A1A1A", darkHex: "F5F1F3")
    static let textSecondary = Color(hex: "5C5C5C", darkHex: "CFC7CB")
    static let textTertiary = Color(hex: "8A8A8A", darkHex: "9A9296")

    static let border = Color(hex: "000000", darkHex: "FFFFFF").opacity(0.08)
    static let surface = Color(.tertiarySystemFill)
    static let chipSurface = Color(hex: "EDE9EC", darkHex: "30282D")
    static let statSurface = Color(hex: "F1D7E1", darkHex: "452B35")
    static let backgroundGradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "FFFFFF", darkHex: "181416"), location: 0),
            Gradient.Stop(color: Color(hex: "FFFDFC", darkHex: "1D171A"), location: 0.32),
            Gradient.Stop(color: Color(hex: "FDF1F6", darkHex: "241A1F"), location: 0.68),
            Gradient.Stop(color: Color(hex: "FAE8EF", darkHex: "2A1D23"), location: 1)
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

    func appNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.automatic, for: .navigationBar)
    }

    func scrollResponsiveNavigationTitle(_ title: String, isVisible: Bool) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .opacity(isVisible ? 1 : 0)
                        .accessibilityHidden(!isVisible)
                        .animation(.easeInOut(duration: 0.18), value: isVisible)
                }
            }
            .toolbarBackground(isVisible ? .visible : .hidden, for: .navigationBar)
            .animation(.easeInOut(duration: 0.18), value: isVisible)
    }
}

extension Color {
    init(hex: String, darkHex: String? = nil) {
        self.init(UIColor { traitCollection in
            UIColor(appHex: traitCollection.userInterfaceStyle == .dark ? darkHex ?? hex : hex)
        })
    }
}

private extension UIColor {
    convenience init(appHex: String) {
        let normalized = appHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&rgb)

        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
