import SwiftUI

struct MoodPicker: View {
    @Binding var selectedMood: Mood?

    var body: some View {
        GeometryReader { proxy in
            let iconSize: CGFloat = 54
            let availableSpacing = (proxy.size.width - (iconSize * CGFloat(Mood.allCases.count))) / CGFloat(Mood.allCases.count - 1)
            let spacing = min(max(availableSpacing, 10), 18)

            HStack(spacing: spacing) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        MoodIcon(mood: mood, isSelected: selectedMood == mood, size: iconSize)
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: AppSpacing.minimumTapTarget, minHeight: AppSpacing.minimumTapTarget)
                    .accessibilityLabel(mood.name)
                    .accessibilityValue(selectedMood == mood ? "Selected" : "Not selected")
                    .accessibilityHint("Sets current mood to \(mood.name)")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 56)
        .accessibilityElement(children: .contain)
    }
}

struct MoodIcon: View {
    let mood: Mood
    let isSelected: Bool
    let size: CGFloat

    var body: some View {
        Image(mood.assetName)
            .resizable()
            .scaledToFit()
            .padding(size * 0.1)
            .frame(width: size, height: size)
            .background(mood.fill, in: Circle())
            .overlay {
                Circle()
                    .stroke(mood.ring, lineWidth: 1.5)
            }
            .scaleEffect(isSelected ? 1.04 : 1)
            .shadow(color: isSelected ? mood.ring.opacity(0.34) : .clear, radius: 12, x: 0, y: 6)
            .shadow(color: isSelected ? mood.ring.opacity(0.18) : .clear, radius: 4, x: 0, y: 1)
            .contentShape(Circle())
            .accessibilityHidden(true)
    }
}

struct MoodEntryCard: View {
    let entry: MoodHistoryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.compact) {
                Circle()
                    .fill(entry.mood.fill)
                    .frame(width: 16, height: 16)
                    .accessibilityHidden(true)

                Text(entry.mood.name)
                    .font(.system(.body, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Spacer(minLength: AppSpacing.compact)

                Text(entry.shortDate)
                    .captionTextStyle()
            }

            Text(entry.note)
                .secondaryTextStyle()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.mood.name), \(entry.shortDate). \(entry.note)")
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(AppColor.textTertiary)
                .frame(width: 42, height: 42)
                .background(AppColor.surface, in: Circle())
                .overlay {
                    Circle().stroke(AppColor.border, lineWidth: 0.5)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, Aura J")
                    .font(.system(.body, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Text(todayText)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hello Aura J. \(todayText)")
    }

    private var todayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        return "Today, \(formatter.string(from: Date.now))"
    }
}
