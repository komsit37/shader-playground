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

// Hash function for pseudo-random values
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 2D noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Create pixelated grid effect
float pixelGrid(vec2 p, float pixelSize) {
    vec2 grid = floor(p / pixelSize) * pixelSize;
    return hash(grid);
}

// Digital particle fragment
float digitalFragment(vec2 pos, vec2 center, float size, float randomSeed, float time, float progress) {
    // Calculate fragment offset based on noise
    vec2 offset = vec2(
        noise(center * 10.0 + randomSeed) - 0.5,
        noise(center * 15.0 + randomSeed + 100.0) - 0.5
    ) * 0.08 * progress * progress; // Quadratic spread
    
    vec2 fragmentPos = center + offset;
    
    // Fragment fades in during first half, fades out during second half
    float alpha = 1.0;
    if (progress < 0.5) {
        alpha = progress * 2.0; // Fade in
    } else {
        alpha = (1.0 - progress) * 2.0; // Fade out
    }
    
    // Create pixelated square fragment
    vec2 localPos = pos - fragmentPos;
    float pixelSize = size * (0.8 + 0.4 * sin(time * 8.0 + randomSeed)); // Slight pulsing
    
    if (abs(localPos.x) < pixelSize && abs(localPos.y) < pixelSize) {
        return alpha;
    }
    return 0.0;
}

// Reassembly effect with digital glitch
float reassemblyGlitch(vec2 pos, vec2 center, vec4 cursorBounds, float progress) {
    // Create glitch lines during reassembly
    float glitchIntensity = sin(progress * 12.0) * 0.5 + 0.5;
    vec2 glitchOffset = vec2(
        noise(pos * 20.0 + progress * 5.0) - 0.5,
        0.0
    ) * 0.01 * glitchIntensity * (1.0 - progress);
    
    vec2 glitchedPos = pos + glitchOffset;
    float sdf = getSdfRectangle(glitchedPos, center, cursorBounds.zw * 0.5);
    
    return 1.0 - smoothstep(0.0, 0.002, abs(sdf));
}

// Smooth easing functions
float easeInOut(float t) {
    return t * t * (3.0 - 2.0 * t);
}

float easeOut(float t) {
    return 1.0 - (1.0 - t) * (1.0 - t);
}

const vec4 CURSOR_COLOR = vec4(0.0, 1.0, 0.8, 1.0); // Cyan-green
const vec4 FRAGMENT_COLOR = vec4(0.2, 1.0, 0.6, 0.8); // Bright green
const vec4 GLITCH_COLOR = vec4(1.0, 0.4, 0.8, 0.6); // Magenta accent
const vec4 CORE_COLOR = vec4(1.0, 1.0, 1.0, 1.0); // White core
const float DURATION = 0.4; // Fast digital effect
const int FRAGMENT_COUNT = 16; // Number of pixel fragments

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    // Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Normalization for cursor position and size;
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);
    
    vec4 newColor = vec4(fragColor);
    
    // Only show digital effect if there was significant cursor movement
    if (moveDistance > 0.001 && progress < 1.0) {
        float dissolveProgress = easeInOut(progress);
        
        // Phase 1: Dissolve from previous position (0.0 to 0.6)
        if (progress < 0.6) {
            float dissolvePhase = progress / 0.6;
            
            // Create digital fragments spreading from previous position
            for (int i = 0; i < FRAGMENT_COUNT; i++) {
                float angle = float(i) * 6.28318 / float(FRAGMENT_COUNT);
                float radius = currentCursor.z * 0.3; // Fragment spawn radius
                vec2 fragmentCenter = centerCP + vec2(cos(angle), sin(angle)) * radius;
                
                float fragment = digitalFragment(
                    vu, 
                    fragmentCenter, 
                    0.008, // Fragment size
                    float(i) * 7.29, // Random seed per fragment
                    iTime,
                    dissolvePhase
                );
                
                if (fragment > 0.0) {
                    newColor = mix(newColor, FRAGMENT_COLOR, fragment * 0.6);
                }
            }
        }
        
        // Phase 2: Reassembly at new position (0.4 to 1.0)
        if (progress > 0.4) {
            float assemblyPhase = (progress - 0.4) / 0.6;
            
            // Digital glitch reassembly effect
            float glitch = reassemblyGlitch(vu, centerCC - (currentCursor.zw * offsetFactor), currentCursor, assemblyPhase);
            if (glitch > 0.0) {
                newColor = mix(newColor, GLITCH_COLOR, glitch * 0.4);
            }
            
            // Scanning lines effect during reassembly
            float scanLine = sin((vu.y - centerCC.y) * 100.0 + iTime * 15.0);
            scanLine = smoothstep(0.7, 1.0, scanLine) * (1.0 - assemblyPhase);
            if (scanLine > 0.0 && distance(vu, centerCC) < currentCursor.z) {
                newColor = mix(newColor, CORE_COLOR, scanLine * 0.3);
            }
        }
        
        // Digital noise removed to prevent screen flashing
    }
    
    // Draw current cursor with digital core effect
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    
    // Main cursor body
    newColor = mix(newColor, CURSOR_COLOR, antialising(sdfCurrentCursor));
    
    // Add pulsing digital core
    float coreRadius = min(currentCursor.z, currentCursor.w) * 0.2;
    float core = 1.0 - smoothstep(0.0, coreRadius, distance(vu, centerCC));
    float corePulse = 0.7 + 0.3 * sin(iTime * 4.0);
    newColor = mix(newColor, CORE_COLOR, core * corePulse * 0.6);
    
    fragColor = newColor;
}