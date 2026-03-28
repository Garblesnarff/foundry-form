# Foundry Form — Product Requirements Document

## Executive Summary

Foundry Form is an on-device AI coach that watches your form in real-time. Upload a video or use the camera, and get instant feedback on whether your squat depth is good, your golf swing is on-plane, or your dance move matches the tutorial. No subscription, no cloud, no ads—just pure local AI running on your iPhone or iPad.

## Problem Statement

1. **Fitness users** struggle to get real-time form feedback without a trainer
2. **Coaches** spend hours analyzing video to spot form errors
3. **Dancers/golfers** want to compare their movement against reference video frame-by-frame
4. **PT patients** can't afford in-person rehab sessions but need form validation
5. **Existing solutions** require cloud upload (privacy risk), subscriptions (cost), or external wearables (complexity)

## Solution

Foundry Form brings professional-grade motion analysis to your pocket. Uses Apple Vision framework to detect 19 body landmarks in real-time, calculates joint angles, scores form against "ideal" reference postures, and counts reps automatically.

### Key Differentiators
- **100% offline**: Nothing leaves your device
- **30fps analysis**: Real-time feedback, not post-hoc
- **Built-in rep counter**: No external gadgets
- **Form scoring**: Percentage match to ideal form
- **Video playback**: Review sessions in slow-motion
- **No subscription**: One-time purchase ($4.99 pro) or free base app

## Target Users

### Primary
- Fitness enthusiasts (gym-goers, home workout fans) — 60%
- Golfers seeking swing analysis — 20%
- Physical therapy patients — 15%
- Dancers/movement coaches — 5%

### Secondary (V2+)
- Yoga instructors
- Swimming coaches
- Rock climbers
- Martial artists

## Feature Set

### MVP (Phase 1–3)
- [x] Real-time pose detection (19 joints)
- [x] Camera feed + skeleton overlay
- [x] Exercise selector (squats, deadlifts, bicep curls, push-ups, planks, golf swings)
- [x] Form scoring (0–100%)
- [x] Rep counting
- [x] Session recording + playback
- [x] Local history database
- [x] Slow-motion review

### V1.1 (Phase 4–5)
- [ ] Multi-sport profiles (yoga, dance, swimming)
- [ ] Benchmark comparison (pro athlete reference video)
- [ ] AR guidance overlay (ideal joints vs actual)
- [ ] HealthKit integration (export reps + duration)
- [ ] Cloud backup (optional, encrypted)

### V2 (Post-launch)
- [ ] Custom exercise builder
- [ ] Apple Watch support (haptic feedback for form errors)
- [ ] SharePlay comparison (share live feed with coach)
- [ ] AI-generated coaching tips
- [ ] Social leaderboards (opt-in, privacy-respecting)

## Business Model

### Pricing
- **Free Tier**: Single sport (squats + deadlifts), limited history (100 sessions)
- **Pro Pack ($4.99 one-time)**: All sports, unlimited history, slow-mo playback
- **Coaching Tier ($9.99/mo future)**: Premium coaching feedback, benchmark videos

### Revenue Projection (Year 1)
- Free downloads: 500K (viral TikTok clips of form analysis)
- Pro conversion: 5% (25K users × $4.99 = $125K)
- CoachKit subscribers (V2): 2% (10K users × $9.99/mo = $1.2M/year)
- **Total Year 1**: ~$200K

## Functional Requirements

### FR1: Live Pose Detection
- Input: Camera frame (30fps minimum)
- Process: Apple Vision VNDetectHumanBodyPoseRequest
- Output: 19 joint landmarks in normalized camera space (0–1)
- Latency: <100ms per frame
- Accuracy: ≥85% joint detection under normal lighting

### FR2: Form Scoring
- Algorithm: Compare user's joint angles to reference angles per exercise
- Formula: `score = (1 - mean_absolute_error / max_error) * 100`
- Output: 0–100% float, updated every 5 frames (~150ms)
- Feedback: Color skeleton (green/yellow/red) based on threshold

### FR3: Rep Counting
- Algorithm: Detect angle oscillation (e.g., elbow going 160° → 40° → 160°)
- Per-exercise thresholds (squat depth >70°, bicep curl ROM >120°)
- Output: Integer rep count, incremented when threshold crossed
- Accuracy: ≥90% for controlled movements

### FR4: Exercise Library
- Base exercises: Squats, deadlifts, bicep curls, push-ups, planks, golf swings
- Per exercise: Ideal joint angles, rep detection thresholds, ROM requirements
- Expandable via config file or Core ML model

### FR5: Session Recording
- Capture video frames + pose landmarks at 30fps
- Store in SwiftData with metadata (exercise, duration, date, form score)
- Playback at 1x/0.5x speed with skeleton overlay
- Export as MP4 with optional sharing

### FR6: Local History
- Store up to N sessions (100 free, unlimited pro)
- Query by exercise, date range, form score range
- Display stats: total reps, PB (personal best), avg form score
- Persistent across app restarts

## Technical Requirements

### TR1: Performance
- Pose detection: 30fps on iPhone 13+
- Form scoring: ≤50ms computation time
- Rep counting: Real-time update (no lag)
- Memory: ≤500 MB peak usage
- Battery: ≤5% drain per 30-minute session

### TR2: Compatibility
- iOS 16+ / iPadOS 16+
- Devices: iPhone 12+, iPad Pro 3rd gen+, or any Apple Silicon iPad
- No external dependencies (Vision, AVFoundation, SwiftData all built-in)

### TR3: Data Privacy
- No cloud transmission by default
- Camera frames deleted after pose extraction (not stored)
- Sessions encrypted at rest on device
- Optional encrypted iCloud backup (v2)
- Compliance: GDPR, CCPA, App Privacy Guidelines

