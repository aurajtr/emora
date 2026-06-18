import SwiftUI

struct HistoryView: View {
    @Environment(MoodStore.self) private var moodStore
    @State private var selectedMode = HistoryMode.list
    @State private var selectedSort = HistorySort.mostRecent
    @State private var displayedMonth = Date.now
    @State private var selectedDate = Date.now


    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.firstWeekday = 2
        return calendar
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    Picker("History View", selection: $selectedMode) {
                        ForEach(HistoryMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(AppColor.accent)

                    if selectedMode == .list {
                        listContent
                    } else {
                        calendarContent
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 8)
                .padding(.bottom, AppSpacing.screenVertical)
            }
        }
        .navigationTitle("Mood History")
        .navigationBarTitleDisplayMode(.large)
    }

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("All Moods (\(moodStore.totalMoodCount))")
                    .sectionTitleStyle()

                Spacer()

                Menu {
                    Picker("Sort mood history", selection: $selectedSort) {
                        ForEach(HistorySort.allCases) { sort in
                            Label(sort.title, systemImage: sort.systemImage)
                                .tag(sort)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedSort.title)
                        Image(systemName: "chevron.down")
                            .font(.system(.caption2, design: .default, weight: .bold))
                    }
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColor.surface, in: Capsule())
                }
                .accessibilityLabel("Sort mood history")
                .accessibilityValue(selectedSort.title)
            }

            if sortedEntries.isEmpty {
                ContentUnavailableView(
                    "No Moods Yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Your logged moods will appear here.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(sortedEntries) { entry in
                    NavigationLink {
                        MoodDetailView(loggedMood: entry.loggedMood, note: entry.note, onDelete: {
                            moodStore.delete(entry)
                        })
                    } label: {
                        HistoryMoodCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sortedEntries: [MoodHistoryEntry] {
        switch selectedSort {
        case .mostRecent:
            moodStore.entries.sorted { $0.date > $1.date }
        case .oldest:
            moodStore.entries.sorted { $0.date < $1.date }
        case .moodName:
            moodStore.entries.sorted { $0.mood.name < $1.mood.name }
        }
    }

    private var calendarContent: some View {
        VStack(spacing: 12) {
            calendarCard
            if let selectedCalendarEntry {
                NavigationLink {
                    MoodDetailView(loggedMood: selectedCalendarEntry.loggedMood, note: selectedCalendarEntry.note, onDelete: {
                        moodStore.delete(selectedCalendarEntry)
                    })
                } label: {
                    HistoryMoodCard(entry: selectedCalendarEntry)
                }
                .buttonStyle(.plain)
            } else {
                ContentUnavailableView(
                    "No Mood on This Date",
                    systemImage: "calendar",
                    description: Text("Select a date with a mood record to see its details.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
    }

    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    moveMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.textSecondary)
                .accessibilityLabel("Previous month")

                Spacer()

                Text(monthTitle(for: displayedMonth))
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)

                Spacer()

                Button {
                    moveMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.textSecondary)
                .accessibilityLabel("Next month")
            }

            HStack {
                ForEach(CalendarDay.weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: CalendarDay.columns, spacing: 8) {
                ForEach(calendarDays) { day in
                    CalendarMoodDay(
                        day: day,
                        mood: day.isCurrentMonth ? moodStore.entry(on: day.date, calendar: calendar)?.mood : nil,
                        isSelected: calendar.isDate(day.date, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = day.date
                    }
                }
            }
        }
        .padding(18)
        .cardBackground()
    }

    private var calendarDays: [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        let monthStart = monthInterval.start
        let weekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = (weekday - calendar.firstWeekday + 7) % 7
        let visibleDayCount = Int(ceil(Double(leadingDays + dayRange.count) / 7.0)) * 7

        return (0..<visibleDayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - leadingDays, to: monthStart) else {
                return nil
            }

            return CalendarDay(
                date: date,
                value: calendar.component(.day, from: date),
                isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    private var selectedCalendarEntry: MoodHistoryEntry? {
        moodStore.entry(on: selectedDate, calendar: calendar)
    }

    private func moveMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth),
              let monthStart = calendar.dateInterval(of: .month, for: newMonth)?.start else {
            return
        }

        displayedMonth = monthStart
        selectedDate = calendar.isDate(Date.now, equalTo: monthStart, toGranularity: .month) ? Date.now : monthStart
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func monthAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
}

private enum HistorySort: String, CaseIterable, Identifiable {
    case mostRecent
    case oldest
    case moodName

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mostRecent: "Most Recent"
        case .oldest: "Oldest First"
        case .moodName: "Mood Name"
        }
    }

    var systemImage: String {
        switch self {
        case .mostRecent: "arrow.down"
        case .oldest: "arrow.up"
        case .moodName: "textformat.abc"
        }
    }
}

private enum HistoryMode: String, CaseIterable, Identifiable {
    case list
    case calendar

    var id: String { rawValue }

    var title: String {
        switch self {
        case .list: "List View"
        case .calendar: "Calendar View"
        }
    }
}


private struct HistoryMoodCard: View {
    let entry: MoodHistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(entry.month)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                Text("\(entry.day)")
                    .font(.system(.title2, design: .default, weight: .bold))
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(width: 64)
            .frame(minHeight: 78)
            .background(AppColor.accentSoft, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.mood.name)
                    .font(.system(.body, design: .default, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                if !entry.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(entry.note)
                        .secondaryTextStyle()
                        .lineLimit(2)
                }

                HStack(spacing: 6) {
                    ForEach(entry.tags.prefix(2)) { tag in
                        Text(tag.title)
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColor.accentSoft, in: Capsule())
                    }
                }
            }

            Spacer(minLength: 8)

            MoodIcon(mood: entry.mood, isSelected: false, size: 56)
        }
        .padding(14)
        .cardBackground()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.shortDate), \(entry.mood.name). \(entry.note)")
    }
}

private struct CalendarMoodDay: View {
    let day: CalendarDay
    let mood: Mood?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    if let mood {
                        MoodIcon(mood: mood, isSelected: false, size: 24)
                            .opacity(day.isCurrentMonth ? 1 : 0.3)
                    } else {
                        Circle()
                            .fill(AppColor.chipSurface)
                            .frame(width: 24, height: 24)
                            .opacity(day.isCurrentMonth ? 1 : 0.3)
                    }

                    if day.isToday {
                        Circle()
                            .fill(AppColor.accent)
                            .frame(width: 7, height: 7)
                            .offset(x: 2, y: -1)
                    }
                }

                Text("\(day.value)")
                    .font(.system(.caption, design: .default, weight: isSelected || day.isToday ? .bold : .medium))
                    .foregroundStyle(textColor)
                    .frame(width: 30, height: 18)
                    .background {
                        if isSelected {
                            Capsule().fill(AppColor.accent)
                        }
                    }
            }
            .frame(maxWidth: .infinity, minHeight: 46)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.accessibilityDate)
        .accessibilityValue(day.isToday ? "Today, \(mood?.name ?? "No mood")" : mood?.name ?? "No mood")
    }

    private var textColor: Color {
        if isSelected { return .white }
        if day.isCurrentMonth { return AppColor.textSecondary }
        return AppColor.textTertiary
    }
}

private struct CalendarDay: Identifiable {
    let date: Date
    let value: Int
    let isCurrentMonth: Bool
    let isToday: Bool

    var id: Date { date }

    var accessibilityDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    static let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
    static let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
}

#Preview("History") {
    HistoryView()
        .environment(MoodStore())
}
