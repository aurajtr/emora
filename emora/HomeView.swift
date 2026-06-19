import SwiftUI

struct HomeView: View {
    @Environment(MoodStore.self) private var moodStore
    @State private var selectedMood: Mood?
    @State private var showsNavigationTitle = false

    private var stats: [SummaryProgressStat] {
        [
            SummaryProgressStat(value: "\(moodStore.currentStreak)", title: "Day Streak"),
            SummaryProgressStat(value: "\(moodStore.happyDaysThisMonth)", title: "Happy Days")
        ]
    }

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

                todayMoodSection
                progressSection
                recentMoodSection
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, 0)
            .padding(.bottom, AppSpacing.screenVertical)
        }
        .coordinateSpace(name: "homeScroll")
        .background(AppColor.backgroundGradient.ignoresSafeArea())
        .scrollResponsiveNavigationTitle("Summary", isVisible: showsNavigationTitle)
        .onPreferenceChange(HomeScrollOffsetPreferenceKey.self) { offset in
            showsNavigationTitle = offset < -18
        }
    }

    private var homeHeader: some View {
        ZStack(alignment: .trailing) {
            Text("Summary")
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

    private var todayMoodSection: some View {
        Group {
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
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .sectionTitleStyle()

            if moodStore.entriesThisMonth.isEmpty {
                ContentUnavailableView(
                    "No Progress Yet",
                    systemImage: "chart.bar.xaxis",
                    description: Text("Log a mood to see this month's trends.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else {
                VStack(spacing: 12) {
                    statGrid
                    frequentMoodCard
                    distributionCard
                }
            }
        }
    }

    private var statGrid: some View {
        HStack(spacing: 12) {
            ForEach(stats) { stat in
                VStack(spacing: 0) {
                    Text(stat.value)
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundStyle(AppColor.accent)
                        .minimumScaleFactor(0.8)

                    Text(stat.title)
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .padding(.top, 8)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .frame(height: 76)
                .background(AppColor.statSurface, in: RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(stat.value) \(stat.title)")
            }
        }
    }

    private var frequentMoodCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Frequent Mood")
                .font(.system(.headline, design: .default, weight: .semibold))
                .foregroundStyle(AppColor.textSecondary)

            if let frequentMood = moodStore.mostFrequentMoodThisMonth {
                HStack(spacing: 10) {
                    Circle()
                        .fill(frequentMood.mood.fill)
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)

                    Text("\(frequentMood.mood.name) - \(frequentMood.count) \(frequentMood.count == 1 ? "Day" : "Days")")
                        .font(.system(.title3, design: .default, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary)
                }
            } else {
                Text("No mood records this month")
                    .secondaryTextStyle()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 88)
        .cardBackground()
        .accessibilityElement(children: .combine)
    }

    private var distributionCard: some View {
        VStack(alignment: .leading, spacing: 36) {
            Text("Mood Distribution This Month")
                .font(.system(.headline, design: .default, weight: .semibold))
                .foregroundStyle(AppColor.textSecondary)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(moodStore.moodDistributionThisMonth) { item in
                    SummaryMoodBar(item: item)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150, alignment: .bottom)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
        .accessibilityElement(children: .contain)
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

private struct SummaryMoodBar: View {
    let item: MoodDistribution

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(AppColor.surface.opacity(0.7))
                    .frame(width: 38, height: 104)

                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(item.mood.fill)
                    .frame(width: 38, height: barHeight)
                    .opacity(item.percentage == 0 ? 0.35 : 1)
            }
            .frame(height: 104, alignment: .bottom)

            MoodIcon(mood: item.mood, isSelected: false, size: 30)
                .opacity(item.percentage == 0 ? 0.55 : 1)

            Text("\(item.percentage)%")
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.mood.name), \(item.percentage) percent")
    }

    private var barHeight: CGFloat {
        guard item.percentage > 0 else { return 0 }
        return max(CGFloat(item.percentage) / 100 * 104, 10)
    }
}

private struct SummaryProgressStat: Identifiable {
    let id = UUID()
    let value: String
    let title: String
}

private struct HomeScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview("Summary") {
    NavigationStack {
        HomeView()
            .environment(MoodStore())
    }
}

#Preview("Summary Selected") {
    NavigationStack {
        HomeView(initialSelectedMood: .happy)
            .environment(MoodStore())
    }
}
