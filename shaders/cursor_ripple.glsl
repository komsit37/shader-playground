// Water ripple cursor effect
// Creates expanding ripples when cursor moves with interference patterns

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    
    vec2 currentPos = (iCurrentCursor.xy - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    vec2 prevPos = (iPreviousCursor.xy - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    
    float timeSinceChange = iTime - iTimeCursorChange;
    float moveDistance = length(currentPos - prevPos);
    
    vec3 color = vec3(0.0);
    
    // Only show ripples if cursor has moved significantly
    if (moveDistance > 0.001) {
        // Primary ripple from current position
        float dist1 = length(uv - currentPos);
        float ripple1 = sin(dist1 * 30.0 - timeSinceChange * 8.0) * 0.5 + 0.5;
        ripple1 *= exp(-dist1 * 3.0) * exp(-timeSinceChange * 2.5);
        
        // Secondary ripple from previous position for interference
        float dist2 = length(uv - prevPos);
        float ripple2 = sin(dist2 * 25.0 - timeSinceChange * 6.0) * 0.5 + 0.5;
        ripple2 *= exp(-dist2 * 4.0) * exp(-timeSinceChange * 3.0);
        
        // Combine ripples with interference
        float combined = ripple1 + ripple2 * 0.6;
        
        // Add some chromatic dispersion
        color.r = combined * exp(-timeSinceChange * 2.0);
        color.g = combined * exp(-timeSinceChange * 2.2) * 0.8;
        color.b = combined * exp(-timeSinceChange * 2.5) * 1.2;
        
        // Add cursor highlight
        float cursorDist = length(uv - currentPos);
        float cursorGlow = exp(-cursorDist * 20.0) * 0.3;
        color += vec3(0.2, 0.6, 1.0) * cursorGlow;
    }
    
    fragColor = vec4(color, 1.0);
}