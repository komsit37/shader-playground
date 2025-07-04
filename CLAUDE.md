# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a shader playground specifically designed for developing cursor effects for the Ghostty terminal. The project uses WebGL shaders (GLSL) with the GlslCanvas library to create and test cursor animations and visual effects.

## Development Commands

### Starting the Development Server

```bash
# Install dependencies first
npm install

# Start development server with file watching
browser-sync start --server --files "./*" "shaders/*"
```

The development server runs on `http://localhost:3000` and automatically reloads when files change.

### Code Formatting

```bash
npx prettier --write .
```

## Architecture

### Core Components

**index.html** - Main HTML file that sets up:

- Canvas playground with responsive grid layout
- Toolbar with cursor type and mode controls
- Loads GlslCanvas library from CDN

**main.js** - Main JavaScript controller that:

- Manages multiple shader canvases in a responsive grid
- Handles cursor position tracking and uniform updates
- Implements three interaction modes: click, auto, and random
- Loads and wraps shaders with the Ghostty wrapper
- Provides keyboard controls for cursor movement

**shaders/ghostty_wrapper.glsl** - Wrapper template that:

- Sets up uniforms for cursor data (`iCurrentCursor`, `iPreviousCursor`, `iTimeCursorChange`)
- Provides Shadertoy compatibility layer
- Contains `//$REPLACE$` placeholder for injecting actual shader code

### Shader Architecture

The shader system uses a wrapper pattern where:

1. Individual effect shaders contain the `mainImage()` function
2. The wrapper provides standard uniforms and calls the effect's `mainImage()`
3. Effects receive cursor data as vec4s: `xy` for position, `zw` for width/height
4. All coordinates are normalized to screen space (-1 to 1)

### Available Cursor Effects

**cursor_ligthing.glsl** - Smooth lighting effect:

- Clean orange/yellow glow trail following cursor movement
- Fast fade (0.45s) optimized for terminal typing
- No dark trail artifacts, glow-only design
- Parallelogram trail shape between cursor positions

**cursor_ligthing_fancy.glsl** - Jagged lightning effect:

- Electric blue lightning bolts with branching patterns
- Procedural noise-based jagged paths with secondary branches
- Fast fade (0.25s) for rapid typing without distraction
- No screen flashing - lightning confined to cursor trail

**cursor_rainbow.glsl** - Rainbow cursor effect:

- HSV rainbow colors cycling through spectrum
- Position-based color variation for dynamic gradients
- Terminal-optimized: 0.3s fade, subtle opacity (cursor 80%, trail 40%)
- No screen effects - colors restricted to cursor and trail shapes

### Cursor State Management

The system tracks:

- Current cursor position and dimensions (`iCurrentCursor`)
- Previous cursor position and dimensions (`iPreviousCursor`)
- Time when cursor last changed (`iTimeCursorChange`)

This enables trail effects and smooth transitions between cursor states.

### Interaction Modes

- **Click Mode**: Manual cursor positioning via mouse clicks
- **Auto Mode**: Cycles through preset positions automatically
- **Random Mode**: Random cursor positioning at intervals

## File Structure

```
├── index.html          # Main playground interface
├── main.js            # Core JavaScript logic
├── package.json       # Dependencies (browser-sync, prettier)
├── shaders/           # GLSL shader files
│   ├── ghostty_wrapper.glsl          # Shader wrapper template
│   ├── cursor_ligthing.glsl          # Smooth lighting trail effect
│   ├── cursor_ligthing_fancy.glsl    # Jagged lightning trail effect
│   ├── cursor_rainbow.glsl           # Rainbow cursor with subtle trail
│   ├── cursor_blaze.glsl             # Blazing trail effect
│   ├── cursor_smear.glsl             # Smear trail effect
│   └── old/                          # Archive of previous versions
└── README.md          # Basic setup instructions
```

## Working with Shaders

### Adding New Effects

1. Create new `.glsl` file in `shaders/` directory
2. Implement `mainImage(out vec4 fragColor, in vec2 fragCoord)` function
3. Use provided uniforms for cursor data and timing
4. Add shader loading to `main.js` in the Promise.all chain

### Shader Development Tips

- Use SDF (Signed Distance Field) functions for smooth shapes
- Leverage cursor position uniforms for interactive effects
- Implement antialiasing for smooth edges
- Test with different cursor sizes using toolbar controls

### Terminal-Friendly Design Principles

- **Fast fade timing**: Use 0.2-0.45s durations to avoid interference with rapid typing
- **No screen flashing**: Minimize distraction
- **Subtle opacity**: Keep trail effects at 30-50% opacity to minimize distraction
- **Smooth easing**: Use cubic or quartic easing for pleasant fade-out curves
- **Movement detection**: Only show trails when cursor moves significantly (>0.001 units)

## Testing Workflow

1. Save shader file - browser-sync will auto-reload
2. Use toolbar to test different cursor types (thin/thick, horizontal/vertical)
3. Test interaction modes to verify cursor tracking
4. Use keyboard arrows for precise cursor movement in click mode

## Important: Shader Development

**CRITICAL**: All cursor shaders MUST read the current screen content first to avoid black screen in Ghostty terminal. See SHADER_DESIGN.md for complete guidelines and common pitfalls.

