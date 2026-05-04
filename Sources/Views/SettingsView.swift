import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var dataStore: DataStore

    @AppStorage("videoQuality") private var videoQuality: Int = 0  // 0 = 720p, 1 = 1080p
    @AppStorage("repSensitivity") private var repSensitivity: Double = 50
    @AppStorage("useFrontCamera") private var useFrontCamera: Bool = false

    @State private var showClearCacheConfirmation = false
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // App Info
                Section {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "2026.03.28")
                } header: {
                    Text("About")
                }

                // Exercise Library
                Section {
                    ForEach(ExerciseType.allCases) { exercise in
                        HStack(spacing: 12) {
                            Image(systemName: exercise.iconName)
                                .foregroundColor(.forgeAmber)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.displayName)
                                    .fontWeight(.semibold)
                                Text(exercise.description)
                                    .font(.caption)
                                    .foregroundColor(.forgeMediumGray)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Exercise Library")
                }

                // Recording
                Section {
                    Picker("Video Quality", selection: $videoQuality) {
                        Text("720p").tag(0)
                        Text("1080p").tag(1)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Recording")
                }

                // Rep Counter Sensitivity
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Sensitivity")
                            Spacer()
                            Text("\(Int(repSensitivity))%")
                                .foregroundColor(.forgeMediumGray)
                                .font(.system(.body, design: .monospaced))
                        }

                        Slider(value: $repSensitivity, in: 0...100, step: 5)
                            .tint(.forgeAmber)

                        Text("Higher sensitivity detects reps faster but may trigger on partial movements.")
                            .font(.caption)
                            .foregroundColor(.forgeMediumGray)
                    }
                } header: {
                    Text("Rep Counter")
                }

                // Camera
                Section {
                    Toggle("Use Front Camera", isOn: $useFrontCamera)
                        .tint(.forgeAmber)
                } header: {
                    Text("Camera")
                }

                // Privacy & Legal
                Section {
                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    NavigationLink(destination: TermsView()) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }

                    LabeledContent {
                        Text("Local Only")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.formGreen)
                    } label: {
                        Label("Data Storage", systemImage: "lock.shield")
                    }
                } header: {
                    Text("Privacy & Legal")
                }

                // Danger Zone
                Section {
                    Button {
                        showClearCacheConfirmation = true
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.orange)
                    }

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset All Data", systemImage: "exclamationmark.triangle")
                    }
                } header: {
                    Text("Danger Zone")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.forgeBlack)
            .navigationTitle("Settings")

            .confirmationDialog("Clear Cache?", isPresented: $showClearCacheConfirmation, titleVisibility: .visible) {
                Button("Clear Cache", role: .destructive) {
                    // Clear temporary caches
                }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Reset All Data?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    dataStore.deleteAllSessions()
                    videoQuality = 0
                    repSensitivity = 50
                    useFrontCamera = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all sessions and reset settings to defaults. This cannot be undone.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Privacy View

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Last Updated: March 28, 2026")
                    .font(.caption)
                    .foregroundColor(.forgeMediumGray)

                Group {
                    PolicySection(title: "1. Data Collection") {
                        "Foundry Form collects pose data from your device camera. This data is processed entirely on your device and never sent to external servers."
                    }
                    PolicySection(title: "2. Local Processing") {
                        "All pose detection, angle calculations, and form analysis happen locally on your iPhone or iPad. No video frames or pose data leave your device."
                    }
                    PolicySection(title: "3. Session Storage") {
                        "Your workout sessions are stored on your device in the local file system. They are not synchronized with iCloud or any cloud service by default."
                    }
                    PolicySection(title: "4. Camera Permissions") {
                        "Foundry Form requires camera access to function. You can revoke this permission at any time in Settings > Privacy > Camera."
                    }
                    PolicySection(title: "5. Data Deletion") {
                        "You can delete individual sessions or all sessions at any time using the History view or Settings."
                    }
                    PolicySection(title: "6. No Tracking") {
                        "We do not track your usage, location, or collect any personal data. No ads, no analytics, no telemetry."
                    }
                }

                Spacer()
            }
            .padding(16)
        }
        .background(Color.forgeBlack)
        .navigationTitle("Privacy Policy")
    }
}

// MARK: - Terms View

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Last Updated: March 28, 2026")
                    .font(.caption)
                    .foregroundColor(.forgeMediumGray)

                Group {
                    PolicySection(title: "1. License Grant") {
                        "Subject to these terms, we grant you a limited, non-exclusive, non-transferable license to use Foundry Form for personal, non-commercial purposes."
                    }
                    PolicySection(title: "2. Acceptable Use") {
                        "You agree not to: (a) reverse engineer or modify the app, (b) use it for commercial purposes without permission, (c) interfere with its operation."
                    }
                    PolicySection(title: "3. Disclaimer of Warranties") {
                        "Foundry Form is provided 'as-is' without warranties. We do not guarantee specific results or liability for fitness-related injury. Always consult a professional trainer or physician."
                    }
                    PolicySection(title: "4. Limitation of Liability") {
                        "In no event shall we be liable for any damages arising from your use of the app, including personal injury or loss of data."
                    }
                    PolicySection(title: "5. Governing Law") {
                        "These terms are governed by applicable law in the jurisdiction where Foundry is based."
                    }
                }

                Spacer()
            }
            .padding(16)
        }
        .background(Color.forgeBlack)
        .navigationTitle("Terms of Service")
    }
}

// MARK: - Policy Section Helper

struct PolicySection: View {
    let title: String
    let content: String

    init(title: String, content: () -> String) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.forgeAmber)
            Text(content)
                .font(.body)
                .foregroundColor(.white)
                .lineSpacing(4)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(DataStore.shared)
}
