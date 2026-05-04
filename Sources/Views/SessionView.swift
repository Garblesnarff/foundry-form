import SwiftUI

// MARK: - Session View (Main Camera & Feedback)

struct SessionView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var poseDetector: PoseDetector
    @EnvironmentObject var formAnalyzer: FormAnalyzer

    @State private var selectedExercise: ExerciseType = .squat
    @State private var isRecording = false
    @State private var repCounter: RepCounter?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showExercisePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen camera feed with skeleton overlay
                if poseDetector.cameraPermissionGranted {
                    CameraView(
                        captureSession: poseDetector.captureSession,
                        poseData: poseDetector.currentPose,
                        formScore: formAnalyzer.formScore
                    )
                    .ignoresSafeArea()
                } else {
                    CameraPermissionView()
                }

                // HUD overlays
                VStack(spacing: 0) {
                    // Top bar: exercise badge + feedback
                    topOverlay
                    Spacer()
                    // Bottom: metrics + controls
                    bottomOverlay
                }
            }
            .navigationTitle("Foundry Form")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showExercisePicker = true
                    } label: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.forgeAmber)
                    }
                    .disabled(isRecording)
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView(selectedExercise: $selectedExercise)
            }
            .onAppear {
                repCounter = RepCounterFactory.create(for: selectedExercise)
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    // MARK: - Top Overlay

    private var topOverlay: some View {
        HStack {
            // Exercise name badge
            HStack(spacing: 6) {
                Image(systemName: selectedExercise.iconName)
                    .font(.caption)
                Text(selectedExercise.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.forgeAmber)
            .clipShape(Capsule())

            Spacer()

            // Form feedback text
            if isRecording, !formAnalyzer.formFeedback.isEmpty {
                Text(formAnalyzer.formFeedback)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.forgeBlack.opacity(0.85))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Bottom Overlay

    private var bottomOverlay: some View {
        VStack(spacing: 12) {
            // Real-time metrics
            if isRecording {
                SessionMetricsOverlay(
                    formScore: formAnalyzer.formScore,
                    repCount: repCounter?.repCount ?? 0,
                    elapsedTime: elapsedTime,
                    exerciseType: selectedExercise
                )
            }

            // Start / Stop Recording Button
            Button(action: toggleRecording) {
                HStack(spacing: 8) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                    Text(isRecording ? "End Session" : "Forge Your Form")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isRecording ? Color.formRed : Color.forgeAmber)
                )
            }
            .disabled(!poseDetector.cameraPermissionGranted)
            .accessibilityLabel(isRecording ? "End session" : "Start session")
            .accessibilityHint(isRecording
                ? "Stops recording and saves your workout"
                : "Starts analyzing your \(selectedExercise.displayName) form")

            // Error message
            if let error = poseDetector.detectionError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.formRed)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.forgeBlack.opacity(0), Color.forgeBlack.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Recording Control

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        dataStore.createSession(exerciseType: selectedExercise)
        repCounter = RepCounterFactory.create(for: selectedExercise)
        formAnalyzer.resetHistory()
        elapsedTime = 0
        startTimer()
    }

    private func stopRecording() {
        isRecording = false
        stopTimer()

        let averageScore = formAnalyzer.averageFormScore()
        let bestScore = formAnalyzer.bestFormScore()
        let reps = repCounter?.repCount ?? 0

        dataStore.endCurrentSession(
            reps: reps,
            averageScore: averageScore,
            peakScore: bestScore
        )
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1

            // Update form analysis every tick
            if let pose = poseDetector.currentPose {
                formAnalyzer.analyzeForm(pose: pose, for: selectedExercise)
                let angle = exercisePrimaryAngle(pose, for: selectedExercise)
                repCounter?.updateWithAngle(angle)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Extract the primary angle used for rep detection from the current pose.
    private func exercisePrimaryAngle(_ pose: PoseData, for exercise: ExerciseType) -> Float {
        switch exercise {
        case .squat:
            return AngleCalculator.extractSquatAngles(from: pose).primaryAngle
        case .deadlift:
            return AngleCalculator.extractDeadliftAngles(from: pose).primaryAngle
        case .bicepCurl:
            return AngleCalculator.extractBicepCurlAngles(from: pose).primaryAngle
        case .pushUp:
            return AngleCalculator.extractPushUpAngles(from: pose).primaryAngle
        case .plank:
            return AngleCalculator.extractPlankAngles(from: pose).primaryAngle
        case .golfSwing:
            return AngleCalculator.extractGolfSwingAngles(from: pose).primaryAngle
        }
    }
}

// MARK: - Session Metrics Overlay

struct SessionMetricsOverlay: View {
    let formScore: Float
    let repCount: Int
    let elapsedTime: TimeInterval
    let exerciseType: ExerciseType

    private var timeString: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Rep Counter (or Hold timer for plank)
            metricColumn(
                label: exerciseType.isRepBased ? "Reps" : "Hold",
                value: exerciseType.isRepBased ? "\(repCount)" : timeString
            )

            Divider()
                .frame(height: 36)
                .background(Color.forgeMediumGray)

            // Form Score
            metricColumn(
                label: "Form",
                value: String(format: "%.0f%%", formScore),
                valueColor: Color.formScoreColor(for: formScore)
            )

            Divider()
                .frame(height: 36)
                .background(Color.forgeMediumGray)

            // Timer
            metricColumn(label: "Time", value: timeString)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.forgeBlack.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session metrics: \(repCount) reps, form score \(Int(formScore)) percent, elapsed \(timeString)")
    }

    private func metricColumn(label: String, value: String, valueColor: Color = .white) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.forgeMediumGray)
            Text(value)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    SessionView()
        .environmentObject(DataStore.shared)
        .environmentObject(PoseDetector())
        .environmentObject(FormAnalyzer())
        .preferredColorScheme(.dark)
}
