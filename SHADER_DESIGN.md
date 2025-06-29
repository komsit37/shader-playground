⏺ You have significant flexibility in designing shader effects! Based on the codebase
structure, here's what you can do:

Complete Creative Freedom

Visual Effects:

- Any mathematical function or algorithm you can implement in GLSL
- Complex particle systems, fluid simulations, fractals, noise patterns
- Multi-layered effects with different blend modes
- Time-based animations with custom easing functions
- Physics simulations (springs, gravity, collisions)

Color Systems:

- Full RGB/HSV color manipulation
- Custom color palettes and gradients
- Dynamic color changes based on movement, time, or position
- Transparency and alpha blending effects

Available Inputs

Cursor State:

- iCurrentCursor - current position and dimensions
- iPreviousCursor - previous position and dimensions
- iTimeCursorChange - when cursor last moved
- iTime - global time for animations
- iResolution - screen resolution
- fragCoord - current pixel position

Movement Analysis:

You can distinguish between different types of cursor movement by analyzing the available data:

**Typing vs Jumping Detection:**
- Distance between positions: `distance(iCurrentCursor.xy, iPreviousCursor.xy)`
- Small distances (~character width) = typing
- Large distances (>several characters) = jumping/navigation

**Speed Detection:**
- Time between moves: `iTime - iTimeCursorChange`
- Movement velocity: `distance / time_delta`
- Fast typing: short time intervals, consistent small distances
- Slow typing: longer intervals between moves
- Quick jumps: large distance, short time
- Deliberate navigation: varied distances and timing

**Pattern Recognition:**
- Horizontal movement (same Y) = likely typing on current line
- Vertical movement = line changes, scrolling, or navigation
- Diagonal jumps = major navigation (search results, function calls)
- Rapid back-and-forth = editing/corrections

**Implementation Examples:**
```glsl
float moveDistance = distance(iCurrentCursor.xy, iPreviousCursor.xy);
float timeDelta = iTime - iTimeCursorChange;
float velocity = moveDistance / max(timeDelta, 0.001);

// Classify movement type
bool isTyping = moveDistance < 0.05 && abs(iCurrentCursor.y - iPreviousCursor.y) < 0.01;
bool isFastTyping = isTyping && timeDelta < 0.1;
bool isJumping = moveDistance > 0.2;
bool isNearJump = moveDistance > 0.05 && moveDistance < 0.2;
bool isFarJump = moveDistance > 0.5;
```

This allows effects to adapt dynamically - subtle trails for typing, dramatic effects for navigation jumps.

Background:

- iChannel0 - the terminal background texture (in actual use)
- Can read existing pixels to blend with

Mathematical Tools

Built-in Functions:

- Trigonometry: sin, cos, tan, atan2
- Exponentials: exp, log, pow, sqrt
- Noise functions: custom implementations
- Distance functions: distance, length, dot
- Smoothing: smoothstep, mix, clamp

Custom Functions:

- SDF (Signed Distance Fields) for complex shapes
- Procedural noise for organic effects
- Custom easing curves
- Bezier curves and splines

Examples of What's Possible

Already Implemented:

- Lightning bolts with branching
- Smooth lighting trails
- Rainbow color cycling
- Bounce physics with particles
- Digital dissolve/teleportation
- Pulsing focus effects
- Water flow simulation

Could Be Added:

- Fire/flame effects
- Plasma/energy fields
- Geometric patterns
- Particle explosions
- Liquid metal effects
- Neon/cyberpunk styles
- Nature effects (leaves, snow, etc.)
- Abstract art patterns

Limitations

Performance:

- Runs in real-time, so complex calculations need optimization
- Fragment shader runs per-pixel, so efficiency matters

GLSL Constraints:

- No dynamic loops (loop counts must be compile-time constants)
- Limited precision on some operations
- No recursion

Terminal Context:

- Should work well on dark backgrounds
- Avoid effects that make text hard to read
- Consider color-blind users

The shader system is very flexible - you're essentially writing a small graphics program that
runs on the GPU for each pixel!

## Critical Issue: Terminal Content Preservation

**Problem**: Shaders that don't read screen content create black screen in Ghostty, hiding all terminal text.

**Solution**: Always start with:
```glsl
#if !defined(WEB)
fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
#endif
```

Then blend effects with the original content using `mix()` instead of replacing it.
