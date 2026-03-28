# Foundry Form — Pose Reference & Joint Angles

## Overview
This document defines the reference joint angles for each exercise. These are the "ideal" angles that users should achieve for good form. Form scoring compares user angles against these references.

## General Principles

### Angle Definition
- **Angle**: Measured at vertex joint between two adjacent joints
- **Example**: Elbow angle = angle between shoulder → elbow → wrist
- **Range**: 0–180 degrees (straight line is 180°)
- **Calculation**: Uses `atan2` for vector angle (see `AngleCalculator.swift`)

### Tolerance Windows
Form score is calculated as:
```
score = max(0, (tolerance - |userAngle - referenceAngle|) / tolerance) * 100
```

Example: If reference elbow angle is 90° with 20° tolerance:
- User angle 90° → 100% score
- User angle 100° → 50% score
- User angle 120° → 0% score

---

## Exercise Reference Angles

### 1. Squat

**Target Body Position**:
- Feet shoulder-width apart
- Knees tracking over toes
- Chest upright, core engaged
- Descent depth: 70° knee angle (or deeper)

**Key Joint Angles**:

| Joint | Reference | Tolerance | Notes |
|-------|-----------|-----------|-------|
| **Knee** | 70° | ±20° | Measured at bottom of squat |
| **Hip** | 60° | ±20° | Hip crease below parallel |
| **Ankle** | 85° | ±15° | Slight dorsiflexion (shins forward) |

**Rep Detection**:
- Minimum angle: 70° (knee)
- Maximum angle: 170° (standing)
- Rep counted when: angle oscillates 70° → 170° → 70°

**Common Errors**:
- Knees caving in (angle>90° at bottom) → Score red
- Not going deep enough (<70°) → Score yellow
- Heels lifting (ankle >100°) → Minor deduction

---

### 2. Deadlift

**Target Body Position**:
- Straight back (neutral spine)
- Weight in heels
- Shoulders directly over bar (hips at top)
- Full hip and knee extension at top

**Key Joint Angles**:

| Joint | Reference | Tolerance | Notes |
|-------|-----------|-----------|-------|
| **Knee** | 40° | ±25° | Extension at top (nearly straight) |
| **Hip** | 25° | ±25° | Hip fully extended |
| **Back** | 20° | ±20° | Angle from vertical (lean forward) |

**Rep Detection**:
- Minimum knee angle: 20° (bottom position)
- Maximum knee angle: 170° (top, standing)
- Rep counted when: knee oscillates 20° → 170° → 20°

**Common Errors**:
- Rounding lower back (back angle >30°) → Score red
- Shoulders too far in front (poor bar path) → Minor deduction
- Incomplete lockout (knees <150°) → Score yellow

---

### 3. Bicep Curl

**Target Body Position**:
- Upper arms stationary (shoulders stable)
- Elbows at sides, slight forward angle
- Curl to ~90° elbow angle (hands near shoulders)
- Control descent

**Key Joint Angles**:

| Joint | Reference | Tolerance | Notes |
|-------|-----------|-----------|-------|
| **Elbow** | 90° | ±20° | At top of curl |
| **Shoulder** | 0° | ±10° | No swinging/momentum |
| **Wrist** | 10° | ±10° | Slight extension (neutral) |

**Rep Detection**:
- Minimum elbow angle: 40° (top position)
- Maximum elbow angle: 170° (bottom, fully extended)
- Rep counted when: elbow oscillates 40° → 170° → 40°

**Common Errors**:
- Elbows drifting forward (shoulder active) → Score yellow
- Partial reps (not full ROM) → Score red
- Swinging momentum → Score red

---

### 4. Push-Up

**Target Body Position**:
- Hands shoulder-width apart
- Body in straight line (head to heels)
- Lower until chest near ground (~90° elbow)
- Push up without hips sagging

**Key Joint Angles**:

| Joint | Reference | Tolerance | Notes |
|-------|-----------|-----------|-------|
| **Elbow** | 90° | ±20° | At bottom of push-up |
| **Shoulder (abduction)** | 45° | ±15° | Elbows not flared too wide |
| **Hip (alignment)** | 180° | ±10° | Hips level with shoulders/ankles |

**Rep Detection**:
- Minimum elbow angle: 50° (bottom)
- Maximum elbow angle: 160° (top, nearly lockout)
- Rep counted when: elbow oscillates 50° → 160° → 50°

**Common Errors**:
- Sagging hips (hip angle <170°) → Score yellow
- Elbows too wide (shoulder >60°) → Score yellow
- Not deep enough (<80°) → Score yellow
- Neck jutting forward → Minor deduction

---

### 5. Plank

