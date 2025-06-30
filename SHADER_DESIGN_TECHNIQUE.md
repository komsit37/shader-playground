# Shader Design Techniques

## Critical Issues & Fixes

### Dark Circle Problem Fix
**Problem:** Using `mix()` for shader effects creates dark circles/halos around cursor that darken terminal background.

**Solution:** Use additive blending instead:
```glsl
// ❌ Creates dark circles
newColor = mix(newColor, effectColor, intensity);

// ✅ No dark circles, preserves background  
newColor.rgb += effectColor.rgb * intensity;
```

### Terminal Content Preservation
**Problem:** Shaders that don't read screen content create black screen in Ghostty.

**Solution:** Always start with:
```glsl
#if !defined(WEB)
fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
#endif
```

## Movement Detection Patterns

**Classify cursor movement types:**
```glsl
float moveDistance = distance(iCurrentCursor.xy, iPreviousCursor.xy);
float timeDelta = iTime - iTimeCursorChange;

bool isTyping = moveDistance < 0.05 && abs(iCurrentCursor.y - iPreviousCursor.y) < 0.01;
bool isJumping = moveDistance > 0.2;
bool isFastTyping = isTyping && timeDelta < 0.1;
```

**Movement patterns:**
- Horizontal movement = typing on current line
- Vertical movement = line changes/navigation
- Small distances = character-by-character typing
- Large distances = navigation jumps

## Performance Optimization

**GLSL Constraints:**
- No dynamic loops (use fixed bounds with early break)
- No recursion
- Runs per-pixel, so efficiency matters

**Optimization patterns:**
```glsl
// Spatial culling
if (distance(uv, cursorPos) > effectRadius) return;

// Early exit
if (intensity < 0.01) return;

// Fixed loop bounds
for (int i = 0; i < MAX_COUNT; i++) {
    if (i >= dynamicCount) break;
}
```

## Available Shader Inputs

- `iCurrentCursor` - current position and dimensions
- `iPreviousCursor` - previous position and dimensions  
- `iTimeCursorChange` - when cursor last moved
- `iTime` - global time for animations
- `iResolution` - screen resolution
- `fragCoord` - current pixel position
- `iChannel0` - terminal background texture