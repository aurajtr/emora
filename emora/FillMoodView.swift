import SwiftUI

struct FillMoodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: Mood
    @State private var note = ""
    @State private var selectedTags: Set<MoodTag> = [.relaxed]

    let onSave: (LoggedMood) -> Void

    init(initialMood: Mood, onSave: @escaping (LoggedMood) -> Void = { _ in }) {
        _selectedMood = State(initialValue: initialMood)
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.group) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How was your mood?")
                            .pageTitleStyle()

                        Text("Add a note about how you're feeling")
                            .secondaryTextStyle()
                    }

                    selectedMoodCard

                    MoodPicker(selectedMood: Binding(
                        get: { selectedMood },
                        set: { selectedMood = $0 ?? selectedMood }
                    ))

                    noteEditor

                    MoodTagSection(selectedTags: $selectedTags)
                        .padding(.bottom, 8)

                    Button {
                        onSave(LoggedMood(
                            mood: selectedMood,
                            note: note,
                            tags: MoodTag.allCases.filter { selectedTags.contains($0) }
                        ))
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(.body, design: .default, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .tint(AppColor.accent)
                    .accessibilityHint("Saves this mood entry")
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, AppSpacing.screenVertical)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private var selectedMoodCard: some View {
        HStack(spacing: 16) {
            MoodIcon(mood: selectedMood, isSelected: true, size: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text(selectedMood.name)
                    .font(.system(.body, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Text("Tap a mood to change")
                    .secondaryTextStyle()
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .cardBackground()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Selected mood, \(selectedMood.name). Tap another mood to change")
    }

    private var noteEditor: some View {
        TextEditor(text: $note)
            .font(.system(.body, design: .default))
            .foregroundStyle(AppColor.textPrimary)
            .scrollContentBackground(.hidden)
            .padding(12)
            .frame(minHeight: 118)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
            .overlay(alignment: .topLeading) {
                if note.isEmpty {
                    Text("What's on your mind right now?")
                        .font(.system(.body, design: .default))
                        .foregroundStyle(AppColor.textTertiary)
                        .padding(.horizontal, 17)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 0.5)
            }
            .accessibilityLabel("Mood note")
            .accessibilityValue(note.isEmpty ? "Empty" : note)
            .accessibilityHint("Write what is on your mind right now")
    }
}

private struct FlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = makeRows(proposal: proposal, subviews: subviews)
        return CGSize(
            width: proposal.width ?? rows.map(\.width).max() ?? 0,
            height: rows.last.map { $0.yOffset + $0.height } ?? 0
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(proposal: ProposedViewSize(width: bounds.width, height: proposal.height), subviews: subviews)

        for row in rows {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: bounds.minY + row.yOffset),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + horizontalSpacing
            }
        }
    }

    private func makeRows(proposal: ProposedViewSize, subviews: Subviews) -> [FlowRow] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0
        var yOffset: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = currentItems.isEmpty ? size.width : currentWidth + horizontalSpacing + size.width

            if nextWidth > maxWidth, !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, width: currentWidth, height: currentHeight, yOffset: yOffset))
                yOffset += currentHeight + verticalSpacing
                currentItems = [FlowItem(index: index, size: size)]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(FlowItem(index: index, size: size))
                currentWidth = nextWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, width: currentWidth, height: currentHeight, yOffset: yOffset))
        }

        return rows
    }
}

private struct FlowRow {
    let items: [FlowItem]
    let width: CGFloat
    let height: CGFloat
    let yOffset: CGFloat
}

private struct FlowItem {
    let index: Int
    let size: CGSize
}

struct MoodTagSection: View {
    @Binding var selectedTags: Set<MoodTag>

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            Text("How do you feel right now?")
                .font(.system(.body, design: .default))
                .foregroundStyle(AppColor.textSecondary)
                .accessibilityAddTraits(.isHeader)

            FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(MoodTag.allCases) { tag in
                    Button {
                        toggle(tag)
                    } label: {
                        Text(tag.title)
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(AppColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .frame(minHeight: 34)
                            .background(chipFill(for: tag), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tag.title)
                    .accessibilityValue(selectedTags.contains(tag) ? "Selected" : "Not selected")
                    .accessibilityHint("Toggles this feeling tag")
                }
            }
        }
    }

    private func chipFill(for tag: MoodTag) -> Color {
        selectedTags.contains(tag) ? AppColor.accentSoft : AppColor.chipSurface
    }

    private func toggle(_ tag: MoodTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

#Preview("Fill Mood") {
    NavigationStack {
        FillMoodView(initialMood: .happy)
    }
}
