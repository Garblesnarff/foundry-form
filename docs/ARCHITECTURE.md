# Foundry Form — Architecture Deep-Dive

## System Overview

```
┌─────────────────────────────────────┐
│     SwiftUI User Interface          │
│  (SessionView, HistoryView, etc.)   │
└────────────────┬────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
┌───────▼──────┐  ┌──────▼────────┐
│  PoseDetector│  │ FormAnalyzer  │
│ (Observable) │  │ (Observable)  │
└────────┬─────┘  └──────┬────────┘
         │                │
    ┌────▼────────────────▼────┐
    │   Core Analysis Layer    │
    │ ┌──────────────────────┐ │
    │ │ AngleCalculator      │ │
    │ │ RepCounter           │ │
    │ │ JointAngleExtractor  │ │
    │ └──────────────────────┘ │
    └────┬──────────────────────┘
         │
    ┌────▼─────────────────┐
    │  Local Storage Layer │
    │ ┌──────────────────┐ │
    │ │  DataStore       │ │
    │ │  JSON/FileSystem │ │
    │ └──────────────────┘ │
    └──────────────────────┘
```

## Layer Breakdown

### 1. UI Layer (SwiftUI)
**Responsibility**: Render UI, handle user input, display real-time feedback

**Key Components**:
- `FoundryFormApp.swift` — App entry point, theme setup
- `SessionView.swift` — Live camera + rep counter + form feedback
- `CameraView.swift` — Camera preview with skeleton overlay
- `HistoryView.swift` — Session browser with filtering
- `SettingsView.swift` — Exercise & recording preferences

**Data Flow**:
- Observes: `@EnvironmentObject` for `PoseDetector`, `FormAnalyzer`, `DataStore`
- Updates: Published properties trigger SwiftUI re-renders
- Lifecycle: Managed by SwiftUI view lifecycle

### 2. Detection Layer (Vision Framework)
**Responsibility**: Capture camera frames, run pose detection, extract landmarks

**Key Component**: `PoseDetector.swift`
- Wraps `AVCaptureSession` for 30fps video input
- Implements `AVCaptureVideoDataOutputSampleBufferDelegate` for frame callbacks
- Uses `VNDetectHumanBodyPoseRequest` from Vision framework
- Publishes `currentPose: PoseData` for UI observation
- Handles camera permissions gracefully

**Pose Data Structure**:
```swift
struct PoseData {
    // 19 joints from Vision framework
    let nose: CGPoint
    let leftEye, rightEye, leftEar, rightEar: CGPoint
    let leftShoulder, rightShoulder: CGPoint
    let leftElbow, rightElbow: CGPoint
    let leftWrist, rightWrist: CGPoint
    let leftHip, rightHip: CGPoint
    let leftKnee, rightKnee: CGPoint
    let leftAnkle, rightAnkle: CGPoint
    let timestamp: Date
    let isValid: Bool
}
```

### 3. Analysis Layer (Pose Metrics)
**Responsibility**: Convert landmarks to angles, score form, count reps

**Key Components**:

#### AngleCalculator
- Static functions for joint angle calculation
- Uses vector math: `angle = acos(dotProduct / (mag1 * mag2))`
- Exercise-specific angle extraction:
  - `extractSquatAngles()` → knee, hip angles
  - `extractDeadliftAngles()` → knee, hip, back angles
  - `extractBicepCurlAngles()` → elbow angle, shoulder height
  - `extractPushUpAngles()` → elbow, shoulder, hip alignment
  - `extractPlankAngles()` → elbow, body alignment
  - `extractGolfSwingAngles()` → wrist, shoulder rotation, knee flex

#### FormAnalyzer (Observable)
- Publishes `formScore: Float` (0–100%)
- Publishes `formFeedback: String` ("Great form!", etc.)
- Per-exercise analysis:
  - Compares user angles to reference angles
  - Calculates error: `error = |userAngle - referenceAngle|`
  - Normalizes to score: `score = max(0, (20 - error) / 20) * 100`
  - Maintains history (last 10 frames) for moving average

#### RepCounter (Observable)
- Publishes `repCount: Int`
- State machine:
  - **Waiting**: No motion detected
  - **Descending**: Angle decreasing toward min threshold
  - **Ascending**: Angle increasing back to max threshold (rep counted)
- Exercise-specific thresholds:
  - Squat: knee 70° min, 170° max
  - Curl: elbow 40° min, 170° max
  - Etc. (see `ExerciseReferenceAngles`)

### 4. Persistence Layer
**Responsibility**: Store sessions, track history, enable playback

**Key Component**: `DataStore.swift` (Observable Singleton)
- Manages `sessions: [Session]` array
- Implements JSON serialization to Documents folder
- CRUD operations:
  - `createSession()` → starts recording
  - `endCurrentSession()` → saves to history
  - `deleteSession()` → removes from history
  - `sessionsForExercise()` → filters by type
  - `sessionStats()` → aggregates metrics

**Session Model**:
```swift
struct Session {
    let id: UUID
    let exerciseType: ExerciseType
    let startTime, endTime: Date
    let totalReps: Int
    let averageFormScore: Float
    let peakFormScore: Float
    let videoURL: URL?
}
```

## Data Flow (Real-Time Session)

