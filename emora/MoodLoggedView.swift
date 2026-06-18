import SwiftUI

struct MoodLoggedView: View {
    let loggedMood: LoggedMood
    let onMoodLogged: (LoggedMood) -> Void
    let onDelete: () -> Void

    init(loggedMood: LoggedMood, onMoodLogged: @escaping (LoggedMood) -> Void, onDelete: @escaping () -> Void = {}) {
        self.loggedMood = loggedMood
        self.onMoodLogged = onMoodLogged
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(spacing: 18) {
            NavigationLink {
                MoodDetailView(loggedMood: loggedMood, onMoodLogged: onMoodLogged, onDelete: onDelete)
            } label: {
                MoodIcon(mood: loggedMood.mood, isSelected: true, size: 104)
                    .padding(.top, 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open mood details")

            VStack(spacing: 6) {
                Text("Mood Logged!")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text("You're feeling **\(loggedMood.mood.name)** today.\nKeep it up, you're doing great.")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !loggedMood.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(loggedMood.tags.prefix(3)) { tag in
                        Text(tag.title)
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColor.accentSoft, in: Capsule())
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Tags: \(loggedMood.tags.prefix(3).map(\.title).joined(separator: ", "))")
            }

            NavigationLink {
                FillMoodView(initialMood: loggedMood.mood, onSave: onMoodLogged)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                    Text("Edit your mood")
                }
                .font(.system(.body, design: .default, weight: .semibold))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .tint(AppColor.accent)
            .padding(.horizontal, 22)
            .accessibilityHint("Opens the mood note screen to edit this entry")
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .cardBackground()
        .accessibilityElement(children: .contain)
    }
}

#Preview("Mood Logged") {
    NavigationStack {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()
            MoodLoggedView(
                loggedMood: LoggedMood(mood: .happy, note: "", tags: [.hopeful, .grateful]),
                onMoodLogged: { _ in }
            )
            .padding(24)
        }
    }
}
