// Glitch cursor effect - digital corruption and datamoshing
// Creates various glitch artifacts around cursor with movement-triggered intensity

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
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

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// Datamosh effect - corrupted rectangular blocks
float datamoshBlock(vec2 uv, vec2 center, float size, float seed, float intensity) {
    vec2 blockUV = (uv - center) / size;
    vec2 blockID = floor(blockUV);
    
    float blockHash = hash(blockID + seed);
    float blockExists = step(0.6, blockHash);
    
    vec2 blockPos = fract(blockUV);
    float blockShape = 1.0 - smoothstep(0.1, 0.9, max(abs(blockPos.x - 0.5), abs(blockPos.y - 0.5)) * 2.0);
    
    return blockExists * blockShape * intensity;
}

// RGB shift effect - only return positive contributions
vec3 rgbShift(vec2 uv, vec2 cursorPos, vec2 cursorSize, float shiftAmount, float intensity) {
    vec2 offset1 = vec2(-shiftAmount, 0.0);
    vec2 offset2 = vec2(shiftAmount, 0.0);
    
    float sdfR = getSdfRectangle(uv, cursorPos + offset1, cursorSize * 0.5);
    float sdfG = getSdfRectangle(uv, cursorPos, cursorSize * 0.5);
    float sdfB = getSdfRectangle(uv, cursorPos + offset2, cursorSize * 0.5);
    
    // Only return positive contributions for additive blending
    float r = antialising(sdfR) * intensity * 0.8; // Red component
    float g = antialising(sdfG) * intensity * 0.6; // Green component  
    float b = antialising(sdfB) * intensity * 1.0; // Blue component
    
    return vec3(r, g, b);
}

// Digital static noise
float digitalStatic(vec2 uv, float time, float frequency) {
    vec2 noiseUV = uv * frequency + time;
    return step(0.5, hash(floor(noiseUV)));
}

// Scanline corruption
float corruptedScanlines(vec2 uv, vec2 center, float time, float radius) {
    float dist = distance(uv, center);
    if (dist > radius) return 0.0;
    
    float scanline = sin((uv.y - center.y) * 200.0 + time * 30.0);
    float corruption = sin(time * 15.0 + dist * 10.0) * 0.5 + 0.5;
    
    return smoothstep(0.7, 1.0, scanline) * corruption;
}

// Horizontal displacement glitch
vec2 horizontalGlitch(vec2 uv, vec2 center, float time, float intensity, float radius) {
    float dist = distance(uv, center);
    if (dist > radius) return uv;
    
    float glitchLine = sin((uv.y - center.y) * 50.0 + time * 25.0);
    float glitchMask = step(0.8, glitchLine);
    float displacement = sin(time * 40.0 + uv.y * 100.0) * 0.02 * intensity;
    
    return uv + vec2(displacement * glitchMask, 0.0);
}