### Initialization
1. User launches app → `FoundryFormApp` initializes `@StateObject` observables
2. `PoseDetector.setupCamera()` → requests camera permission, starts `AVCaptureSession`
3. Camera preview renders, skeleton overlay ready

### Session Start
1. User taps "Forge Your Form"
2. `SessionView.startRecording()` →
   - `DataStore.createSession(selectedExercise)` → creates Session with startTime
   - `RepCounter` initialized with exercise thresholds
   - `Timer` starts at 0.1s intervals

### Real-Time Loop (every ~33ms at 30fps)
```
Vision Framework (camera frame)
    ↓
PoseDetector.detectPose()
    ↓ (publishes)
currentPose: PoseData
    ↓
SessionView observes → updates skeleton overlay
    ↓
Timer callback (0.1s):
    ├─ FormAnalyzer.analyzeForm(pose, exercise)
    │  └─ Extract angles → Compare to reference → Score (0-100%)
    │     └─ Publishes formScore
    │
    ├─ RepCounter.updateWithAngle()
    │  └─ State machine → increment repCount if threshold crossed
    │     └─ Publishes repCount
    │
    └─ UI renders form score + reps in overlay
```

### Session End
1. User taps "End Session"
2. `SessionView.stopRecording()` →
   - Stop timer
   - Collect metrics: totalReps, averageFormScore, peakFormScore
   - `DataStore.endCurrentSession()` → saves to JSON + UI updates

### Playback (Future)
- Load Session from DataStore
- Render SessionDetailView with stats
- (Video playback: Phase 3)

## Threading Model

### Main Thread (UI)
- All SwiftUI views and updates
- Button taps, navigation
- Drawing skeleton overlay

### Session Queue (`sessionQueue`)
- Camera session start/stop
- AVCaptureSession lifecycle
- Non-blocking

### Detection Queue (`detectionQueue`)
- Vision framework pose detection
- Expensive ML inference
- Delegates back to Main for @Published updates

```swift
detectionQueue.async { [weak self] in
    // Run pose detection (slow, expensive)
    self.detectPose(in: sampleBuffer)

    DispatchQueue.main.async {
        // Update @Published properties (triggers UI re-render)
        self.currentPose = pose
    }
}
```

## Performance Considerations

### Targets
- **Pose Detection**: 30fps (33ms per frame)
- **Form Scoring**: <50ms computation
- **Rep Counting**: <10ms state machine
- **Memory**: <500MB peak
- **Battery**: <5% drain per 30-min session

### Optimizations
1. **Lazy Landmark Detection**:
   - Vision framework detects all 19 joints
   - Only extract angles needed for current exercise
   - Skip unused joints

2. **Score History Window**:
   - Keep last 10 scores, not all history
   - Reduces memory, enables smooth moving average

3. **Frame Skipping** (optional):
   - Process every 2nd–3rd frame if needed
   - Reduces detection frequency, maintains visual feedback

4. **Angle Calculation**:
   - Pre-compute vectors
   - Clamp `acos()` input to avoid domain errors
   - No allocations in hot path

### Debugging
- Enable FPS counter: `Debug > Metal > Color Mis-matched
- Profile with Instruments: Xcode > Product > Profile
- Watch "System Trace" for thread bottlenecks
- Monitor memory with "Allocations" instrument

## Testing Strategy

### Unit Tests
- `AngleCalculatorTests`: Mock pose data, verify angle math
- `RepCounterTests`: Simulate angle sequences, verify state transitions
- `FormAnalyzerTests`: Check scoring logic with hardcoded poses

### Integration Tests
- End-to-end: Camera → Pose → Angles → Form Score → Reps
- Session lifecycle: Create → Record → Save → Load
- Persistence: Save sessions, reload app, verify data intact

### Device Tests
- Real iPhone with camera (Vision limited on simulator)
- Test all 6 exercises with real form variations
- Verify 30fps sustainability over 30+ minute sessions
- Check memory stability (no leaks with long recordings)

## Future Extensibility

### Adding a New Exercise
1. Extend `ExerciseType` enum with new case
2. Add reference angles in `switch` statement
3. Add `extract[ExerciseName]Angles()` in `AngleCalculator`
4. Add `analyze[ExerciseName]()` in `FormAnalyzer`
5. Add UI description and icon

### Adding Video Recording
- Implement `AVAssetWriter` to encode frames to H.264 MP4
- Overlay skeleton during encoding
- Store URL in `Session.videoURL`
- Build `SessionPlayerView` for playback

### Adding Benchmarks
- Store reference pose videos in app bundle
- Load benchmark skeleton, overlay with user skeleton
- Calculate similarity score between two poses
- Display side-by-side in ComparisonView

## Dependency Graph

```
PoseDetector (Vision, AVFoundation)
    ↓
SessionView observes PoseData
    ↓
FormAnalyzer observes PoseData
    ↓
AngleCalculator (no deps)
RepCounter (no deps)
    ↓
SessionView updates UI
    ↓
DataStore persists to FileSystem
```

**Zero external dependencies** (only Apple frameworks):
- Vision (pose detection)
- AVFoundation (camera)
- SwiftUI (UI)
- Combine (reactivity)
- Foundation (JSON, FileSystem)
