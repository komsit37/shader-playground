# Rainbow Cursor

A terminal-optimized rainbow effect featuring HSV color cycling through the spectrum with subtle trail animation, designed to be fun while minimizing distraction during coding.

## Core Concept

Creates a vibrant rainbow cursor that cycles through the full color spectrum using HSV color space. The effect includes a subtle trail that averages colors between positions, providing visual interest without overwhelming the terminal interface.

## Visual Design

### Color Generation
- **HSV Color Space**: Smooth transitions through full hue spectrum (0-360°)
- **Position-Based Variation**: Colors change based on cursor position for dynamic gradients
- **Time Animation**: Slow color cycling creates gentle rainbow movement
- **Saturation/Brightness**: 70% saturation, 90% brightness for pleasant, non-harsh colors

### HSV to RGB Conversion
```glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

### Rainbow Calculation
```glsl
float hue = fract(time * speed + pos.x * 0.5 + pos.y * 0.3);
return hsv2rgb(vec3(hue, 0.7, 0.9));
```

## Technical Features

### Terminal Optimization
- **Fast Fade**: 0.3 seconds duration for rapid typing compatibility
- **Subtle Opacity**: Cursor 80%, trail 40% to maintain readability
- **Movement Detection**: Only shows trail on significant movement (>0.001 units)
- **No Screen Effects**: Colors restricted to cursor and trail shapes only

### Color Animation
- **Rainbow Speed**: 0.8 cycles per second for gentle animation
- **Trail Speed**: 0.7x slower for smoother trail appearance  
- **Position Influence**: X-axis contributes 0.5, Y-axis contributes 0.3 to hue calculation
- **Smooth Transitions**: Fractional time ensures seamless color loops

### Trail Design
- **Parallelogram Shape**: Connects previous and current cursor positions
- **Color Averaging**: Trail uses averaged position for consistent color gradients
- **Opacity Fade**: Trail opacity decreases over time using cubic easing
- **Anti-aliased Edges**: SDF-based rendering for smooth appearance

## Color Palette Characteristics

### HSV Parameters
- **Hue**: Full spectrum (0-360°) cycling based on time and position
- **Saturation**: 70% for vibrant but not overwhelming colors
- **Value/Brightness**: 90% for good visibility without eye strain

### Visual Balance
- **Cursor Visibility**: 80% opacity ensures cursor remains clearly visible
- **Trail Subtlety**: 40% opacity provides effect without distraction
- **Color Harmony**: Smooth HSV transitions prevent jarring color changes

## Performance Optimizations

### Efficient Rendering
- **Single Pass**: Colors calculated once per pixel
- **Mathematical Color**: No texture lookups required
- **Optimized Functions**: Efficient HSV-to-RGB conversion
- **Contained Effects**: No screen-wide processing

### Terminal Compatibility
- **Quick Fade**: 0.3s prevents interference with rapid editing
- **Low CPU Impact**: Mathematical colors vs complex effects
- **Readable Text**: Maintains terminal text legibility
- **Non-Distracting**: Subtle animation speed and opacity

## Design Philosophy

Perfect for developers who want to add personality and fun to their terminal environment without sacrificing functionality. The rainbow effect brings joy and visual interest while maintaining professional usability.

The continuous color cycling creates a sense of liveliness and creativity, making coding sessions feel more engaging and personalized.

## Usage Recommendations

- **Ideal for**: Creative coding, personal projects, mood enhancement
- **Best with**: Dark terminal themes where rainbow colors provide vibrant contrast
- **Typing Speed**: Optimized for any typing speed due to fast fade
- **Environment**: Personal development environments, creative workshops

## Customization Notes

The effect can be easily modified by adjusting:
- `RAINBOW_SPEED`: Change color cycling rate
- `TRAIL_OPACITY`: Adjust trail visibility
- `CURSOR_OPACITY`: Modify cursor transparency
- HSV saturation/brightness values for different color intensities