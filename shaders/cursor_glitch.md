# Glitch Cursor Effect

A comprehensive digital glitch effect that creates various forms of visual corruption around the cursor during movement, inspired by datamoshing and digital artifacts.

## Visual Design

- **Primary Colors**: Purple-magenta cursor with cyan and orange-red glitch accents
- **Effect Radius**: 2x cursor size for localized corruption
- **Fade Duration**: 0.35 seconds for quick recovery
- **Movement Response**: Intensity scales with cursor jump distance

## Glitch Effects

### Core Glitch Types

1. **RGB Channel Shift**
   - Red channel offset left, blue channel offset right
   - Creates classic chromatic aberration effect
   - Intensity: 0.008 units maximum displacement

2. **Datamosh Blocks**
   - Corrupted rectangular data blocks around cursor
   - Random placement using hash function
   - Cyan color overlay with 60% intensity

3. **Digital Static**
   - High-frequency white noise overlay
   - 150Hz frequency for fine grain effect
   - Limited to 80% of effect radius

4. **Corrupted Scanlines**
   - Horizontal scanning interference
   - Orange-red color with corruption patterns
   - 200Hz scanline frequency

5. **Horizontal Displacement**
   - Glitch lines cause horizontal pixel shifts
   - Affects UV coordinates for realistic distortion
   - 25Hz glitch timing

### Advanced Effects

6. **Color Channel Corruption**
   - Random color inversion in affected areas
   - Activates at 30%+ glitch intensity
   - Affects 60% of effect radius

7. **Pixelation Effect**
   - Dynamic pixel size based on intensity
   - Activates at 50%+ glitch intensity
   - Creates blocky digital artifacts

## Technical Features

- **Intensity Scaling**: `min(moveDistance * 8.0, 1.0)` for proportional response
- **Exponential Fade**: `exp(-timeSinceChange * 3.0)` for quick recovery
- **Spatial Limiting**: All effects constrained to cursor vicinity
- **Performance Optimized**: Early distance culling prevents unnecessary calculations

## Movement Response

- **Small Movements**: Subtle RGB shift and light static
- **Medium Jumps**: Full datamosh blocks and scanline corruption
- **Large Jumps**: Maximum intensity with pixelation and color inversion

## Terminal Integration

- **Content Preservation**: Reads screen texture first
- **Localized Effects**: No full-screen interference
- **Fast Fade**: Minimal disruption to workflow
- **Color Safe**: Avoids problematic color combinations