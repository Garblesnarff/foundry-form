# Foundry Form — Development Roadmap

## Phase 1: Foundation (Weeks 1–4)

### Core Infrastructure
- [ ] **1.1** Project setup (Xcode, Git, SwiftUI app structure)
  - Create xcodeproj with iOS 16+ target
  - Add Info.plist with camera + microphone usage descriptions
  - Configure Privacy Manifest (App Privacy Guidelines)
  - Owner: Full-stack

- [ ] **1.2** Camera + AVFoundation integration
  - `CameraManager`: Wraps AVCaptureSession for 30fps capture
  - Request camera permission with graceful fallback
  - Handle session interruptions (phone call, etc.)
  - Owner: Views

- [ ] **1.3** Vision Framework pose detection
  - `PoseDetector`: Wraps VNDetectHumanBodyPoseRequest
  - Extract 19 landmarks, normalize to camera space (0–1)
  - Frame-by-frame processing loop
  - Error handling for poor lighting, occlusion
  - Owner: Tracking

- [ ] **1.4** Data models
  - `Exercise.swift`: ExerciseType enum + reference angles
  - `PoseData.swift`: Codable struct for 19 landmarks
  - `Session.swift`: SwiftData model for session history
  - Owner: Models

- [ ] **1.5** SwiftData setup
  - `DataStore.swift`: CRUD operations for sessions
  - Initialize database schema on app launch
  - Migration strategy for future versions
  - Owner: Persistence

### Phase 1 Testing
- [ ] Unit test: `PoseDetectorTests` (mock VNRequest)
- [ ] Integration test: Camera → PoseDetector → DataStore flow
- [ ] Device test: Real iPhone with camera

### Phase 1 Deliverables
- Working camera feed with pose skeleton overlay
- 19 joints rendered as circles + lines on top of camera
- Ability to record pose data to local database
- Privacy manifest complete

---

## Phase 2: Form Analysis (Weeks 5–8)

### Angle Calculation
- [ ] **2.1** `AngleCalculator.swift`
  - Function: `calculateAngle(point1, vertex, point2) -> Float` (in degrees)
  - Use atan2 to get angle between two vectors
  - Test with hardcoded points
  - Owner: Tracking

- [ ] **2.2** Joint angle extraction per exercise
  - Squat: knee angle, hip angle, ankle angle
  - Deadlift: knee angle, hip angle, back angle (shoulder-hip-ankle)
  - Bicep curl: elbow angle, shoulder angle
  - Push-up: elbow angle, wrist angle, hip drop
  - Plank: elbow angle, hip alignment, back angle
  - Golf swing: wrist angle, shoulder rotation, knee angle
  - Store reference angles in `Exercise.swift`
  - Owner: Tracking

### Form Scoring
- [ ] **2.3** `FormAnalyzer.swift`
  - Compare user angles to reference angles
  - Calculate mean absolute error per joint
  - Normalize to 0–100% form score
  - Update every 5 frames (150ms)
  - Owner: Tracking

- [ ] **2.4** Color feedback system
  - Green: 80–100% form (good)
  - Yellow: 60–79% form (acceptable)
  - Red: 0–59% form (needs correction)
  - Update skeleton overlay color per frame
  - Owner: Views

### Rep Counting (Baseline)
- [ ] **2.5** `RepCounter.swift`
  - Algorithm: Detect angle crossing thresholds
  - Example: Bicep curl = count when elbow angle crosses 40° and 160°
  - State machine: (1) waiting for top, (2) waiting for bottom, (3) count
  - Initialize thresholds per exercise
  - Owner: Tracking

### Phase 2 Testing
- [ ] Unit test: `AngleCalculatorTests` (hardcoded landmarks)
- [ ] Unit test: `FormAnalyzerTests` (synthetic poses)
- [ ] Unit test: `RepCounterTests` (simulated angle sequences)
- [ ] Device test: Real-time form scoring on iPhone