### TR4: Accessibility
- VoiceOver support for controls
- Large text option for rep counter
- Camera preview contrast adjustable
- High contrast mode support

## Non-Functional Requirements

### NF1: Reliability
- App crash rate: <0.5%
- Camera permission handling: Graceful fallback if denied
- Pose detection failure: Skeleton goes gray, rep counter paused

### NF2: Maintainability
- Code modular (separate tracking, analysis, UI layers)
- Unit tests for angle calculations (>85% coverage)
- Clear exercise config format (JSON or plist)

### NF3: Extensibility
- Exercise config system allows new sports without code changes
- Form analyzer pluggable for custom analysis logic
- Rep counter configurable per exercise

## User Stories

### US1: Fitness Enthusiast
> As a gym-goer, I want to see my form score in real-time during squats, so I can adjust my depth and knee position without a trainer.

Acceptance Criteria:
- Camera feed shows skeleton overlay ✓
- Form score updates every 5 frames ✓
- Color changes red if depth <70° ✓
- Rep counter increments automatically ✓

### US2: Golfer
> As a golfer, I want to compare my swing angle to a pro golfer's ideal angle, so I can see where I'm off-plane.

Acceptance Criteria:
- Golf swing profile selectable ✓
- Joint angles for wrists, elbows, shoulders calculated ✓
- Swing plane angle shown as reference ✓
- Slow-mo playback of swing available ✓

### US3: PT Patient
> As a rehabilitation patient, I want to record my exercises daily and track my ROM improvement, so I can show my PT progress without in-person visits.

Acceptance Criteria:
- Session history shows date, exercise, ROM ✓
- Charts display ROM trend over time ✓
- Export option to share with PT ✓

### US4: Dancer
> As a dancer, I want to compare my move frame-by-frame with a reference video, so I can match the choreography exactly.

Acceptance Criteria:
- Reference video loaded ✓
- Frame-by-frame scrubber for both videos ✓
- Overlay mode shows both skeletons ✓
- Syncing feature to lock both to same frame ✓

## Success Metrics

### User Acquisition
- 500K downloads in first 6 months
- 5% app store rating (3.5+ stars)
- Featured in App Store "Health & Fitness" category

### Engagement
- 40% DAU (daily active users)
- 3 sessions per week per user
- 10 min average session duration

### Monetization
- 5% conversion to Pro ($4.99)
- 2% adoption of Coaching tier (v2, $9.99/mo)

### Quality
- Crash rate <0.5%
- Form scoring accuracy ≥85%
- Rep counting accuracy ≥90%

## Marketing & Viral Angle

### Positioning
"The personal trainer in your pocket—no internet, no subscription, just form."

### Viral Content Hooks
1. **Side-by-Side Comparison**: User's form + pro athlete form overlay on TikTok/Reels
   - "My squat vs. Hafthor's squat" videos
   - Easy share from app

2. **Form Fail Moments**: Highlight when form degrades (skeleton turns red)
   - Funny but educational
   - Shareable clips

3. **Rep Challenge**: "How many perfect reps can you do before form breaks?"
   - Leaderboard concept (v2)
   - Branded #ForgeYourForm hashtag

### Channels
- TikTok: Form comparison videos + tutorials
- Instagram Reels: Before/after user transformations
- YouTube: Demo + exercise guide videos
- Reddit: r/fitness, r/bodyweightfitness, r/golf
- Fitness influencers: Free promo codes for review

## Timeline

### Phase 1: MVP (Weeks 1–4)
- Camera feed + skeleton overlay
- Single exercise (squats)
- Basic form scoring

### Phase 2: Expansion (Weeks 5–8)
- 5 more exercises (deadlifts, curls, push-ups, planks, golf swings)
- Rep counting + form feedback
- Session recording

### Phase 3: Polish (Weeks 9–12)
- Slow-mo playback
- History view + stats
- App Store optimization

### Phase 4: Launch (Week 13)
- App Store submission + approval
- Marketing rollout

### Phase 5: Post-Launch (Weeks 14+)
- Bug fixes, performance tuning
- V1.1 features (multi-sport, benchmarks)

## Open Questions

1. **MediaPipe vs. Vision Framework?**
   - Decision: Apple Vision (built-in, no dependencies, sufficient for MVP)
   - If accuracy <80%, evaluate MediaPipe port

2. **Video file format for export?**
   - Decision: H.264 MP4 (widely compatible)
   - Alternate: ProRes for pro users (v2)

3. **iCloud backup strategy?**
   - Decision: Optional, encrypted, off by default (privacy-first)
   - Cost: ~$0.10 per GB per user per month

4. **Multi-user support?**
   - Decision: Single user at MVP (family sharing v2)
   - Profiles system for shared iPad

## Dependencies & Risks

### Technical Risks
- **Vision accuracy**: May be <85% in poor lighting → Mitigation: lighting guidance in app
- **Battery drain**: 30fps video capture is expensive → Mitigation: auto-pause, reduced FPS option
- **Memory**: SwiftData might be slow with large datasets → Mitigation: pagination, indexing

### Business Risks
- **Viral TikTok dependency**: Organic growth may plateau → Mitigation: paid ads, influencer partnerships
- **Competition**: Tiktok's AR filters may cannibalize → Differentiation: local, scientific, privacy-first
- **Saturation**: Fitness app market crowded → Differentiation: form scoring + rep counting, not just recording

## Appendix

### A. Exercise Reference
See `docs/POSE_REFERENCE.md` for joint angle specifications per exercise.

### B. API Surface
See `docs/ARCHITECTURE.md` for data structures and interfaces.

### C. Design System
See `docs/DESIGN_SYSTEM.md` for UI guidelines (Foundry forge aesthetic).
