# Digital Dissolve Cursor

A unique cursor design featuring "teleportation" effect where the cursor digitally dissolves into pixelated fragments at the old position, then reassembles with glitch effects at the new position.

## Core Concept

The cursor mimics digital teleportation by breaking apart into fragments and reassembling at the destination, creating a sci-fi effect that feels like the cursor is dematerializing and rematerializing.

## Visual Design

### Phase 1: Dissolution (0-60% of animation)
- Cursor breaks into 16 digital fragments that spread outward
- Fragments use noise-based movement for realistic dispersion
- Each fragment has individual timing and random offset patterns
- Fragments fade in during first half, fade out during second half

### Phase 2: Reassembly (40-100% of animation)
- Fragments reassemble at destination with digital glitch lines
- Horizontal scanning lines sweep across the reassembly area
- Digital noise overlay creates authentic glitch aesthetic
- Overlapping phases ensure smooth visual continuity

### Color Palette
- **Main Cursor**: Cyan-green (`#00FFCC`)
- **Fragments**: Bright green (`#33FF99`)
- **Glitch Accents**: Magenta (`#FF66CC`)
- **Core**: White with pulsing animation

## Technical Features

### Procedural Effects
- Hash-based pseudo-random fragment positioning for consistent patterns
- 2D noise functions for realistic fragment dispersion
- Pixelated grid effects using floor-based sampling
- Digital scanning lines with sine wave patterns

### Performance Optimizations
- Fast 0.4s duration optimized for terminal use
- Effects contained to cursor area only (no screen flashing)
- Efficient fragment rendering using loops
- Smooth easing functions for natural animation curves

### Animation Phases
```
0.0 - 0.6: Dissolution phase (fragments spread from old position)
0.4 - 1.0: Reassembly phase (glitch effects at new position)
```

## Unique Elements

1. **Fragment Physics**: Each of 16 fragments follows unique noise-based trajectories
2. **Digital Glitch**: Horizontal offset glitches during reassembly create authentic digital artifact feel
3. **Scanning Lines**: Vertical scan lines sweep across cursor during materialization
4. **Pulsing Core**: Constant subtle white core animation even when static
5. **Procedural Noise**: Background digital noise overlay during transitions

## Design Philosophy

Perfect for developers who want something futuristic and unique - the effect suggests high-tech interfaces and digital transformation, making terminal work feel more engaging while maintaining professional aesthetics.

The cursor feels like it belongs in a cyberpunk interface or advanced sci-fi terminal, adding personality without being distracting during intensive coding sessions.