### Phase 2 Deliverables
- Form score displayed on screen (0–100%)
- Skeleton color changes based on form quality
- Rep counter increments for squats/curls
- Initial exercise library (6 exercises)

---

## Phase 3: Recording & Playback (Weeks 9–12)

### Session Recording
- [ ] **3.1** `SessionRecorder.swift`
  - Capture video frames + pose landmarks at 30fps
  - Store frame timestamps
  - Write video using AVAssetWriter
  - Save to Documents folder + reference in SwiftData
  - Owner: Views

- [ ] **3.2** Video export
  - Encode recorded frames as H.264 MP4
  - Overlay skeleton onto video
  - Add text labels (rep count, form score, time)
  - Owner: Views

### Session Playback
- [ ] **3.3** `SessionPlayerView.swift`
  - Display recorded video with skeleton overlay
  - Scrubber for frame-by-frame review
  - Playback speed control (1x, 0.5x, 0.25x)
  - Show frame metadata (rep #, form score, timestamp)
  - Owner: Views

- [ ] **3.4** History view
  - `HistoryView.swift`: List all sessions
  - Filter by exercise, date range, form score
  - Tap to open playback
  - Delete session option
  - Owner: Views

### Slow-Motion Analysis
- [ ] **3.5** Slow-motion export
  - Re-render recorded session at 0.5x speed (60fps playback)
  - Export as separate MP4 for sharing
  - Owner: Views

### Phase 3 Testing
- [ ] Integration test: Record → Playback flow
- [ ] Device test: 5+ minute recording (memory stability)
- [ ] Video validation: Check MP4 integrity

### Phase 3 Deliverables
- Record live session with video + pose data
- Playback with skeleton overlay
- Frame-by-frame scrubber
- Export as MP4
- History browser with filtering

---

## Phase 4: Analytics & Refinement (Weeks 13–14)

### Statistics & Tracking
- [ ] **4.1** `StatsView.swift`
  - Display per-exercise stats:
    - Total reps logged
    - Average form score
    - Personal best (max reps in single session)
    - Trend chart (form score over time)
  - Owner: Views

- [ ] **4.2** Progress dashboard
  - Weekly/monthly summary
  - Trending exercises (most logged)
  - Form improvement over time
  - Owner: Views

### Settings
- [ ] **4.3** `SettingsView.swift`
  - Enable/disable exercises
  - Adjust rep counter sensitivity
  - Video export quality (720p/1080p)
  - Storage management (cache size, delete old sessions)
  - Owner: Views

### Polish
- [ ] **4.4** Performance optimization
  - Profile FPS, memory usage
  - Optimize angle calculation (vectorize if needed)
  - Reduce latency in real-time pipeline
  - Owner: Full-stack

- [ ] **4.5** UI refinement
  - Align all views to Foundry design system
  - Dark forge aesthetic throughout
  - Amber accent colors for CTAs
  - Typography: SF Pro for body, SF Mono for numbers
  - Owner: Views

### Phase 4 Testing
- [ ] UI test: Navigation through all screens
- [ ] Performance test: 30-minute recording, no lag
- [ ] Regression test: All Phase 1–3 features still work

### Phase 4 Deliverables
- Complete statistics dashboard
- Settings panel
- Polished, consistent UI
- Performance benchmarks <100ms frame time

---

## Phase 5: App Store Launch (Week 15)

### Submission Preparation
- [ ] **5.1** App Store metadata
  - Write compelling app description
  - Create marketing screenshots (5 of them)
  - Record demo video (30 seconds)
  - Choose keywords for discovery
  - Owner: Full-stack

- [ ] **5.2** Privacy & compliance
  - Complete Privacy Manifest (camera, no tracking)
  - Verify GDPR/CCPA compliance
  - Review Apple's App Store Review Guidelines
  - Test on all supported devices
  - Owner: Full-stack

- [ ] **5.3** Testing suite
  - Regression test all features
  - Test on iPhone 15 Pro, iPad Air 5, iPad Pro 12.9
  - Verify accessibility (VoiceOver, text sizing)
  - Check battery usage
  - Owner: Full-stack

- [ ] **5.4** Build for release
  - Version 1.0.0
  - Code sign with distribution certificate
  - Create App Store build
  - Owner: Full-stack

### Launch
- [ ] **5.5** Submit to App Store
  - Complete TestFlight beta testing (100+ beta testers)
  - Resolve any feedback
  - Submit for review
  - Owner: Full-stack

- [ ] **5.6** Marketing rollout
  - Launch TikTok with demo clips
  - Reach out to fitness influencers
  - Post on Reddit, Twitter, YouTube
  - Owner: Marketing (external)

### Phase 5 Deliverables
- App approved and live on App Store
- 500K+ downloads in first month (goal)
- Zero critical bugs reported
- Average rating ≥3.5 stars

---

## Phase 6: Post-Launch Stabilization (Weeks 16–20)

### Bug Fixes & Performance
- [ ] Monitor crash reports, fix top issues
- [ ] Optimize for older devices (iPhone 12, iPad 7th gen)
- [ ] Improve form scoring accuracy based on user feedback
- [ ] Adjust rep counter thresholds per exercise
- Owner: Full-stack

### V1.1 Planning
- [ ] Implement user feedback features (higher priority first)
- [ ] Design multi-sport profiles (yoga, dance, swimming)
- [ ] Plan benchmark comparison feature
- Owner: Product

---

## Backlog (Post-V1)

### V1.1 Features
- [ ] Yoga profile (downward dog, warrior pose, etc.)
- [ ] Dance profile (basic moves, ballet, hip-hop)
- [ ] Swimming profile (stroke form analysis)
- [ ] Pro-athlete benchmark videos (opt-in)
- [ ] AR guidance overlay (side-by-side ideal vs actual)
- [ ] HealthKit integration (export reps, duration)
- [ ] iCloud backup (optional, encrypted)

### V2 Features
- [ ] Apple Watch support (haptic feedback for form errors)
- [ ] Custom exercise builder (users define their own form profile)
- [ ] SharePlay (share live feed with coach/trainer)
- [ ] Social leaderboards (opt-in, privacy-respecting)
- [ ] AI coaching tips ("Your right knee is caving inward — try thinking 'spread the floor'")
- [ ] Coaching tier ($9.99/mo) with personalized feedback

### Future
- [ ] Android port (Kotlin, MediaPipe)
- [ ] Web dashboard (view history, export analytics)
- [ ] API for fitness apps (integrate into MyFitnessPal, Strava, etc.)
- [ ] Hardware partnerships (gym equipment tracking)

---

## Task Assignment Guidelines

### Pose/Tracking Agent (Sections 1.3, 1.4, 2.1–2.5, 4.4)
- Responsible for: PoseDetector, AngleCalculator, FormAnalyzer, RepCounter
- Must test with synthetic pose data first
- Must document joint angle references in POSE_REFERENCE.md

### Views Agent (Sections 1.2, 1.5, 3–4, 5)
- Responsible for: All `.swift` files in `Sources/Views/`
- Must follow Foundry design system (dark forge, amber accents)
- Must handle camera permissions gracefully

### Full-Stack (Sections 1.1, 4.5, 5)
- Owns project setup, Xcode config, App Store submission
- Integrates Tracking and Views layers
- Runs end-to-end tests before phases complete

---

## Definition of Done (per Phase)

### Code
- [ ] All TODOs resolved
- [ ] No compiler warnings
- [ ] Unit tests pass (>80% coverage)
- [ ] Device tests pass on real hardware

### Documentation
- [ ] Commit messages clear and conventional
- [ ] README updated if needed
- [ ] Code comments for complex logic
- [ ] POSE_REFERENCE.md updated if angles change

### Quality
- [ ] Performance profiled (no 30fps drops)
- [ ] Memory stable (no leaks)
- [ ] Accessibility tested (VoiceOver, text sizing)
- [ ] Privacy vetted (no unexpected data access)
