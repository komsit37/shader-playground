# Fancy Lightning Cursor

A jagged lightning effect featuring electric blue lightning bolts with branching patterns, designed to be flashy and fun while maintaining fast fade timing for terminal use.

## Core Concept

Creates dramatic lightning bolts that connect cursor positions with realistic jagged paths and secondary branches. The effect uses procedural noise to generate authentic electrical discharge patterns that flicker and animate dynamically.

## Visual Design

### Lightning Generation
- **Main Bolt**: Primary lightning path between cursor positions using multi-octave noise
- **Secondary Branches**: Two additional branch paths at 30%-70% and 20%-80% along main bolt
- **Jagged Pattern**: 4 octaves of noise create realistic electrical discharge appearance
- **Dynamic Flicker**: Time-based animation makes lightning bolts pulse and shimmer

### Lightning Physics
```glsl
// Jagged displacement using multiple noise octaves
float displacement = 0.0;
float amplitude = 0.015;
float frequency = 8.0;

for (int i = 0; i < 4; i++) {
    displacement += (noise - 0.5) * amplitude;
    amplitude *= 0.6;  // Decay each octave
    frequency *= 2.0;  // Increase frequency
}
```

### Color Palette
- **Lightning**: Electric blue (`#99CCFF`)
- **Glow**: Bright blue (`#4DCCFF`)
- **Cursor**: Light blue-white (`#E6E6FF`)
- **Intensity**: High contrast for dramatic effect

## Technical Features

### Procedural Lightning
- **Noise-Based Paths**: Uses hash function for consistent pseudo-random patterns
- **Branch Generation**: Secondary bolts branch off at calculated angles
- **Time Animation**: Flicker effect using `sin(time * 25.0)` for realistic electrical behavior
- **Distance Fields**: Lightning rendered as inverse distance fields for smooth appearance

### Performance Optimizations
- **Fast Fade**: 0.25 seconds total duration for rapid typing compatibility
- **Movement Detection**: Only activates on significant cursor movement (>0.001 units)
- **Efficient Branching**: Limited to 2 secondary branches to maintain performance
- **No Screen Flash**: Removed flash effects to prevent distraction

### Animation Curve
- **Sharp Easing**: `pow(1.0 - x, 4.0)` for quick, dramatic fade-out
- **Immediate Impact**: Lightning appears instantly then fades rapidly
- **Flicker Timing**: 25 Hz flicker rate for authentic electrical effect

## Branch Architecture

### Main Lightning Bolt
- Path follows direct line between cursor positions
- Displaced by multi-octave noise for jagged appearance
- Width inversely proportional to distance (1/400x multiplier)

### Secondary Branches
1. **Branch 1 (30-70% of path)**:
   - Angled 0.8 radians from main direction
   - 0.3x intensity of main bolt
   - Uses sine wave displacement

2. **Branch 2 (20-80% of path)**:
   - Angled -0.6 radians from main direction  
   - 0.2x intensity of main bolt
   - Uses cosine wave displacement

## Design Philosophy

Created for users who want a more dramatic, attention-grabbing cursor effect. The lightning theme suggests power and energy, making cursor movement feel more dynamic and engaging.

Perfect for gaming environments, creative coding sessions, or when you want to add personality to your terminal without compromising functionality.

## Usage Recommendations

- **Ideal for**: Creative work, gaming, demo presentations
- **Best with**: Dark backgrounds where electric blue provides strong contrast
- **Typing Speed**: Fast fade (0.25s) accommodates rapid typing
- **Mood**: Energetic, dramatic, attention-grabbing

## Technical Notes

The effect balances visual drama with terminal practicality by using:
- Quick fade timing to avoid typing interference
- Contained lightning effects (no screen flash)
- Efficient procedural generation
- Smooth anti-aliased rendering