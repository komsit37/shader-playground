float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Parallelogram SDF functions from cursor_smear
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

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
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

// iOS-style elastic bounce easing
float elasticOut(float t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    
    float c4 = (2.0 * 3.14159) / 3.0;
    return pow(2.0, -10.0 * t) * sin((t * 10.0 - 0.75) * c4) + 1.0;
}

// Combined elastic + bounce for iOS-like feel with distance-based intensity
float iOSBounce(float t, float intensity) {
    float overshoot = mix(1.05, 1.15, intensity); // Reduced overshoot range
    float settleSpeed = mix(0.7, 0.5, intensity); // Longer settle for bigger jumps
    
    if (t < settleSpeed) {
        return smoothstep(0.0, settleSpeed, t) * overshoot;
    } else {
        float elasticT = (t - settleSpeed) / (1.0 - settleSpeed);
        return overshoot - (overshoot - 1.0) * elasticOut(elasticT);
    }
}

const vec4 CURSOR_COLOR = vec4(0.2, 0.7, 1.0, 1.0);
const vec4 BOUNCE_GLOW = vec4(0.4, 0.8, 1.0, 0.3);
const vec4 TRAIL_COLOR = vec4(0.3, 0.8, 1.0, 0.8);
const float BASE_DURATION = 0.3; // Base duration for short jumps
const float MAX_DURATION = 0.7; // Maximum duration for long jumps
const float DISTANCE_SCALE = 0.5; // How much distance affects bounce intensity

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

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);
    
    // Calculate distance-based bounce intensity and duration
    float normalizedDistance = clamp(moveDistance * DISTANCE_SCALE, 0.0, 1.0);
    float bounceIntensity = normalizedDistance;
    float duration = mix(BASE_DURATION, MAX_DURATION, normalizedDistance);
    
    float progress = clamp((iTime - iTimeCursorChange) / duration, 0.0, 1.0);
    
    vec4 newColor = vec4(fragColor);
    
    // Draw parallelogram trail (similar to cursor_smear)
    if (moveDistance > 0.001 && progress < 1.0) {
        // Determine vertex placement for proper trail shape
        float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
        float invertedVertexFactor = 1.0 - vertexFactor;
        
        // Create parallelogram vertices connecting previous and current cursor positions
        vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
        vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
        vec2 v2 = vec2(previousCursor.x + previousCursor.z * invertedVertexFactor, previousCursor.y);
        vec2 v3 = vec2(previousCursor.x + previousCursor.z * vertexFactor, previousCursor.y - previousCursor.w);
        
        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);
        
        // Apply trail with distance-based snap fade
        float trailFadeSpeed = mix(2.5, 5.0, bounceIntensity); // Much faster fade for snappier feel
        float trailProgress = clamp(progress * trailFadeSpeed, 0.0, 1.0);
        float trailOpacity = (1.0 - trailProgress) * mix(0.5, 0.8, bounceIntensity); // More intense for longer jumps
        newColor = mix(newColor, TRAIL_COLOR, antialising(sdfTrail) * trailOpacity);
    }
    
    // Calculate animated cursor position with bounce
    vec2 animatedCursorCenter = centerCC;
    vec4 animatedCursor = currentCursor;
    
    if (moveDistance > 0.001 && progress < 1.0) {
        // Calculate bounce animation with distance-based intensity
        float bounceProgress = iOSBounce(progress, bounceIntensity);
        
        // Interpolate position with overshoot
        vec2 direction = normalize(centerCC - centerCP);
        vec2 targetPos = centerCP + (centerCC - centerCP) * bounceProgress;
        
        // Add distance-based overshoot in the movement direction
        float settleSpeed = mix(0.7, 0.5, bounceIntensity);
        if (progress < settleSpeed) {
            float overshoot = sin(progress * 3.14159 / settleSpeed) * mix(0.005, 0.015, bounceIntensity) * moveDistance;
            targetPos += direction * overshoot;
        }
        
        animatedCursorCenter = targetPos;
        animatedCursor.xy = targetPos - vec2(currentCursor.z * 0.5, -currentCursor.w * 0.5);
        
        // Add minimal bounce glow only during active animation
        if (progress < 0.8) {
            float glowRadius = 0.018;
            float glow = 1.0 / (distance(vu, animatedCursorCenter) / glowRadius + 1.0);
            glow *= (1.0 - progress) * 0.5; // Subtle fade out
            newColor = mix(newColor, BOUNCE_GLOW, clamp(glow * 0.15, 0.0, 1.0));
        }
    }
    
    // Draw animated cursor with bounce scaling
    float bounceScale = 1.0;
    if (progress < 1.0 && moveDistance > 0.001) {
        float scaleIntensity = mix(0.15, 0.4, bounceIntensity);
        bounceScale = (1.0 - scaleIntensity) + scaleIntensity * iOSBounce(progress, bounceIntensity);
    }
    
    vec4 scaledCursor = vec4(
        animatedCursor.xy,
        animatedCursor.z * bounceScale,
        animatedCursor.w * bounceScale
    );
    
    float sdfAnimatedCursor = getSdfRectangle(vu, scaledCursor.xy - (scaledCursor.zw * offsetFactor), scaledCursor.zw * 0.5);
    newColor = mix(newColor, CURSOR_COLOR, antialising(sdfAnimatedCursor));
    
    fragColor = newColor;
}
