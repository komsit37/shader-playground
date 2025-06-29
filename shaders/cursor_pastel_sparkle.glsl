// A cute, sparkling cursor with a pastel color palette.
// - When idle, it has a soft, continuous sparkle.
// - When moving, it leaves a trail of twinkling pastel particles.

// Helper function for random values
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

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

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = normalize_coord(fragCoord, 1.0);
    vec4 currentCursor = vec4(normalize_coord(iCurrentCursor.xy, 1.0), normalize_coord(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalize_coord(iPreviousCursor.xy, 1.0), normalize_coord(iPreviousCursor.zw, 0.0));
    
    float timeDelta = iTime - iTimeCursorChange;
    float progress = clamp(timeDelta / 0.3, 0.0, 1.0);
    float fade = 1.0 - progress;
    
    vec2 cursorCenter = currentCursor.xy - (currentCursor.zw * vec2(-0.5, 0.5));
    vec2 prevCursorCenter = previousCursor.xy - (previousCursor.zw * vec2(-0.5, 0.5));
    
    float distToCursor = distance(uv, cursorCenter);
    float movement = distance(currentCursor.xy, previousCursor.xy);
    
    vec3 color = vec3(0.0);
    
    // Base cursor shape (soft pink)
    float sdfCursor = getSdfRectangle(uv, cursorCenter, currentCursor.zw * 0.5);
    vec3 baseColor = vec3(1.0, 0.7, 0.85);
    color = mix(color, baseColor, antialising(sdfCursor) * 0.8);
    
    // Sparkle effect around cursor
    vec2 sparkleCoord = uv * 100.0 + iTime * 10.0;
    float sparkleNoise = rand(floor(sparkleCoord));
    
    if (sparkleNoise > 0.95) {
        vec2 sparkleOffset = (fract(sparkleCoord) - 0.5) * 0.02;
        vec2 sparklePos = cursorCenter + sparkleOffset;
        float sparkleDist = distance(uv, sparklePos);
        float sparkleSize = 0.005 + sin(iTime * 8.0 + sparkleNoise * 20.0) * 0.002;
        float sparkleIntensity = 1.0 - smoothstep(0.0, sparkleSize, sparkleDist);
        
        vec3 sparkleColor = vec3(1.0, 1.0, 0.8);
        color += sparkleColor * sparkleIntensity * 0.6;
    }
    
    // Motion trail with pastel particles
    if (movement > 0.001 && fade > 0.0) {
        for (int i = 1; i <= 5; i++) {
            float step = float(i) * 0.2;
            vec2 trailPos = mix(cursorCenter, prevCursorCenter, step);
            float trailDist = distance(uv, trailPos);
            
            float trailRand = rand(trailPos + float(i));
            vec3 trailColor = vec3(0.7, 0.8, 1.0); // Pastel blue
            if (trailRand > 0.66) trailColor = vec3(1.0, 0.9, 0.7); // Pastel yellow
            else if (trailRand > 0.33) trailColor = vec3(1.0, 0.7, 0.85); // Pastel pink
            
            float trailSize = 0.015 * (1.0 - step * 0.5);
            float trailIntensity = (1.0 - smoothstep(0.0, trailSize, trailDist)) * fade * (1.0 - step * 0.8);
            
            // Add twinkling effect to trail particles
            float twinkle = sin(iTime * 6.0 + trailRand * 15.0) * 0.5 + 0.5;
            color += trailColor * trailIntensity * 0.4 * twinkle;
        }
    }
    
    fragColor = vec4(color, 1.0);
}
