// Manga Slash Ghost - Digital dissolve-style slashing effect at previous position
// Combines manga slash aesthetics with digital dissolve mechanics

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

// Create slashing fragments that dissolve away
float slashFragment(vec2 pos, vec2 start, vec2 end, float thickness, float randomSeed, float progress) {
    vec2 direction = normalize(end - start);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    float pathLength = distance(start, end);
    
    if (pathLength < 0.001) return 0.0;
    
    // Calculate position along slash path
    vec2 toPos = pos - start;
    float alongPath = dot(toPos, direction);
    float acrossPath = dot(toPos, perpendicular);
    
    float t = clamp(alongPath / pathLength, 0.0, 1.0);
    
    // Create jagged slash line with noise
    float jaggedOffset = (noise(vec2(t * 15.0, randomSeed)) - 0.5) * thickness * 0.8;
    float mainSlash = thickness / (abs(acrossPath - jaggedOffset) * 50.0 + 0.002);
    
    // Add secondary slash marks
    float secondarySlash = 0.0;
    for (int i = 0; i < 3; i++) {
        float offset = (float(i) - 1.0) * thickness * 0.4;
        float jaggedSec = (noise(vec2(t * 12.0 + float(i), randomSeed + float(i))) - 0.5) * thickness * 0.3;
        secondarySlash += thickness * 0.6 / (abs(acrossPath - offset - jaggedSec) * 80.0 + 0.004);
    }
    
    // Digital dissolve effect - fragments break apart and fade
    float dissolveProgress = clamp(progress * 1.5, 0.0, 1.0);
    
    // Create pixelated dissolution
    vec2 pixelGrid = floor(pos * 200.0) / 200.0;
    float pixelNoise = hash(pixelGrid + randomSeed);
    
    // Fragments dissolve at different rates
    float dissolveThreshold = 0.3 + pixelNoise * 0.7;
    float fragmentAlpha = 1.0 - smoothstep(dissolveThreshold - 0.1, dissolveThreshold + 0.1, dissolveProgress);
    
    // Add digital glitch effect
    float glitchOffset = sin(pos.x * 150.0 + progress * 20.0) * 0.001 * (1.0 - progress);
    
    return (mainSlash + secondarySlash) * fragmentAlpha;
}

// Speed lines emanating from slash
float speedLines(vec2 pos, vec2 center, vec2 direction, float progress, float seed) {
    vec2 perpendicular = vec2(-direction.y, direction.x);
    
    float lines = 0.0;
    for (int i = 0; i < 5; i++) {
        float lineOffset = (float(i) - 2.0) * 0.03;
        vec2 lineStart = center + perpendicular * lineOffset;
        vec2 lineEnd = lineStart + direction * 0.15 * (1.0 - progress);
        
        float lineIntensity = slashFragment(pos, lineStart, lineEnd, 0.002, seed + float(i), progress * 0.8);
        lines += lineIntensity * (1.0 - progress) * 0.3;
    }
    
    return lines;
}

// Easing functions
float easeOut(float t) {
    return 1.0 - (1.0 - t) * (1.0 - t);
}

float easeInOut(float t) {
    return t * t * (3.0 - 2.0 * t);
}

// Manga slash colors
const vec3 SLASH_RED = vec3(1.0, 0.2, 0.3);      // Intense red
const vec3 SLASH_WHITE = vec3(1.0, 0.9, 0.8);    // Hot white
const vec3 SLASH_ORANGE = vec3(1.0, 0.6, 0.2);   // Fire orange
const vec3 CURSOR_COLOR = vec3(0.9, 0.9, 0.9);   // Clean cursor
const float DURATION = 0.35; // Fast dramatic effect

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

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);
    
    vec4 newColor = vec4(fragColor);
    
    // Show slash effect only if there was significant movement
    if (moveDistance > 0.001 && progress < 1.0) {
        vec2 slashDirection = normalize(centerCC - centerCP);
        float seed = iTimeCursorChange;
        
        // Main slash effect at previous position (like digital dissolve location)
        vec2 slashStart = centerCP - slashDirection * moveDistance * 0.3;
        vec2 slashEnd = centerCP + slashDirection * moveDistance * 0.7;
        
        float mainSlash = slashFragment(vu, slashStart, slashEnd, 0.015, seed, progress);
        
        // Secondary slashes for dramatic effect
        float secondarySlashes = 0.0;
        for (int i = 0; i < 3; i++) {
            vec2 offset = vec2(-slashDirection.y, slashDirection.x) * (float(i) - 1.0) * moveDistance * 0.2;
            vec2 secStart = slashStart + offset;
            vec2 secEnd = slashEnd + offset;
            
            secondarySlashes += slashFragment(vu, secStart, secEnd, 0.008, seed + float(i) * 3.0, progress) * 0.6;
        }
        
        // Speed lines for impact
        float speedEffect = speedLines(vu, centerCP, slashDirection, progress, seed);
        
        // Apply colors with dramatic intensity
        float totalSlash = mainSlash + secondarySlashes;
        float fade = 1.0 - easeOut(progress);
        
        // Core slash - intense white/red
        if (totalSlash > 0.5) {
            newColor = mix(newColor, vec4(SLASH_WHITE, 0.9), clamp(totalSlash - 0.5, 0.0, 1.0) * fade);
        }
        
        // Main slash body - red/orange
        if (totalSlash > 0.1) {
            newColor = mix(newColor, vec4(SLASH_RED, 0.7), clamp(totalSlash - 0.1, 0.0, 0.4) * fade);
        }
        
        // Outer glow - orange
        if (totalSlash > 0.05) {
            newColor = mix(newColor, vec4(SLASH_ORANGE, 0.5), clamp(totalSlash - 0.05, 0.0, 0.2) * fade);
        }
        
        // Speed lines
        if (speedEffect > 0.0) {
            newColor = mix(newColor, vec4(SLASH_WHITE, 0.6), speedEffect * fade);
        }
    }
    
    // Draw current cursor
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    newColor = mix(newColor, vec4(CURSOR_COLOR, 0.8), antialising(sdfCurrentCursor));
    
    fragColor = newColor;
}