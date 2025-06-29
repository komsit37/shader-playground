# Manga Slash Zen

**Adaptive flowing lines with minimal text obstruction**

## Overview

Manga Slash Zen reimagines manga slash effects with mindful design principles. It provides beautiful flowing line effects while being intelligent about text placement, creating gaps and reducing intensity in areas where text typically appears.

## Adaptive Intelligence

### Movement Classification
- **Typing Detection**: Small horizontal movements with minimal vertical displacement
- **Navigation Detection**: Large movements indicating cursor jumps
- **Context Awareness**: Different effects for different interaction types

### Text Avoidance System
- **Horizontal Text Zones**: Detects likely text line positions
- **Dynamic Gap Creation**: Reduces line intensity near text baselines
- **Subtle Hints**: Maintains visual continuity with reduced opacity
- **Smart Line Placement**: Flows around text-heavy areas

## Visual Effects by Context

### Typing Mode
- **Minimal Trails**: Ultra-thin (0.003) flowing lines
- **Text-Aware Gaps**: 80% opacity reduction near text lines
- **Soft Teal Color**: Calming, non-distracting `#4DCCB3`
- **Fast Fade**: 0.25s duration for rapid typing compatibility

### Navigation Mode
- **Flowing Lines**: Elegant curved paths between positions
- **Dramatic Colors**: Purple/blue gradient for visual impact
- **Speed Lines**: Minimal, tasteful speed effects
- **Rich Fade**: 0.4s duration with 70% opacity for visibility

### Medium Movement
- **Balanced Effects**: Moderate flowing lines for small jumps
- **Adaptive Timing**: 0.3s duration with 50% opacity
- **Smooth Blue**: Calming `#6BB5E6` for balanced feedback

## Color Philosophy

### Zen Palette
- **Teal** (`#4DCCB3`) - Calming, focused typing
- **Purple** (`#9980E6`) - Creative navigation and exploration
- **Blue** (`#6BB5E6`) - Balanced, thoughtful movement
- **Warm White** (`#E6E6F2`) - Pure highlights and core effects

### Adaptive Cursor
- **Context-Sensitive Colors**: Cursor adapts to current movement type
- **Subtle Variations**: Non-distracting color shifts
- **Consistent Opacity**: Stable 80% opacity for readability

## Technical Innovation

### Text Detection Algorithm
```glsl
// Approximate text line detection
float textLineHeight = 0.04;
float textY = floor(p.y / textLineHeight) * textLineHeight;
float distanceToTextLine = abs(p.y - textY);

// Reduce intensity near text baseline
if (distanceToTextLine < textLineHeight * 0.3) {
    textAvoidance = 0.2; // Subtle hint instead of full line
}
```

### Performance Features
- **Efficient Line Rendering**: Optimized flowing line algorithm
- **Smart Effect Scaling**: Fewer lines for typing, more for navigation
- **Adaptive Quality**: Effect complexity matches movement importance
- **GPU-Friendly**: Minimal branching and texture lookups

## Design Philosophy

Zen design principles applied to cursor effects:

- **Mindful Minimalism**: Effects serve purpose without distraction
- **Contextual Awareness**: Responds intelligently to user intention
- **Harmonious Colors**: Calming palette that enhances focus
- **Respectful Presence**: Enhances without overwhelming

## Use Cases

Ideal for users who want:
- **Distraction-Free Typing**: Minimal interference with text editing
- **Contextual Feedback**: Intelligent response to different actions
- **Aesthetic Beauty**: Elegant flowing lines without chaos
- **Professional Environment**: Subtle effects suitable for work

The zen approach creates a cursor effect that feels like a thoughtful companion rather than a flashy distraction, adapting intelligently to support your workflow.

## Terminal Integration

- **Typing-First Design**: Optimized for text editing workflows
- **Line-Aware Positioning**: Respects terminal text structure
- **Rapid Response**: Fast effects for quick typing patterns
- **Graceful Navigation**: Beautiful effects for cursor jumps and searches