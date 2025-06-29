# Manga Slash Ghost

**Digital dissolve-style slashing effect at previous cursor position**

## Overview

Manga Slash Ghost combines the dramatic aesthetics of manga slash effects with the elegant mechanics of digital dissolve. Instead of a full-width obstructive line, the slashing effect appears at the previous cursor position and dissolves away like digital fragments.

## Visual Effects

### Slashing Mechanics
- **Main Slash**: Jagged, dramatic slash line with noise-based texture
- **Secondary Slashes**: Parallel slash marks for enhanced visual impact
- **Digital Dissolution**: Fragments break apart with pixelated dissolve effect
- **Speed Lines**: Emanating impact lines for dramatic flair

### Color Palette
- **Intense Red** (`#FF334D`) - Core slash energy
- **Hot White** (`#FFE6CC`) - Slash highlights and core intensity
- **Fire Orange** (`#FF9933`) - Outer glow and energy effects
- **Clean Gray** (`#E6E6E6`) - Subtle cursor color

## Technical Features

### Fragment System
- **Pixelated Dissolution**: Digital-style breakup mimicking digital dissolve
- **Staggered Fade**: Different fragments dissolve at varying rates
- **Glitch Effects**: Subtle digital distortion during dissolution
- **Random Distribution**: Procedural fragment placement for organic feel

### Performance Optimized
- **SDF-based Rendering**: Smooth, anti-aliased slash lines
- **Efficient Fragment Loop**: Optimized for 16 fragment calculations
- **Smart Culling**: Only renders visible effects during active period

### Terminal Integration
- **Previous Position Focus**: Effects appear where cursor was, not where text is
- **Fast Dissolution**: 0.35s duration to avoid typing interference
- **No Screen Flash**: Effects contained to slash area only
- **Text-Safe Design**: Slashing occurs at previous position, away from new text

## Use Cases

Perfect for users who want:
- **Dramatic Visual Impact**: Manga-style action effects
- **Text-Friendly Design**: No interference with current typing position
- **Digital Aesthetic**: Pixel-perfect dissolution effects
- **Gaming Feel**: Action-oriented cursor feedback

The ghost effect creates the impression that the previous cursor position "explodes" with slashing energy while leaving the current position clear for unobstructed text editing.

## Comparison to Original

- **Reduced Obstruction**: Effects at previous position instead of full trail
- **Digital Dissolution**: Clean pixelated breakup instead of persistent lines
- **Faster Fade**: Quicker dissolution for better typing experience
- **Enhanced Drama**: More intense colors and fragment effects