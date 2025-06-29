// Heartbeat pulse cursor effect
// Creates rhythmic pulsing rings with varying intensity

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    
    vec2 currentPos = (iCurrentCursor.xy - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    vec2 prevPos = (iPreviousCursor.xy - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    
    float timeSinceChange = iTime - iTimeCursorChange;
    float moveDistance = length(currentPos - prevPos);
    
    vec3 color = vec3(0.0);
    
    // Generate heartbeat rhythm
    float heartRate = 1.5; // beats per second
    float beatTime = mod(iTime * heartRate, 1.0);
    
    // Double pulse pattern (lub-dub)
    float pulse1 = smoothstep(0.0, 0.1, beatTime) * smoothstep(0.2, 0.1, beatTime);
    float pulse2 = smoothstep(0.3, 0.4, beatTime) * smoothstep(0.5, 0.4, beatTime);
    float heartbeat = pulse1 + pulse2 * 0.7;
    
    // Distance from cursor
    float dist = length(uv - currentPos);
    
    // Multiple pulse rings
    for (int i = 0; i < 4; i++) {
        float ringTime = beatTime + float(i) * 0.15;
        float ringRadius = ringTime * 0.8;
        
        // Ring thickness varies with heartbeat
        float thickness = 0.02 + heartbeat * 0.01;
        float ring = 1.0 - smoothstep(ringRadius - thickness, ringRadius + thickness, dist);
        ring *= smoothstep(0.0, 0.1, ringRadius) * smoothstep(1.0, 0.8, ringRadius);
        
        // Color shifts with each ring
        vec3 ringColor = vec3(
            0.8 + 0.2 * sin(float(i) * 2.0),
            0.3 + 0.3 * cos(float(i) * 1.5),
            0.6 + 0.4 * sin(float(i) * 3.0)
        );
        
        color += ringColor * ring * heartbeat * (1.0 - float(i) * 0.2);
    }
    
    // Add movement-triggered intensity
    if (moveDistance > 0.001) {
        float moveBoost = exp(-timeSinceChange * 3.0) * moveDistance * 10.0;
        color *= (1.0 + moveBoost);
        
        // Add sparkle effect on movement
        vec2 sparkleUV = uv * 50.0 + iTime;
        float sparkle = hash(floor(sparkleUV)) * hash(floor(sparkleUV + 1.0));
        sparkle = smoothstep(0.98, 1.0, sparkle);
        color += vec3(1.0, 0.8, 0.6) * sparkle * moveBoost * 0.3;
    }
    
    // Core cursor glow
    float coreGlow = exp(-dist * 15.0) * (0.5 + heartbeat * 0.5);
    color += vec3(1.0, 0.4, 0.6) * coreGlow;
    
    fragColor = vec4(color, 1.0);
}