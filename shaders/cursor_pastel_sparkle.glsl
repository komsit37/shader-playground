float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float getSdfCircle(in vec2 p, in vec2 center, float radius)
{
    return length(p - center) - radius;
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

float ease(float x) {
    return pow(1.0 - x, 4.0);
}

// Simple hash function for pseudo-random numbers
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Generate sparkle effect
float sparkle(vec2 p, float time, float scale) {
    vec2 gridPos = floor(p * scale);
    vec2 localPos = fract(p * scale) - 0.5;
    
    float random = hash(gridPos);
    float sparkleTime = fract(time * 0.5 + random * 10.0);
    
    // Create pulsing sparkle
    float pulse = smoothstep(0.0, 0.1, sparkleTime) * smoothstep(0.9, 0.8, sparkleTime);
    float sparkleSize = 0.15 + 0.1 * pulse;
    
    // Star shape approximation using cross pattern
    float cross1 = smoothstep(sparkleSize, sparkleSize * 0.5, abs(localPos.x)) * 
                   smoothstep(sparkleSize * 0.3, 0.0, abs(localPos.y));
    float cross2 = smoothstep(sparkleSize, sparkleSize * 0.5, abs(localPos.y)) * 
                   smoothstep(sparkleSize * 0.3, 0.0, abs(localPos.x));
    
    return max(cross1, cross2) * pulse;
}

// Pastel color palette
vec3 getPastelColor(float index) {
    float colorIndex = mod(index, 5.0);
    
    if (colorIndex < 1.0) {
        return vec3(1.0, 0.8, 0.9);  // Soft pink
    } else if (colorIndex < 2.0) {
        return vec3(0.9, 0.9, 1.0);  // Soft purple
    } else if (colorIndex < 3.0) {
        return vec3(0.8, 1.0, 0.9);  // Soft mint
    } else if (colorIndex < 4.0) {
        return vec3(1.0, 0.95, 0.8); // Soft yellow
    } else {
        return vec3(0.9, 0.8, 1.0);  // Soft lavender
    }
}

const float DURATION = 0.5;
const float SPARKLE_SCALE = 40.0;
const float TRAIL_SPARKLE_SCALE = 60.0;
const vec3 IDLE_COLOR = vec3(1.0, 0.8, 0.9); // Soft pink for idle cursor

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #else
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    #endif
    
    // Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    // Normalization for cursor position and size;
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    // Determine parallelogram vertices for trail
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);

    vec4 newColor = vec4(fragColor);
    
    // Cursor sparkle effect when idle or moving
    vec2 cursorCenter = currentCursor.xy - (currentCursor.zw * offsetFactor);
    float cursorRadius = max(currentCursor.z, currentCursor.w) * 0.3;
    float sdfCursorCircle = getSdfCircle(vu, cursorCenter, cursorRadius);
    
    // Create sparkle effect around cursor
    float cursorSparkles = sparkle(vu - cursorCenter, iTime, SPARKLE_SCALE);
    float cursorSparklesMask = 1.0 - smoothstep(0.0, cursorRadius * 1.5, abs(sdfCursorCircle));
    cursorSparkles *= cursorSparklesMask;
    
    // Show trail sparkles only if there was cursor movement and within duration
    if (moveDistance > 0.001 && progress < 1.0) {
        // Trail sparkles
        float trailSparkles = sparkle(vu, iTime - progress * 0.5, TRAIL_SPARKLE_SCALE);
        float trailMask = 1.0 - smoothstep(0.0, 0.02, abs(sdfTrail));
        trailSparkles *= trailMask * (1.0 - easedProgress);
        
        // Multiple pastel colors for trail sparkles
        vec3 trailColor = getPastelColor(floor(iTime * 2.0) + hash(vu) * 5.0);
        newColor = mix(newColor, vec4(trailColor, 0.6), trailSparkles);
        
        // Add cursor sparkles only during movement
        vec3 cursorSparkleColor = getPastelColor(floor(iTime * 1.5) + hash(cursorCenter) * 5.0);
        newColor = mix(newColor, vec4(cursorSparkleColor, 0.8), cursorSparkles * (1.0 - easedProgress));
    }
    
    // Draw current cursor with soft pink color
    vec4 cursorColor = vec4(IDLE_COLOR, 0.7);
    newColor = mix(newColor, cursorColor, antialising(sdfCurrentCursor));
    
    fragColor = newColor;
}