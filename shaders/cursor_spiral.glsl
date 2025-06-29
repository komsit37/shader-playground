// Spiral particle cursor effect
// Creates rotating spiral trails with particle-like elements

float noise(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 rotate(vec2 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    
    vec2 currentPos = (iCurrentCursor.xy - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    vec2 prevPos = (iPreviousCursor.xy - 0.5 * iResolution.xy) / min(iResolution.x, iResolution.y);
    
    float timeSinceChange = iTime - iTimeCursorChange;
    float moveDistance = length(currentPos - prevPos);
    
    vec3 color = vec3(0.0);
    
    // Create spiral trail
    vec2 toCursor = uv - currentPos;
    float distToCursor = length(toCursor);
    
    // Generate multiple spiral arms
    for (int arm = 0; arm < 3; arm++) {
        float armOffset = float(arm) * 2.09439; // 120 degrees
        
        // Spiral parameters
        float spiralTightness = 8.0;
        float spiralSpeed = 2.0;
        
        // Calculate spiral position
        for (float t = 0.0; t < 1.0; t += 0.05) {
            float radius = t * 0.3 * (1.0 + moveDistance * 5.0);
            float angle = t * spiralTightness + iTime * spiralSpeed + armOffset;
            
            vec2 spiralPos = currentPos + rotate(vec2(radius, 0.0), angle);
            
            // Add some noise to spiral path
            spiralPos += vec2(
                noise(spiralPos * 10.0 + iTime) - 0.5,
                noise(spiralPos * 10.0 + iTime + 100.0) - 0.5
            ) * 0.02;
            
            float distToSpiral = length(uv - spiralPos);
            
            // Particle size varies along spiral
            float particleSize = 0.015 * (1.0 - t) * (1.0 + sin(t * 20.0 + iTime * 3.0) * 0.3);
            
            // Particle intensity
            float particle = 1.0 - smoothstep(0.0, particleSize, distToSpiral);
            particle *= (1.0 - t) * (1.0 - t); // Fade with distance
            
            // Movement boost
            if (moveDistance > 0.001) {
                particle *= 1.0 + exp(-timeSinceChange * 2.0) * 2.0;
            }
            
            // Color based on spiral position and time
            vec3 particleColor = vec3(
                0.5 + 0.5 * sin(t * 10.0 + iTime + armOffset),
                0.3 + 0.7 * cos(t * 8.0 + iTime * 1.2),
                0.8 + 0.2 * sin(t * 12.0 + iTime * 0.8)
            );
            
            color += particleColor * particle;
        }
    }
    
    // Add trailing spiral connecting current and previous positions
    if (moveDistance > 0.001) {
        vec2 trailDir = normalize(currentPos - prevPos);
        vec2 perpDir = vec2(-trailDir.y, trailDir.x);
        
        for (float s = 0.0; s < 1.0; s += 0.02) {
            vec2 basePos = mix(prevPos, currentPos, s);
            
            // Create spiral motion along the trail
            float spiralRadius = 0.05 * sin(s * 15.0 + iTime * 4.0);
            vec2 spiralOffset = perpDir * spiralRadius;
            
            vec2 trailPos = basePos + spiralOffset;
            float distToTrail = length(uv - trailPos);
            
            float trailParticle = 1.0 - smoothstep(0.0, 0.008, distToTrail);
            trailParticle *= (1.0 - s) * exp(-timeSinceChange * 1.5);
            
            vec3 trailColor = vec3(1.0, 0.6, 0.2) * mix(1.0, 0.3, s);
            color += trailColor * trailParticle;
        }
    }
    
    // Central cursor glow
    float coreGlow = exp(-distToCursor * 20.0);
    color += vec3(0.8, 0.4, 1.0) * coreGlow * 0.5;
    
    // Add some ambient sparkle
    vec2 sparkleUV = uv * 40.0 + iTime * 0.5;
    float sparkle = noise(floor(sparkleUV));
    sparkle = smoothstep(0.97, 1.0, sparkle);
    color += vec3(1.0, 1.0, 0.8) * sparkle * 0.1;
    
    fragColor = vec4(color, 1.0);
}