# Lighting Cursor

A smooth lighting effect featuring clean orange/yellow glow trails that follow cursor movement, optimized for terminal typing with fast fade timing.

## Core Concept

Creates an elegant lighting trail that connects the previous and current cursor positions with a warm glow effect. The design prioritizes subtlety and terminal-friendliness by eliminating dark trail artifacts and focusing purely on the lighting effect.

## Visual Design

### Trail Shape
- **Parallelogram Trail**: Connects previous and current cursor positions using a parallelogram shape
- **Vertex Calculation**: Dynamically determines start vertices based on movement direction
- **Smooth Transitions**: Uses SDF (Signed Distance Field) functions for anti-aliased edges

### Lighting Effects
- **Glow Trail**: Orange/yellow glow follows the parallelogram path between cursor positions
- **Cursor Glow**: Radial glow effect around the current cursor position
- **No Dark Artifacts**: Removed solid trail elements to keep effect purely luminous

### Color Palette
- **Cursor**: Yellow (`#FFFF99`)
- **Glow**: Orange/yellow gradient (`#FF9933` to `#FFCC33`)
- **Opacity**: Cursor 60%, glow effects 15-20%

## Technical Features

### Animation Timing
- **Duration**: 0.45 seconds total fade time
- **Glow Fade**: Starts at 0.1s, extends to full duration
- **Fast Fade**: Optimized for rapid typing without interference

### Glow Implementation
```glsl
float glow(float distance, float radius, float intensity) {
    return pow(radius / distance, intensity);
}
```

### Easing Function
- **Cubic Easing**: `pow(1.0 - x, 3.0)` for smooth fade-out
- **Natural Feel**: Provides pleasant visual decay curve

## Performance Optimizations

### Terminal-Friendly Design
- **Movement Detection**: Only shows effects when cursor moves >0.001 units
- **Fast Fade**: 0.45s duration prevents interference with rapid typing
- **Contained Effects**: All visual elements restricted to cursor and trail shapes
- **No Screen Flash**: Maintains focus during intensive coding

### Efficient Rendering
- **SDF-Based**: Uses efficient distance field calculations
- **Minimal Overdraw**: Effects only render where needed
- **Smooth Antialiasing**: Built-in edge smoothing for clean appearance

## Design Philosophy

Perfect for users who want subtle enhancement to their cursor without distraction. The warm lighting effect adds visual interest while maintaining professional aesthetics suitable for long coding sessions.

The effect suggests smooth, fluid movement and creates a sense of continuity between cursor positions, making it easier to track cursor movement across the screen during editing tasks.

## Usage Recommendations

- **Ideal for**: Long coding sessions, professional environments
- **Best with**: Dark terminal themes where the warm glow provides pleasant contrast
- **Typing Speed**: Optimized for any typing speed due to fast fade timing