import SwiftUI

struct RootView: View {
    @State private var showsSplash = true

    var body: some View {
        ZStack {
            ContentView()
                .opacity(showsSplash ? 0 : 1)

            if showsSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeInOut(duration: 0.35)) {
                showsSplash = false
            }
        }
    }
}

struct SplashScreenView: View {
    @State private var wordmarkScale = 0.96
    @State private var wordmarkOpacity = 0.0

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            Text("Emora")
                .font(.system(size: 62, weight: .light, design: .default))
                .foregroundStyle(Color(hex: "4B4246", darkHex: "F5EEF1"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .scaleEffect(wordmarkScale)
                .opacity(wordmarkOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                wordmarkScale = 1
                wordmarkOpacity = 1
            }
        }
    }
}

#Preview("Splash Screen") {
    SplashScreenView()
}

#Preview("Root") {
    RootView()
}