**Target Body Position**:
- Body in straight line (head to heels)
- Forearms parallel, elbows under shoulders
- Core engaged, no sagging
- Hold for time (not reps)

**Key Joint Angles**:

| Joint | Reference | Tolerance | Notes |
|-------|-----------|-----------|-------|
| **Elbow** | 90° | ±10° | Forearm vertical |
| **Hip** | 180° | ±5° | Completely straight (critical) |
| **Neck** | 0° | ±10° | Neutral, not looking up/down |

**Rep Detection**:
- Not applicable (plank is isometric hold)
- Form score based on straightness of body line
- Breakdown when hip alignment degrades significantly

**Common Errors**:
- Hips sagging (hip <170°) → Score red (critical)
- Shoulders hunched (scapula not stable) → Score yellow
- Head looking up/down → Minor deduction
- Elbows too wide → Minor deduction

---

### 6. Golf Swing

**Target Body Position**:
- Address position: neutral stance
- Backswing: shoulders rotate 90°+, wrists cock slightly
- Impact: square clubface, weight shifted to front foot
- Follow-through: full rotation, extended arms

**Key Joint Angles**:

| Joint | Reference | Tolerance | Notes |
|-------|-----------|-----------|-------|
| **Wrist** | 20° | ±15° | Address position, slight extension |
| **Shoulder (rotation)** | 90° | ±20° | Turn in backswing |
| **Knee** | 15° | ±10° | Slight flex at address (stable) |

**Rep Detection**:
- Minimum angle: 10° (address)
- Maximum angle: 180° (follow-through)
- Rep counted when: angle oscillates through full range

**Common Errors**:
- Early wrist cock (wrist >35°) → Score yellow
- Insufficient turn (shoulder <70°) → Score yellow
- Swaying (losing knee flex) → Score red
- Head moving → Minor deduction

---

## Scoring Algorithm

### Form Score Calculation

```
For each primary joint:
  error = |userAngle - referenceAngle|
  contribution = max(0, (tolerance - error) / tolerance) * weight

formScore = sum(contributions) / sum(weights) * 100

// Clamp to 0-100%
formScore = min(100, max(0, formScore))
```

### Example: Squat
```
Reference: knee=70°, hip=60°
User: knee=75°, hip=50°
Tolerance: knee=20°, hip=20°
Weights: knee=0.7, hip=0.3

knee_error = |75 - 70| = 5°
knee_contribution = (20 - 5) / 20 * 0.7 = 0.525

hip_error = |50 - 60| = 10°
hip_contribution = (20 - 10) / 20 * 0.3 = 0.15

formScore = (0.525 + 0.15) / 1.0 * 100 = 67.5%
// Yellow: acceptable form, minor corrections needed
```

### Color Coding
- **Green** (80–100%): Good form, keep it up
- **Yellow** (60–79%): Acceptable form, minor adjustments
- **Red** (0–59%): Poor form, major corrections needed

---

## Measurement Methodology

### Recording Reference Videos
1. Film elite athlete performing exercise
2. Manually annotate key joints at:
   - Starting position
   - Midpoint/peak ROM
   - Ending position
3. Extract angles using `AngleCalculator`
4. Average across 3–5 clean repetitions
5. Set tolerance window based on variation

### Validation
- Test on 50+ users with varying fitness levels
- Ensure form scores correlate with visual quality assessment
- Adjust reference angles if systematic bias detected
- Document any exercise-specific variations (e.g., wide-stance squat)

---

## Special Cases & Modifications

### Wide-Stance Squat
- Knee angle reference: 65° (slightly more knee flexion allowed)
- Hip angle reference: 55°
- Otherwise same scoring

### Pin Press (Bench)
- Not currently supported (not in MVP)
- Would use: elbow angle, shoulder angle, chest position
- Future feature

### Single-Leg Variations
- Requires detecting single-leg stance
- Score each leg independently
- Average for form score
- Future feature

---

## Calibration & Personalization (Future)

### User Calibration
- Option to set personal reference angles
- "Calibrate" button → user performs 3 perfect reps
- App measures angles → sets as personalized baseline
- Score relative to user's own baseline instead of absolute

### Equipment Variations
- Barbell squat vs. bodyweight squat (slightly different angles)
- Dumbbells vs. barbell curl (shoulder angle may vary)
- Detectable via visual cues or user settings

---

## Testing Checklist

Before each release:
- [ ] All reference angles documented in this file
- [ ] Sample videos recorded for each exercise
- [ ] Angles extracted and averaged from videos
- [ ] Tolerance windows justified
- [ ] Form scoring tested with 20+ real users
- [ ] No systematic bias (e.g., consistently low scores)
- [ ] Rep detection tested and validated
- [ ] Edge cases documented (wide stance, etc.)
