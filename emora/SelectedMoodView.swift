import SwiftUI

struct SelectedMoodView: View {
    @Binding var selectedMood: Mood?
    let onMoodLogged: (LoggedMood) -> Void

    init(selectedMood: Binding<Mood?>, onMoodLogged: @escaping (LoggedMood) -> Void = { _ in }) {
        _selectedMood = selectedMood
        self.onMoodLogged = onMoodLogged
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.group) {
            Text("How are you feeling today?")
                .pageTitleStyle()

            MoodPicker(selectedMood: $selectedMood)

            NavigationLink {
                FillMoodView(initialMood: selectedMood ?? .happy, onSave: onMoodLogged)
            } label: {
                HStack(spacing: 8) {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .font(.system(.body, design: .default, weight: .semibold))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .tint(AppColor.accent)
            .disabled(selectedMood == nil)
            .accessibilityLabel("Continue")
            .accessibilityHint(selectedMood == nil ? "Select a mood first" : "Opens the mood note screen")
        }
    }
}

#Preview("Selected Mood") {
    NavigationStack {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()
            SelectedMoodView(selectedMood: .constant(.happy))
                .padding(24)
        }
    }
}
