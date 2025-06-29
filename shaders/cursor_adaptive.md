# Adaptive Cursor

**Intelligent cursor effects that adapt to user behavior patterns**

## Overview

The Adaptive Cursor shader uses advanced movement analysis to provide contextual visual feedback based on detected user intentions. It distinguishes between different types of cursor activity and responds with appropriate visual cues to enhance the user experience.

## Visual Effects by Activity

### Typing Detection
- **Fast Typing**: Intense blue-white glow with ripple rings for very rapid typing (>8 chars/sec)
- **Normal Typing**: Standard yellow/orange glow for regular typing speed
- **Slow/Deliberate Typing**: Gentle green glow for careful, methodical typing

### Editing and Corrections
- **Quick Corrections**: Red pulsing glow with subtle correction trail effects
- **Back-and-forth editing**: Enhanced visual feedback for rapid text modifications

### Navigation Effects
- **Search Navigation**: Cyan ripple effects for fast long-distance jumps (search results)
- **Vertical Navigation**: Purple motion lines for scrolling and line changes
- **Horizontal Navigation**: Orange arrow trails for within-line movement

### Adaptive Cursor Colors
The cursor itself changes color based on current activity:
- **Typing**: Blue (fast), green (slow), yellow (normal)
- **Editing**: Red/pink for corrections
- **Searching**: Cyan for search navigation
- **Vertical Nav**: Purple for line changes
- **Navigation**: Orange for general movement

## Movement Analysis

The shader analyzes multiple movement characteristics:

### Distance Classification
- **Typing Distance**: < 0.03 units (character width)
- **Near Jump**: 0.03 - 0.15 units (word/small navigation)
- **Far Jump**: > 0.4 units (major navigation)

### Timing Analysis
- **Fast Actions**: < 0.08 seconds between moves
- **Normal Actions**: 0.08 - 0.3 seconds
- **Deliberate Actions**: > 0.3 seconds

### Pattern Recognition
- **Horizontal Movement**: Same line typing/editing
- **Vertical Movement**: Line changes, scrolling
- **Rapid Corrections**: Quick back-and-forth patterns
- **Jump Velocity**: Speed of navigation for search detection

## Technical Features

### Performance Optimized
- Efficient SDF-based rendering
- Minimal branching for GPU performance
- Smart effect layering to avoid overdraw

### Visual Design
- Anti-aliased smooth edges
- Contextual color palettes
- Appropriate opacity levels for each activity
- Smooth easing functions for natural animations

### Terminal-Friendly
- Effects confined to cursor area
- No screen flashing or distracting animations
- Color-blind friendly palette choices
- Fast fade times to avoid typing interference

## Use Cases

Perfect for developers and power users who want:
- **Visual feedback** for typing speed and patterns
- **Context awareness** for different editing activities
- **Navigation assistance** with visual cues for search and movement
- **Productivity insights** through visual activity classification

The adaptive system learns from movement patterns in real-time, providing immediate visual feedback that enhances terminal interaction without being distracting.