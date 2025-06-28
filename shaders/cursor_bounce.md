# Bounce Cursor

An iOS-style elastic bounce cursor featuring trail particles and authentic bounce physics that mimics the satisfying elasticity of iOS scroll behavior.

## Core Concept

Recreates the iconic iOS bounce/elastic animation when the cursor moves, complete with overshoot and settle behavior. The cursor scales dynamically and spawns trail particles that follow the same bounce physics, creating a cohesive and satisfying animation.

## Visual Design

### Bounce Physics
- **iOS Elastic**: Authentic iOS-style bounce easing with overshoot and settle
- **Two-Phase Animation**: Quick movement to 110% then elastic settling back to 100%
- **Dynamic Scaling**: Cursor scales between 80%-120% during bounce animation
- **Overshoot Effect**: Cursor briefly extends past target position in movement direction

### Trail Particles
- **Particle Count**: 8 trail particles distributed along movement path
- **Staggered Animation**: Each particle starts bouncing at different times
- **Individual Physics**: Each particle follows independent bounce curves
- **Fade Pattern**: Particles fade in during first half, fade out during second half

### Color Palette
- **Cursor**: Light blue (`#33B3FF`)
- **Trail Particles**: Bright blue (`#99E6FF`)
- **Bounce Glow**: Electric blue (`#66CCFF`)
- **Intensity**: Moderate opacity for elegant appearance

## Technical Features

### iOS Bounce Function
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

### Elastic Out Easing
```glsl
float elasticOut(float t) {
    float c4 = (2.0 * PI) / 3.0;
    return pow(2.0, -10.0 * t) * sin((t * 10.0 - 0.75) * c4) + 1.0;
}
```

### Particle Physics
- **Time Offsets**: Each particle delayed by `t * 0.3` for staggered effect
- **Bounce Scaling**: Particle size varies with bounce amount
- **Alpha Animation**: Fade in/out based on bounce progress
- **Distance Falloff**: Particles dim with distance from center

## Animation Timeline

### Phase Breakdown
- **0.0 - 0.6s**: Primary movement with overshoot
- **0.6 - 1.0s**: Elastic settling to final position
- **Duration**: 0.8 seconds total for full bounce cycle

### Particle Staging
```
Particle 0: Starts immediately (offset 0.0)
Particle 1: Starts at 0.043s (offset 0.3/7)
Particle 2: Starts at 0.086s (offset 0.6/7)
...
Particle 7: Starts at 0.3s (offset 2.1/7)
```

## Performance Optimizations

### Efficient Particle System
- **Loop-Based**: 8 particles generated in single loop
- **Mathematical Physics**: No complex simulation required
- **Distance Fields**: Smooth particle rendering using inverse distance
- **Conditional Rendering**: Particles only render when visible

### Terminal Compatibility
- **Moderate Duration**: 0.8s provides satisfying bounce without interference
- **Movement Detection**: Only activates on significant cursor movement
- **Contained Effects**: All animations restricted to cursor area
- **Smooth Performance**: Optimized for real-time rendering

## Design Philosophy

Brings the beloved iOS bounce feel to terminal cursor movement, creating a sense of physicality and responsiveness. The elastic animation makes cursor movement feel more natural and satisfying, similar to how iOS interfaces provide tactile feedback.

Perfect for users who appreciate polished, responsive interfaces and want their terminal to feel more dynamic and engaging.

## Usage Recommendations

- **Ideal for**: Users who love iOS interface design, tactile feedback enthusiasts
- **Best with**: Any terminal theme - the blue colors work well on both light and dark backgrounds
- **Typing Speed**: Moderate duration works well for normal typing speeds
- **Environment**: Personal development, creative coding, interface design work

## Customization Options

### Adjustable Parameters
- `DURATION`: Modify bounce timing (currently 0.8s)
- `BOUNCE_INTENSITY`: Change overshoot amount (currently 1.5)
- `NUM_TRAIL_PARTICLES`: Adjust particle count (currently 8)
- Color scheme: Easily modified for different themes

### Physics Tuning
- Elastic parameters in `elasticOut()` function
- Overshoot percentage in `iOSBounce()` function
- Particle offset timing for different stagger effects
- Glow intensity and radius for visual impact