const vec4 CURSOR_COLOR = vec4(0.8, 0.2, 1.0, 1.0); // Purple-magenta
const vec4 GLITCH_COLOR1 = vec4(0.0, 1.0, 0.8, 1.0); // Cyan
const vec4 GLITCH_COLOR2 = vec4(1.0, 0.3, 0.0, 1.0); // Orange-red
const vec4 STATIC_COLOR = vec4(1.0, 1.0, 1.0, 1.0); // White
const float FADE_DURATION = 0.35; // Fast fade for minimal distraction

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Preserve terminal content
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);
    
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = length(centerCC - centerCP);
    
    float timeSinceChange = iTime - iTimeCursorChange;
    float progress = clamp(timeSinceChange / FADE_DURATION, 0.0, 1.0);
    float fadeIntensity = exp(-timeSinceChange * 3.0); // Fast exponential fade
    
    vec4 newColor = fragColor;
    
    // Global glitch intensity based on movement
    float glitchIntensity = min(moveDistance * 8.0, 1.0) * fadeIntensity;
    float effectRadius = max(currentCursor.z, currentCursor.w) * 2.0;
    float distToCursor = distance(vu, centerCC);
    
    // Apply glitch effects only near cursor
    if (distToCursor < effectRadius && glitchIntensity > 0.01) {
        float glitchTime = iTime * 20.0 + moveDistance * 30.0;
        
        // Apply horizontal displacement glitch to UV coordinates
        vec2 glitchedUV = horizontalGlitch(vu, centerCC, glitchTime, glitchIntensity, effectRadius);
        
        // RGB shift on cursor - use additive blending
        vec2 cursorPos = currentCursor.xy - (currentCursor.zw * offsetFactor);
        float shiftAmount = 0.008 * glitchIntensity;
        vec3 rgbShifted = rgbShift(glitchedUV, cursorPos, currentCursor.zw, shiftAmount, 0.8);
        
        // Add RGB shift contribution instead of mixing
        newColor.rgb += rgbShifted * 0.4;
        
        // Datamosh blocks around cursor
        float datamosh = datamoshBlock(vu, centerCC, 0.05, iTime * 5.0, glitchIntensity);
        newColor.rgb += GLITCH_COLOR1.rgb * datamosh * 0.4;
        
        // Digital static overlay
        float staticNoise = digitalStatic(vu, glitchTime * 0.1, 150.0);
        staticNoise *= step(distToCursor, effectRadius * 0.8);
        newColor.rgb += STATIC_COLOR.rgb * staticNoise * glitchIntensity * 0.3;
        
        // Corrupted scanlines
        float scanlines = corruptedScanlines(vu, centerCC, glitchTime, effectRadius * 0.9);
        newColor.rgb += GLITCH_COLOR2.rgb * scanlines * glitchIntensity * 0.3;
        
        // Color channel corruption
        if (glitchIntensity > 0.3) {
            float channelCorruption = sin(glitchTime * 3.7) * 0.5 + 0.5;
            if (channelCorruption > 0.7) {
                // Invert colors in random areas
                vec2 corruptionUV = vu * 80.0 + glitchTime * 0.2;
                float corruptionMask = step(0.8, hash(floor(corruptionUV)));
                corruptionMask *= step(distToCursor, effectRadius * 0.6);
                
                // Use additive color corruption instead of inversion to avoid darkening
                newColor.rgb += vec3(corruptionMask * glitchIntensity * 0.2);
            }
        }
        
        // Pixelation effect during intense glitch
        if (glitchIntensity > 0.5) {
            float pixelSize = 0.01 + glitchIntensity * 0.02;
            vec2 pixelatedUV = floor(vu / pixelSize) * pixelSize;
            float pixelationMask = step(distance(pixelatedUV, centerCC), effectRadius * 0.5);
            
            // Add pixelation effect additively
            newColor.rgb += CURSOR_COLOR.rgb * pixelationMask * 0.2;
        }
    }
    
    // Glitch trail along movement path
    if (moveDistance > 0.001) {
        vec2 trailDir = normalize(centerCC - centerCP);
        float trailLength = moveDistance;
        
        // Dynamic trail segments based on distance
        int maxTrailSegments = int(8.0 + min(moveDistance * 30.0, 24.0));
        
        for (int i = 0; i < 32; i++) {
            if (i >= maxTrailSegments) break;
            
            float trailPos = float(i) / float(maxTrailSegments - 1);
            vec2 trailPoint = mix(centerCP, centerCC, trailPos);
            
            float trailFade = exp(-trailPos * 3.0) * fadeIntensity;
            float trailRadius = max(currentCursor.z, currentCursor.w) * (0.8 + trailPos * 0.4);
            float distToTrail = distance(vu, trailPoint);
            
            if (distToTrail < trailRadius && trailFade > 0.01) {
                float trailTime = iTime * 15.0 + trailPos * 20.0;
                
                // Trail glitch effects
                float trailGlitchIntensity = trailFade * min(moveDistance * 6.0, 1.0);
                
                // RGB shift along trail
                vec2 trailOffset = vec2(sin(trailTime) * 0.006, cos(trailTime * 1.3) * 0.004) * trailGlitchIntensity;
                float trailShift = sin(trailTime * 2.0) * 0.005 * trailGlitchIntensity;
                
                // Sample RGB channels with offset
                float trailMask = 1.0 - smoothstep(trailRadius * 0.5, trailRadius, distToTrail);
                
                vec3 trailGlitchColor = vec3(
                    trailMask * (1.0 + sin(trailTime + trailPos * 10.0) * 0.3),
                    trailMask * (0.8 + cos(trailTime * 1.5) * 0.4),
                    trailMask * (0.6 + sin(trailTime * 0.8) * 0.5)
                );
                
                // Blend trail glitch with background using additive blend
                newColor.rgb += trailGlitchColor * trailGlitchIntensity * 0.2;
                
                // Add digital noise to trail
                vec2 trailNoiseUV = vu * 100.0 + trailTime * 0.2;
                float trailNoise = step(0.7, hash(floor(trailNoiseUV)));
                trailNoise *= step(distToTrail, trailRadius * 0.8);
                
                vec3 noiseContribution = vec3(trailNoise) * trailGlitchIntensity * 0.15;
                newColor.rgb += noiseContribution;
                
                // Trail scanline glitches
                float trailScanline = sin((vu.y - trailPoint.y) * 150.0 + trailTime * 20.0);
                trailScanline = smoothstep(0.8, 1.0, trailScanline) * trailMask;
                newColor.rgb += GLITCH_COLOR2.rgb * trailScanline * trailGlitchIntensity * 0.3;
            }
        }
    }
    
    // Draw normal cursor with glitch overlay - use additive blending to avoid dark circles
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    
    // Base cursor with additive glitch coloring
    vec4 cursorColor = mix(CURSOR_COLOR, GLITCH_COLOR1, sin(iTime * 8.0) * 0.5 + 0.5);
    float cursorMask = antialising(sdfCurrentCursor);
    
    // Use additive blending instead of mix to avoid darkening
    newColor.rgb += cursorColor.rgb * cursorMask * 0.6;
    
    // Cursor outline glow with additive blending
    float outlineGlow = 1.0 - smoothstep(0.0, max(currentCursor.z, currentCursor.w) * 0.3, distToCursor);
    outlineGlow *= fadeIntensity * 0.2;
    newColor.rgb += GLITCH_COLOR2.rgb * outlineGlow;
    
    fragColor = newColor;
}