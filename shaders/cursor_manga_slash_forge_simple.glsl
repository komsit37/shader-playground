// Manga Slash Forge - Simplified working version
float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// Simple hash function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Enhanced radial slash with jagged edges
float simpleSlash(vec2 p, vec2 center, float angle, float length, float thickness) {
    vec2 direction = vec2(cos(angle), sin(angle));
    vec2 toPoint = p - center;
    float alongSlash = dot(toPoint, direction);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    float acrossSlash = dot(toPoint, perpendicular);
    
    if (alongSlash < 0.0 || alongSlash > length) return 0.0;
    
    // Add jagged edge effect
    float t = alongSlash / length;
    float jaggedOffset = (hash(vec2(t * 10.0, angle)) - 0.5) * thickness * 0.5;
    
    float intensity = thickness * 3.0 / max(abs(acrossSlash - jaggedOffset) * 25.0 + 0.005, 0.001);
    return clamp(intensity, 0.0, 1.0);
}

// Enhanced flowing line with undulation
float simpleFlow(vec2 p, vec2 start, vec2 end, float thickness) {
    vec2 direction = normalize(end - start);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    float totalLength = distance(start, end);
    
    if (totalLength < 0.001) return 0.0;
    
    vec2 localP = p - start;
    float alongPath = dot(localP, direction);
    float acrossPath = dot(localP, perpendicular);
    
    if (alongPath < 0.0 || alongPath > totalLength) return 0.0;
    
    float t = alongPath / totalLength;
    
    // Add flowing undulation
    float waveOffset = sin(t * 8.0 + iTime * 3.0) * thickness * 0.4;
    
    float intensity = thickness * 4.0 / max(abs(acrossPath - waveOffset) * 40.0 + 0.005, 0.001);
    return clamp(intensity, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    // Normalization
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);
    
    float progress = clamp((iTime - iTimeCursorChange) / 0.4, 0.0, 1.0);
    
    vec4 newColor = fragColor;
    
    // Enhanced effects with better visibility
    if (moveDistance > 0.001 && progress < 1.0) {
        float fade = 1.0 - progress * progress; // Slower fade for visibility
        
        // Typing: enhanced radial forge slashes
        if (moveDistance < 0.05) {
            float totalSlash = 0.0;
            
            // 8 radial slashes for dramatic forge effect
            for (int i = 0; i < 8; i++) {
                float angle = float(i) * 0.785; // 45° intervals
                float slash = simpleSlash(vu, centerCC, angle, 0.04, 0.015);
                totalSlash += slash;
            }
            
            if (totalSlash > 0.0) {
                // Multi-layer color effect
                vec3 forgeColor = vec3(1.0, 0.8, 0.2); // Bright orange/yellow
                if (totalSlash > 0.5) {
                    forgeColor = mix(forgeColor, vec3(1.0, 1.0, 1.0), (totalSlash - 0.5) * 2.0); // White hot core
                }
                newColor = mix(newColor, vec4(forgeColor, 1.0), clamp(totalSlash * fade * 0.8, 0.0, 0.9));
            }
        }
        // Navigation: enhanced flowing line with multiple streams
        else {
            float totalFlow = 0.0;
            
            // Main flowing line
            totalFlow += simpleFlow(vu, centerCP, centerCC, 0.015);
            
            // Parallel flowing lines for richness
            vec2 direction = normalize(centerCC - centerCP);
            vec2 perpendicular = vec2(-direction.y, direction.x);
            
            for (int i = 0; i < 2; i++) {
                float offset = (float(i) - 0.5) * moveDistance * 0.3;
                vec2 flowStart = centerCP + perpendicular * offset;
                vec2 flowEnd = centerCC + perpendicular * offset;
                totalFlow += simpleFlow(vu, flowStart, flowEnd, 0.010) * 0.7;
            }
            
            if (totalFlow > 0.0) {
                // Multi-layer flow colors
                vec3 flowColor = vec3(0.4, 0.3, 0.8); // Purple base
                if (totalFlow > 0.3) {
                    flowColor = mix(flowColor, vec3(0.8, 0.8, 0.9), (totalFlow - 0.3) / 0.7); // Silver highlights
                }
                newColor = mix(newColor, vec4(flowColor, 1.0), clamp(totalFlow * fade * 0.7, 0.0, 0.8));
            }
        }
    }
    
    // Draw cursor
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    newColor = mix(newColor, vec4(0.9, 0.9, 0.9, 1.0), antialising(sdfCurrentCursor));
    
    fragColor = newColor;
}