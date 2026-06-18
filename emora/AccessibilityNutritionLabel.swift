import SwiftUI

struct AccessibilityNutritionLabel: View {
    var body: some View {
        Section {
            LabeledContent("Text") {
                Text("Dynamic Type")
                    .foregroundStyle(AppColor.textSecondary)
            }

            LabeledContent("Contrast") {
                Text("AA-ready")
                    .foregroundStyle(AppColor.textSecondary)
            }

            LabeledContent("Touch targets") {
                Text("44 pt minimum")
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .font(.footnote)
        .foregroundStyle(AppColor.textPrimary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Accessibility nutrition label. Text supports Dynamic Type. Contrast uses dark text on light surfaces. Touch targets are at least 44 points.")
    }
}
