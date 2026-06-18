import SwiftUI

struct HomeView: View {
    @Environment(MoodStore.self) private var moodStore
    @State private var selectedMood: Mood?
    @State private var showsNavigationTitle = false

    init(initialSelectedMood: Mood? = nil) {
        _selectedMood = State(initialValue: initialSelectedMood)
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: HomeScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("homeScroll")).minY
                    )
            }
            .frame(height: 0)

            VStack(alignment: .leading, spacing: AppSpacing.section) {
                homeHeader

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
            .padding(.top, 0)
            .padding(.bottom, AppSpacing.screenVertical)
        }
        .coordinateSpace(name: "homeScroll")
        .background(AppColor.backgroundGradient.ignoresSafeArea())
        .scrollResponsiveNavigationTitle("Mood", isVisible: showsNavigationTitle)
        .onPreferenceChange(HomeScrollOffsetPreferenceKey.self) { offset in
            showsNavigationTitle = offset < -18
        }
    }

    private var homeHeader: some View {
        ZStack(alignment: .trailing) {
            Text("Mood")
                .font(.system(.largeTitle, design: .default, weight: .bold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            profileButton
        }
        .frame(maxWidth: .infinity)
    }

    private var profileButton: some View {
        Image("profile")
            .resizable()
            .scaledToFill()
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(AppColor.border, lineWidth: 0.5)
            }
            .accessibilityLabel("Profile")
    }

    private var recentMoodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent Moods")
                    .sectionTitleStyle()

                Spacer()

                if !moodStore.recentEntries.isEmpty {
                    NavigationLink("See All") {
                        HistoryView()
                    }
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
                }
            }

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

private struct HomeScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
