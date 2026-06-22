//
//  ContentView.swift
//  Emora
//
//  Created by Aura Jatra on 17/06/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var moodStore = MoodStore()

    init() {
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(AppColor.accent)],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(AppColor.textPrimary)],
            for: .selected
        )
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Summary", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "calendar")
            }
        }
        .tint(AppColor.accent)
        .environment(moodStore)
    }
}

#Preview("Home") {
    ContentView()
}
