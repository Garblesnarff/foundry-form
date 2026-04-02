# Foundry Form — Design System

## Overview
Foundry Form adheres to the shared Foundry design system with iOS-specific adaptations. All UI elements use the dark forge aesthetic with amber accents, emphasizing precision and power.

## Color Palette

### Primary Colors
- **Forge Black**: #141210 (RGB: 20, 18, 16)
  - Used for backgrounds, text, primary UI elements
  - Creates the dark, industrial "forge" aesthetic

- **Forge Amber**: #E8A849 (RGB: 232, 168, 73)
  - Used for accent elements, CTAs, highlights
  - Represents the glow of molten metal being forged
  - Used for form score indicators when good

### Secondary Colors
- **Dark Gray**: #25241F (RGB: 37, 36, 31)
  - Used for secondary backgrounds, separators
  - Slightly lighter than black for contrast

- **Medium Gray**: #6B6A67 (RGB: 107, 106, 103)
  - Used for secondary text, disabled elements
  - Provides visual hierarchy

### Status Colors
- **Success (Green)**: #22C55E
  - Form score 80%+
  - Good form feedback

- **Warning (Yellow)**: #FBBF24
  - Form score 60–79%
  - Acceptable form, minor corrections needed

- **Error (Red)**: #EF4444
  - Form score <60%
  - Poor form feedback

## Typography

### Font Stack
Primary: **SF Pro** (Apple's system font)
- Weights: Regular (400), Semibold (600), Bold (700)
- Used for all body text, UI labels

Monospace: **SF Mono** (Apple's system monospace)
- Weights: Regular (400), Semibold (600)
- Used for numeric displays (reps, time, angles)

### Text Styles

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| **Headline** | 18px | Bold (700) | Section titles, exercise names |
| **Subheading** | 16px | Semibold (600) | Minor titles, labels |
| **Body** | 16px | Regular (400) | Description text, form copy |
| **Caption** | 12px | Regular (400) | Helper text, secondary info |
| **Monospace** | 14px | Semibold (600) | Numeric displays (reps, time) |

## Components

### Buttons

#### Primary Button (CTA)
- Background: Forge Amber (#E8A849)
- Text: White, semibold
- Padding: 12pt vertical, 16pt horizontal
- Corner radius: 8pt
- Used for: "Forge Your Form", "Start Session"

#### Secondary Button
- Background: Dark Gray (#25241F)
- Text: White, semibold
- Padding: 12pt vertical, 16pt horizontal
- Corner radius: 8pt
- Used for: "Cancel", "Close", navigation

#### Destructive Button
- Background: Red (#EF4444)
- Text: White, semibold
- Used for: "Delete", "Reset"

### Form Elements

#### Picker / Segmented Control
- Background: Dark Gray (#25241F)
- Selected: Forge Amber (#E8A849)
- Text: White
- Corner radius: 6pt

#### Slider
- Tint: Forge Amber (#E8A849)
- Track: Dark Gray (#25241F)
- Thumb: Forge Amber

#### Progress Bar
- Tint: Forge Amber (#E8A849)
- Track: Dark Gray (#25241F)

### Cards & Containers

#### Session Card
- Background: #25241F
- Corner radius: 8pt
- Padding: 12pt
- Shadow: None (flat design)
- Border: 1pt Dark Gray (#25241F) divider

#### Stats Card
- Background: #1A1915 (slightly darker)
- Corner radius: 8pt
- Padding: 12pt
- Text: Amber for values, gray for labels

## Layout & Spacing

### Spacing Scale
- **4pt**: Minimal spacing (e.g., icon-text gaps)
- **8pt**: Small spacing (component internal padding)
- **12pt**: Default spacing (card padding, component margins)
- **16pt**: Large spacing (section padding, major component gaps)
- **24pt**: Extra-large spacing (between major sections)

### Safe Area
- Respect iOS safe area (notch, home indicator)
- Minimum padding: 16pt from edges
- Full-bleed camera feed allowed

## Icons

### Icon Set
Use SF Symbols (Apple's icon library) exclusively.
- Weight: Regular or Semibold
- Size: Varies by context:
  - Tab bar icons: 24pt
  - Button icons: 16pt
  - Form icons: 20pt
  - Large badges: 48pt

### Icon Colors
- Primary icons: White
- Accent icons: Forge Amber (#E8A849)
- Disabled: Medium Gray (#6B6A67)
- Error: Red (#EF4444)
- Success: Green (#22C55E)

## Dark Mode
The app is dark-mode only (no light mode). All colors are optimized for dark backgrounds.

## Accessibility

### Text Contrast
- Minimum WCAG AA contrast ratio: 4.5:1
- Forge Amber on Forge Black: 8.2:1 ✓
- White on Forge Black: 13.8:1 ✓

### Dynamic Type Support
- All text scales with system font size settings
- Minimum size: 11pt (don't go smaller)
- Test with Large & Extra Large text sizes

### Voice Over
- All interactive elements labeled with meaningful descriptions
- Form score: "Form score: 92 percent, good"
- Rep counter: "Reps: 12"

## Platform-Specific Notes

### iPhone vs iPad
- iPhone: Single-column layout, full-width controls
- iPad: Consider 2-column layout for history (landscape)
- Adaptive layout using `@Environment(\.horizontalSizeClass)`

### Safe Area Handling
- Portrait: Respect notch + home indicator
- Landscape: Watch for Dynamic Island on newer iPhones
- Use `ignoresSafeArea()` for camera feed only

### Gesture Support
- Swipe to delete sessions (standard)
- Tap to view details
- Double-tap for quick actions (future)
- Long-press for context menu (future)

## Animation & Motion

### Transitions
- Screen transitions: `transition(.opacity).animation(.easeInOut(duration: 0.3))`
- Button presses: Quick opacity flash (no bounce)
- Form score updates: Smooth number animation (0.2s)

### Skeleton Overlay
- Joints: 6pt radius circles, Forge Amber
- Connections: 3pt lines, Forge Amber
- 30fps update minimum for smooth motion

## Internationalization (i18n)

### Language Support
- English (en-US): Primary
- Strings externalized to Localizable.strings
- All hardcoded text avoided

### Number Formatting
- Reps: Integer (1, 2, 3...)
- Form score: Percentage (92%)
- Angles: Integer degrees (90°)
- Time: MM:SS format

## Code Examples

### Forge Amber Button
```swift
Button(action: startSession) {
    HStack(spacing: 8) {
        Image(systemName: "play.circle.fill")
        Text("Forge Your Form")
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .font(.headline)
    .foregroundColor(.white)
    .background(
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(red: 0.91, green: 0.66, blue: 0.29))
    )
}
```

### Color Constants (add to App.swift)
```swift
extension Color {
    static let forgeBlack = Color(red: 0.078, green: 0.071, blue: 0.063)
    static let forgeAmber = Color(red: 0.91, green: 0.66, blue: 0.29)
    static let forgeDarkGray = Color(red: 0.145, green: 0.137, blue: 0.122)
}
```

## Compliance Checklist

Before shipping:
- [ ] All text has ≥4.5:1 contrast ratio
- [ ] All interactive elements ≥44pt × 44pt (touch target)
- [ ] VoiceOver tested (enable in Settings > Accessibility)
- [ ] Dynamic Type tested at Large and Extra Large sizes
- [ ] Layout tested on iPhone SE (small) and iPad (large)
- [ ] Skeleton overlay at 30fps+ on target device
- [ ] No layout clipping in landscape mode
- [ ] Home indicator not obstructed
