# Foundry Form — On-Device Pose & Motion Coach

## What This Is
Real-time pose estimation and motion analysis using the iPhone/iPad camera. Analyzes body form for fitness, golf swings, dance moves, PT rehab exercises. Think "AI personal trainer that watches your form." For fitness users, coaches, golfers, dancers, physical therapy patients.

## Tech Stack
- **UI**: Swift 5.9 + SwiftUI
- **Pose Estimation**: Apple Vision framework (VNDetectHumanBodyPoseRequest)
- **Camera**: AVFoundation
- **Analysis**: Core ML for pose classification
- **Persistence**: SwiftData (iOS 17+) with fallback to CoreData
- **Target**: iOS 16+ / iPadOS 16+ (iPhone/iPad with camera)

## Architecture
```
┌──────────────────────────────────────────────┐
│          iOS/iPadOS App                      │
│  ┌────────────────────────────────────────┐  │
│  │       SwiftUI Interface                │  │
│  │  [Camera Feed] [Skeleton Overlay]      │  │
│  │  [Rep Counter] [Form Score: 92%]       │  │
│  │  [Exercise Picker] [History]           │  │
│  └──────────────┬─────────────────────────┘  │
│                 │                             │
│  ┌──────────────▼─────────────────────────┐  │
│  │    Vision / Pose Detection Pipeline    │  │
│  │  Camera Frame → Pose Landmarks (19pt)  │  │
│  │  → Joint Angles → Form Classification  │  │
│  └──────────────┬─────────────────────────┘  │
│                 │                             │
│  ┌──────────────▼─────────────────────────┐  │
│  │    Local Storage (SwiftData/CoreData)  │  │
│  │  Session history, PR tracking, stats   │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Design System
Foundry shared design system adapted for SwiftUI on iOS.
- Dark forge aesthetic: charcoal blacks (#141210), amber accents (#E8A849)
- Fonts: SF Pro (system font)
- Forge language: "Forge your form" / "Analyzing form..." / "Form forged." / "RE-FORM"

## Critical Implementation Notes
- Apple's Vision framework VNDetectHumanBodyPoseRequest gives 19 joint points (shoulders, elbows, wrists, hips, knees, ankles, neck, nose, eyes, ears)
- Joint angle calculation: use atan2 on landmark pairs (shoulder-elbow-wrist for bicep curl angle, etc.)
- Form scoring: compare user's joint angles to "ideal" reference angles per exercise
- Rep counting: detect angle oscillation patterns (e.g., elbow angle going from >160° to <40° = one curl rep)
- Must handle: squats, deadlifts, bicep curls, push-ups, planks, golf swings, yoga poses
- Camera preview must run at 30fps minimum with skeleton overlay
- Record sessions for playback with slow-motion analysis
- Keep single-purpose at launch — one sport/activity per focus, expand later

## File Structure
```
Sources/
├── FoundryFormApp.swift
├── Models/
│   ├── Exercise.swift
│   ├── Session.swift
│   └── PoseData.swift
├── Tracking/
│   ├── PoseDetector.swift
│   ├── AngleCalculator.swift
│   ├── RepCounter.swift
│   └── FormAnalyzer.swift
├── Views/
│   ├── CameraView.swift
│   ├── SkeletonOverlay.swift
│   ├── ExercisePickerView.swift
│   ├── SessionView.swift
│   ├── HistoryView.swift
│   └── SettingsView.swift
├── Persistence/
│   └── DataStore.swift
└── Utilities/
    └── AngleUtils.swift

Resources/
├── Info.plist
└── Assets.xcassets/

docs/
├── DESIGN_SYSTEM.md
├── ARCHITECTURE.md
└── POSE_REFERENCE.md
```

## Build & Run
```bash
open FoundryForm.xcodeproj
# Select iPhone/iPad simulator or device
# Build & Run (⌘R)
```

## Legal
- Apple Vision: No additional licensing (system framework).
- Zero external dependencies — 100% offline, camera-only processing.

## Success Criteria
1. Real-time pose detection at 30fps on iPhone 13+
2. Form scoring accuracy ≥85% for baseline exercises
3. Rep counting accuracy ≥90% for controlled movements
4. Session playback with slow-motion analysis
5. App Store submission ready with privacy compliance
