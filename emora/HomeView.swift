import SwiftUI

struct HomeView: View {
    @Environment(MoodStore.self) private var moodStore
    @State private var selectedMood: Mood?

    init(initialSelectedMood: Mood? = nil) {
        _selectedMood = State(initialValue: initialSelectedMood)
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    ProfileHeaderView()

                    if let todayEntry = moodStore.todayEntry {
                        MoodLoggedView(
                            loggedMood: todayEntry.loggedMood,
                            onMoodLogged: { updatedLog in
                                moodStore.saveToday(updatedLog)
                                selectedMood = updatedLog.mood
                            },
                            onDelete: {
                                moodStore.delete(todayEntry)
                                selectedMood = nil
                            }
                        )
                    } else {
                        SelectedMoodView(selectedMood: $selectedMood) { newLog in
                            moodStore.saveToday(newLog)
                            selectedMood = newLog.mood
                        }
                    }

                    recentMoodSection
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, AppSpacing.screenVertical)
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var recentMoodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Moods")
                .sectionTitleStyle()

            if moodStore.recentEntries.isEmpty {
                Text("No mood recorded yet")
                    .secondaryTextStyle()
                    .padding(.vertical, 4)
            } else {
                ForEach(moodStore.recentEntries) { entry in
                    MoodEntryCard(entry: entry)
                }
            }
        }
    }
}

#Preview("Home") {
    NavigationStack {
        HomeView()
            .environment(MoodStore())
    }
}

#Preview("Home Selected") {
    NavigationStack {
        HomeView(initialSelectedMood: .happy)
            .environment(MoodStore())
    }
}
