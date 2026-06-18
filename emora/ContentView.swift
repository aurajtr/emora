//
//  ContentView.swift
//  emora
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
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "calendar")
            }

            NavigationStack {
                ProgressView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }
        }
        .tint(AppColor.accent)
        .environment(moodStore)
    }
}

#Preview("Home") {
    ContentView()
}
