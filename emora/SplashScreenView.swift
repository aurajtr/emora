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

    private let splashGradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color(hex: "F0B8C8", darkHex: "1B1217"), location: 0),
            Gradient.Stop(color: Color(hex: "F8D4DE", darkHex: "2A1821"), location: 0.34),
            Gradient.Stop(color: Color(hex: "FFF4F8", darkHex: "3A2430"), location: 0.68),
            Gradient.Stop(color: Color(hex: "F8C7D6", darkHex: "4A2A38"), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            splashGradient
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

#Preview("Splash Screen Light") {
    SplashScreenView()
        .preferredColorScheme(.light)
}

#Preview("Splash Screen Dark") {
    SplashScreenView()
        .preferredColorScheme(.dark)
}

#Preview("Root") {
    RootView()
}
