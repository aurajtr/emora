import Foundation
import Observation

@Observable
final class MoodStore {
    private(set) var entries: [MoodHistoryEntry]

    private var calendar: Calendar {
        Calendar.autoupdatingCurrent
    }

    private static let fileURL = URL.documentsDirectory.appending(path: "mood-history.json")

    init(entries: [MoodHistoryEntry]? = nil) {
        let initialEntries = entries ?? Self.loadEntries()
        self.entries = initialEntries.sorted { $0.date > $1.date }
    }

    var totalMoodCount: Int {
        entries.count
    }

    var recentEntries: [MoodHistoryEntry] {
        Array(entries.prefix(5))
    }

    var todayEntry: MoodHistoryEntry? {
        entries.first { calendar.isDateInToday($0.date) }
    }

    var currentStreak: Int {
        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var date = calendar.startOfDay(for: Date.now)
        var streak = 0

        if !entryDates.contains(date), let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
            date = yesterday
        }

        while entryDates.contains(date) {
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else {
                break
            }
            date = previousDate
        }

        return streak
    }

    var happyDaysThisMonth: Int {
        entriesThisMonth.filter { $0.mood == .happy }.count
    }

    var mostFrequentMoodThisMonth: (mood: Mood, count: Int)? {
        let counts = moodCountsThisMonth
        guard let result = counts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return (result.key, result.value)
    }

    var moodDistributionThisMonth: [MoodDistribution] {
        let total = max(entriesThisMonth.count, 1)
        let counts = moodCountsThisMonth

        return Mood.allCases.map { mood in
            let count = counts[mood, default: 0]
            return MoodDistribution(mood: mood, percentage: Int((Double(count) / Double(total) * 100).rounded()))
        }
    }

    var entriesThisMonth: [MoodHistoryEntry] {
        entries(inSameMonthAs: Date.now)
    }

    func saveToday(_ loggedMood: LoggedMood) {
        let now = Date.now

        if let index = entries.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            entries[index].mood = loggedMood.mood
            entries[index].note = loggedMood.note
            entries[index].tags = loggedMood.tags
            entries[index].date = now
        } else {
            entries.insert(
                MoodHistoryEntry(
                    mood: loggedMood.mood,
                    note: loggedMood.note,
                    date: now,
                    tags: loggedMood.tags
                ),
                at: 0
            )
        }

        entries.sort { $0.date > $1.date }
        persistEntries()
    }

    func delete(_ entry: MoodHistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        persistEntries()
    }

    func entry(on date: Date, calendar: Calendar = .autoupdatingCurrent) -> MoodHistoryEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func entries(inSameMonthAs date: Date, calendar: Calendar = .autoupdatingCurrent) -> [MoodHistoryEntry] {
        entries.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
    }

    private var moodCountsThisMonth: [Mood: Int] {
        Dictionary(grouping: entriesThisMonth, by: \.mood).mapValues(\.count)
    }

    private func persistEntries() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entries)
            try data.write(to: Self.fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save mood history: \(error.localizedDescription)")
        }
    }

    private static func loadEntries() -> [MoodHistoryEntry] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([MoodHistoryEntry].self, from: data)
        } catch {
            return []
        }
    }
}

struct MoodDistribution: Identifiable, Hashable {
    var id: Mood { mood }
    let mood: Mood
    let percentage: Int
}
