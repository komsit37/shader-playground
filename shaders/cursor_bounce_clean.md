# Clean Bounce Cursor

A minimal version of the iOS-style bounce cursor featuring pure bounce animation without trail particles or visual clutter, perfect for users who want satisfying physics with clean aesthetics.

## Core Concept

Delivers the authentic iOS bounce feel with minimal visual elements - just the cursor itself bouncing with elastic physics. Focuses on the essential bounce animation while removing all trails, particles, and extra effects for a clean, professional appearance.

## Visual Design

### Pure Bounce Animation
- **iOS Elastic Physics**: Same authentic bounce easing as full bounce cursor
- **Dynamic Scaling**: Cursor scales between 85%-115% during animation
- **Overshoot Behavior**: Brief extension past target position with elastic settle
- **Clean Aesthetics**: No particles, trails, or visual clutter

### Minimal Visual Effects
- **Subtle Glow**: Very light glow (15% opacity) only during active bounce
- **Quick Fade**: Glow disappears in first 80% of animation
- **Reduced Overshoot**: Slightly less dramatic scaling for professional feel
- **Shorter Duration**: 0.6 seconds for quicker, snappier animation

### Color Palette
- **Cursor**: Light blue (`#33B3FF`)
- **Subtle Glow**: Electric blue (`#66CCFF`) at very low opacity
- **Transparency**: Minimal visual footprint

## Technical Features

### Simplified Physics
```glsl
float iOSBounce(float t) {
    if (t < 0.6) {
        return smoothstep(0.0, 0.6, t) * 1.1; // Overshoot to 110%
    } else {
        float elasticT = (t - 0.6) / 0.4;
        return 1.1 - 0.1 * elasticOut(elasticT); // Settle back to 100%
    }
}
```

### Optimized Animation
- **Reduced Scale Range**: 85%-115% vs 80%-120% for subtler effect
- **Shorter Duration**: 0.6s vs 0.8s for faster completion
- **Minimal Glow**: Only 18% glow radius during first 80% of animation
- **Clean Falloff**: Sharp cutoff prevents lingering effects

### Performance Benefits
- **No Particle System**: Eliminates complex loop calculations
- **Minimal Overdraw**: Only cursor and minimal glow rendering
- **Faster Completion**: Shorter animation duration
- **Lower GPU Usage**: Simplified shader calculations

## Animation Timeline

### Bounce Phases
- **0.0 - 0.6s**: Primary movement with 110% overshoot
- **0.6 - 1.0s**: Elastic settling to final position
- **Glow Duration**: 0.0 - 0.48s (80% of total duration)

### Scaling Behavior
```
Start: 100% scale
Peak: 115% scale (at 60% progress)
Settle: 100% scale with elastic bounce
```

## Design Philosophy

Perfect for professional environments where you want the satisfying tactile feedback of iOS bounce physics without any visual distractions. Maintains the essential "feel" while eliminating everything that could interfere with terminal focus.

Ideal for users who appreciate subtle, high-quality animations but prioritize clean, minimal aesthetics in their development environment.

## Usage Recommendations

- **Ideal for**: Professional development, clean interface preferences, minimal aesthetic lovers
- **Best with**: Any terminal theme - minimal visual footprint adapts to any color scheme
- **Typing Speed**: Fast 0.6s duration accommodates rapid typing
- **Environment**: Corporate development, focused coding sessions, minimalist setups

## Comparison with Full Bounce

### Removed Elements
- ❌ Trail particles (8 particles eliminated)
- ❌ Staggered particle animations
- ❌ Complex particle physics
- ❌ Extended visual effects

### Retained Elements
- ✅ Authentic iOS bounce physics
- ✅ Dynamic cursor scaling
- ✅ Overshoot and settle behavior
- ✅ Smooth elastic easing

## Technical Optimizations

### Simplified Rendering
- **Single Object**: Only cursor rendering required
- **Minimal Glow**: 15% opacity, limited duration
- **No Loops**: Eliminates particle generation loops
- **Direct Calculation**: Straightforward physics without complexity

### Terminal Efficiency
- **Faster Animation**: 0.6s completion for quick feedback
- **Low Resource Usage**: Minimal GPU and CPU impact
- **Clean State**: No lingering visual artifacts
- **Focus Preservation**: Doesn't interfere with terminal readability

## Customization Notes

Easy to modify for different preferences:
- `DURATION`: Adjust bounce timing (currently 0.6s)
- `BOUNCE_INTENSITY`: Modify overshoot amount (currently 1.2)
- Scale range: Currently 85%-115% for subtle effect
- Glow parameters: Easily disabled for pure minimal experience