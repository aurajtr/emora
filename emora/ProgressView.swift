import SwiftUI

struct ProgressView: View {
    @Environment(MoodStore.self) private var moodStore
    @State private var showsNavigationTitle = false

    private var stats: [ProgressStat] {
        [
            ProgressStat(value: "\(moodStore.currentStreak)", title: "Day Streak"),
            ProgressStat(value: "\(moodStore.happyDaysThisMonth)", title: "Happy Days")
        ]
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            ScrollView {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ProgressScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("progressScroll")).minY
                        )
                }
                .frame(height: 0)

                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    pageHeader("Progress")

                    if moodStore.entriesThisMonth.isEmpty {
                        ContentUnavailableView(
                            "No Progress Yet",
                            systemImage: "chart.bar.xaxis",
                            description: Text("Log a mood to see this month's trends.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    } else {
                        statGrid
                        frequentMoodCard
                        distributionCard
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, AppSpacing.screenVertical)
            }
            .coordinateSpace(name: "progressScroll")
            .onPreferenceChange(ProgressScrollOffsetPreferenceKey.self) { offset in
                showsNavigationTitle = offset < -16
            }
        }
        .navigationTitle(showsNavigationTitle ? "Progress" : "")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pageHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(.largeTitle, design: .default, weight: .bold))
            .foregroundStyle(AppColor.textPrimary)
            .accessibilityAddTraits(.isHeader)
            .padding(.top, 28)
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
                    MoodBar(item: item)
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
}

private struct ProgressScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct MoodBar: View {
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

private struct ProgressStat: Identifiable {
    let id = UUID()
    let value: String
    let title: String
}

#Preview("Progress") {
    ProgressView()
        .environment(MoodStore())
}
