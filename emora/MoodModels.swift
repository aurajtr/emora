import SwiftUI

enum Mood: String, CaseIterable, Identifiable, Hashable {
    case happy
    case calm
    case sad
    case angry
    case stressed

    var id: String { rawValue }

    var name: String {
        switch self {
        case .happy: "Happy"
        case .calm: "Calm"
        case .sad: "Sad"
        case .angry: "Angry"
        case .stressed: "Stressed"
        }
    }

    var assetName: String {
        switch self {
        case .happy: "happy"
        case .calm: "calm"
        case .sad: "sad"
        case .angry: "angry"
        case .stressed: "exhausted"
        }
    }

    var fill: Color {
        switch self {
        case .happy: Color(hex: "F5C9A0")
        case .calm: Color(hex: "C9DBA8")
        case .sad: Color(hex: "AFC9E8")
        case .angry: Color(hex: "E8A8B9")
        case .stressed: Color(hex: "C9BFE3")
        }
    }

    var ring: Color {
        switch self {
        case .happy: Color(hex: "C97A33")
        case .calm: Color(hex: "6E9342")
        case .sad: Color(hex: "4B79B8")
        case .angry: Color(hex: "B8456A")
        case .stressed: Color(hex: "6F5DA8")
        }
    }
}

struct LoggedMood: Hashable {
    let mood: Mood
    let note: String
    let tags: [MoodTag]
}

struct MoodHistoryEntry: Identifiable, Hashable {
    let id: UUID
    var mood: Mood
    var note: String
    var date: Date
    var tags: [MoodTag]

    init(id: UUID = UUID(), mood: Mood, note: String, date: Date, tags: [MoodTag]) {
        self.id = id
        self.mood = mood
        self.note = note
        self.date = date
        self.tags = tags
    }

    var month: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }

    var day: Int {
        Calendar.autoupdatingCurrent.component(.day, from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter.string(from: date)
    }

    var loggedMood: LoggedMood {
        LoggedMood(mood: mood, note: note, tags: tags)
    }

    static func samples(calendar: Calendar = .autoupdatingCurrent, now: Date = .now) -> [MoodHistoryEntry] {
        let sampleData: [(Mood, String, Int, [MoodTag])] = [
            (.happy, "Great Dinner with family, laughed a lot", -1, [.hopeful, .grateful]),
            (.calm, "Quiet evening reading a good book with matcha", -2, [.sleepy]),
            (.sad, "Missed deadline, felt a bit overwhelmed", -3, [.lonely, .tired]),
            (.stressed, "A stressful day at work made me feel emotionally drained", -4, [.tired, .overwhelmed]),
            (.angry, "Anxious before project presentation", -5, [.anxious]),
            (.stressed, "Anxious before project presentation", -6, [.focused])
        ]

        return sampleData.compactMap { mood, note, dayOffset, tags in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: now) else {
                return nil
            }

            return MoodHistoryEntry(mood: mood, note: note, date: date, tags: tags)
        }
    }
}

enum MoodTag: String, CaseIterable, Identifiable, Hashable {
    case relaxed
    case grateful
    case energized
    case sleepy
    case focused
    case anxious
    case overwhelmed
    case hopeful
    case lonely
    case excited
    case tired
    case peaceful

    var id: String { rawValue }
    var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }
}
