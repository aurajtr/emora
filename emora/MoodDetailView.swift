import SwiftUI

struct MoodDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let loggedMood: LoggedMood
    let note: String
    let onMoodLogged: (LoggedMood) -> Void
    let onDelete: () -> Void

    init(
        loggedMood: LoggedMood,
        note: String? = nil,
        onMoodLogged: @escaping (LoggedMood) -> Void = { _ in },
        onDelete: @escaping () -> Void = {}
    ) {
        self.loggedMood = loggedMood
        self.note = note ?? loggedMood.note
        self.onMoodLogged = onMoodLogged
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.group) {
                    summaryCard
                    if hasNote {
                        noteCard
                    }
                    deleteButton
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, AppSpacing.screenVertical)
            }
        }
        .navigationTitle("Mood Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private var summaryCard: some View {
        VStack(spacing: 18) {
            MoodIcon(mood: loggedMood.mood, isSelected: true, size: 104)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text("Mood Logged!")
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

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
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .cardBackground()
        .accessibilityElement(children: .contain)
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Note")
                .font(.system(.headline, design: .default, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            Text(displayNote)
                .secondaryTextStyle()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your note. \(displayNote)")
    }

    private var deleteButton: some View {
        Button {
            onDelete()
            dismiss()
        } label: {
            Label("Delete", systemImage: "trash")
                .font(.system(.body, design: .default, weight: .semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .controlSize(.large)
        .tint(AppColor.destructive)
        .accessibilityHint("Deletes this mood entry")
    }

    private var displayNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasNote: Bool {
        !displayNote.isEmpty
    }
}

#Preview("Mood Details") {
    NavigationStack {
        MoodDetailView(
            loggedMood: LoggedMood(mood: .happy, note: "Great Dinner with family, laughed a lot", tags: [.hopeful, .grateful])
        )
    }
}
