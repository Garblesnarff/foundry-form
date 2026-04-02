# Foundry Form — On-Device Pose & Motion Coach

Real-time pose estimation and motion analysis on iPhone/iPad. Get instant feedback on your form for fitness, golf, dance, and physical therapy exercises. No internet required—everything runs locally on your device.

## Features

### Current (MVP)
- **Live Pose Detection**: 30fps skeleton overlay on camera feed
- **Form Scoring**: 0–100% match to ideal form for baseline exercises
- **Rep Counting**: Automatic repetition counting for major exercises
- **Exercise Library**: Pre-built form profiles for squats, deadlifts, bicep curls, push-ups, planks, golf swings
- **Session Tracking**: Record and playback workout sessions with timestamps
- **Local History**: All sessions stored on-device; never sent anywhere
- **Slow-Motion Analysis**: Review form in slow-motion from recorded sessions

### Roadmap
- Multi-sport profiles (yoga, dance, swimming)
- Benchmark comparison (compare your form to pro athletes)
- AR guidance overlay (see ideal vs actual joints side-by-side)
- Apple Watch integration
- HealthKit integration (calories, reps, duration)
- Custom exercise builder

## Requirements

- **iOS 16+** or **iPadOS 16+**
- **iPhone/iPad with camera** (iPhone 12+, iPad Pro 3rd gen+, or Apple Silicon iPad)
- **6 GB RAM** minimum (16 GB recommended for smooth video playback)
- Camera permissions enabled

## Installation

### From Source
```bash
git clone https://github.com/foundry-hone/foundry-form.git
cd foundry-form
open FoundryForm.xcodeproj
```

Select your device/simulator and press ⌘R to build and run.

### From App Store
(Coming Q2 2026)

## Usage

1. **Launch** Foundry Form
2. **Select Exercise**: Pick from Squats, Deadlifts, Bicep Curls, Push-Ups, Planks, Golf Swings
3. **Start Recording**: Position yourself in frame, tap "Forge Your Form"
4. **Real-Time Feedback**:
   - Green skeleton = good form
   - Yellow skeleton = form degrading
   - Red skeleton = poor form
   - Rep counter increments with each completed repetition
5. **Review Session**: Tap History to watch playback, analyze slow-motion
6. **Track Progress**: View PR history and strength trends

## Architecture

### Pose Pipeline
```
Camera Frame
  ↓ (30fps)
Vision Framework (VNDetectHumanBodyPoseRequest)
  ↓
19 Joint Landmarks (normalized 0–1)
  ↓ (AngleCalculator)
Joint Angles (degrees)
  ↓ (FormAnalyzer)
Form Score (0–100%)
  ↓ (RepCounter)
Rep Count + Feedback
  ↓
SwiftUI Render + DataStore
```

### Technologies
- **Vision Framework**: Apple's native pose detection (19 joints)
- **AVFoundation**: Real-time camera capture and session recording
- **SwiftData**: Local persistence of sessions and user data
- **SwiftUI**: Modern, reactive UI framework

## Development

### Project Structure
```
Sources/
├── FoundryFormApp.swift       # App entry + SceneDelegate
├── Models/                    # Data structures
├── Tracking/                  # Pose detection + analysis
├── Views/                     # SwiftUI components
├── Persistence/               # SwiftData models
└── Utilities/                 # Helpers (angle math, etc.)

Resources/
├── Info.plist                 # Metadata + privacy keys
└── Assets.xcassets/           # Images, colors, app icon

docs/
├── DESIGN_SYSTEM.md           # Foundry design + iOS rules
├── ARCHITECTURE.md            # Deep-dive: pose pipeline
└── POSE_REFERENCE.md          # Joint angles per exercise
```

### Phases
See **TODO.md** for detailed phase breakdown and task ownership.

### Building
```bash
# Install Xcode 15.0+
# Clone repo
# Open FoundryForm.xcodeproj
# Select iPhone 15 Pro or iPad Air (5th gen)
# ⌘R to build and run
```

### Testing
```bash
# Unit tests
⌘U

# UI tests
⌘U (select UI test target)

# Device test
Connect iPhone/iPad via USB, select device, ⌘R
```

## Privacy & Security

- **No internet**: All processing on-device
- **No data collection**: Sessions never leave your device
- **Camera-only input**: Pose data is extracted from camera, not stored
- **Encrypted storage**: SwiftData uses on-device encryption by default
- **No ads, no tracking**: Free model supported by one-time App Store purchase

## Troubleshooting

### Camera freezes or low fps
- Ensure device has ≥6 GB free RAM
- Close other apps (Maps, Heavy games)
- Restart device
- Update to latest iOS

### Pose detection not working
- Check camera permission: Settings > Privacy > Camera
- Ensure full body is visible in frame
- Adequate lighting (avoid backlit scenes)
- Stand 2–3 meters away from camera

### Rep count inaccurate
- Slow down your movement (for better landmark detection)
- Ensure full range of motion (for angle oscillation detection)
- Check Exercise Reference in docs for expected ROM per exercise

## Contributing

This is a solo project under the Foundry umbrella. Issues and feature requests welcome. See AGENTS.md for development coordination rules.

## License

MIT License. See LICENSE for full text.

## Credits

Built with:
- Apple Vision Framework (pose detection)
- SwiftUI (UI framework)
- SwiftData (persistence)
- Foundry Design System (visual language)

## Contact

- GitHub: [foundry-form](https://github.com/foundry-hone/foundry-form)
- Issues: Use GitHub Issues
- Slack: #foundry-form (when workspace established)
