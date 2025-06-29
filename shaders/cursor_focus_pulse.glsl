// A terminal-optimized cursor for focus and clarity.
// - When idle, it has a subtle, slow pulsing glow.
// - When moving, it has a soft, brighter glow to make tracking easy.
// Ideal for use in Neovim and tmux.

vec2 normalize_coord(vec2 coord, float isPosition) {
    return (coord * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float antialising(float distance) {
    return 1.0 - smoothstep(0.0, normalize_coord(vec2(2.0, 2.0), 0.0).x, distance);
}

float glow(float distance, float radius, float intensity) {
    return pow(radius / distance, intensity);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = normalize_coord(fragCoord, 1.0);
    vec4 currentCursor = vec4(normalize_coord(iCurrentCursor.xy, 1.0), normalize_coord(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalize_coord(iPreviousCursor.xy, 1.0), normalize_coord(iPreviousCursor.zw, 0.0));
    
    float timeDelta = iTime - iTimeCursorChange;
    vec2 cursorCenter = currentCursor.xy - (currentCursor.zw * vec2(-0.5, 0.5));
    
    float movement = distance(currentCursor.xy, previousCursor.xy);
    float sdfCursor = getSdfRectangle(uv, cursorCenter, currentCursor.zw * 0.5);
    
    vec3 color = vec3(0.0);
    
    // Base cursor shape
    vec3 baseColor = vec3(0.9, 0.9, 1.0);
    color = mix(color, baseColor, antialising(sdfCursor) * 0.7);
    
    // Glow effect
    float glowRadius = 0.015;
    float glowIntensity = 0.6;
    
    // Static state: Subtle pulsing glow
    if (movement < 0.001) {
        float pulseSpeed = 2.5;
        float pulseMin = 0.3;
        float pulseMax = 0.8;
        float pulse = (sin(iTime * pulseSpeed) * 0.5 + 0.5) * (pulseMax - pulseMin) + pulseMin;
        
        float staticGlow = glow(abs(sdfCursor), glowRadius, glowIntensity);
        staticGlow = clamp(staticGlow, 0.0, 1.0);
        
        vec3 pulseColor = vec3(0.8, 0.8, 0.9);
        color = mix(color, pulseColor, staticGlow * pulse * 0.15);
    }
    // Moving state: Soft motion glow with trail fade
    else {
        float fade = 1.0 - clamp(timeDelta / 0.4, 0.0, 1.0);
        float intensity = clamp(movement * 20.0, 0.4, 1.2) * fade;
        
        float motionGlow = glow(abs(sdfCursor), glowRadius * 0.8, glowIntensity * 0.9);
        motionGlow = clamp(motionGlow, 0.0, 1.0);
        
        vec3 motionColor = vec3(0.7, 0.8, 1.0);
        color = mix(color, motionColor, motionGlow * intensity * 0.2);
    }
    
    fragColor = vec4(color, 1.0);
}
