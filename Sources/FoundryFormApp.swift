import SwiftUI

@main
struct FoundryFormApp: App {
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var poseDetector = PoseDetector()
    @StateObject private var formAnalyzer = FormAnalyzer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .environmentObject(poseDetector)
                .environmentObject(formAnalyzer)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root Content View (Tab Navigation)

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SessionView()
                .tabItem {
                    Label("Session", systemImage: "video.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(.forgeAmber)
    }
}
