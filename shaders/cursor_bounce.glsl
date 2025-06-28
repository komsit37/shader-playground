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

// iOS-style elastic bounce easing
float elasticOut(float t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    
    float c4 = (2.0 * 3.14159) / 3.0;
    return pow(2.0, -10.0 * t) * sin((t * 10.0 - 0.75) * c4) + 1.0;
}

// Bounce easing function (similar to CSS cubic-bezier)
float bounceOut(float t) {
    if (t < 1.0 / 2.75) {
        return 7.5625 * t * t;
    } else if (t < 2.0 / 2.75) {
        t -= 1.5 / 2.75;
        return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) {
        t -= 2.25 / 2.75;
        return 7.5625 * t * t + 0.9375;
    } else {
        t -= 2.625 / 2.75;
        return 7.5625 * t * t + 0.984375;
    }
}

// Combined elastic + bounce for iOS-like feel
float iOSBounce(float t) {
    // Quick initial movement then elastic settling
    if (t < 0.6) {
        return smoothstep(0.0, 0.6, t) * 1.1; // Overshoot to 110%
    } else {
        float elasticT = (t - 0.6) / 0.4;
        return 1.1 - 0.1 * elasticOut(elasticT); // Settle back to 100%
    }
}

// Generate trail particles with bounce physics
float getTrailParticle(vec2 pos, vec2 center, float size, float timeOffset, float progress) {
    // Each particle bounces at different times
    float particleProgress = clamp(progress - timeOffset, 0.0, 1.0);
    float bounceAmount = iOSBounce(particleProgress);
    
    // Scale particle based on bounce
    float particleSize = size * (0.3 + 0.7 * bounceAmount);
    float distance = length(pos - center);
    
    // Fade out over time
    float alpha = (1.0 - particleProgress) * bounceAmount;
    
    return alpha / (distance / particleSize + 1.0);
}

const vec4 CURSOR_COLOR = vec4(0.2, 0.7, 1.0, 1.0);
const vec4 BOUNCE_COLOR = vec4(0.4, 0.8, 1.0, 0.8);
const vec4 TRAIL_COLOR = vec4(0.6, 0.9, 1.0, 0.6);
const float DURATION = 0.8; // Longer for bounce effect
const float BOUNCE_INTENSITY = 1.5; // How much cursor overshoots
const int NUM_TRAIL_PARTICLES = 8;

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
    
    // Calculate animated cursor position with bounce
    vec2 animatedCursorCenter = centerCC;
    vec4 animatedCursor = currentCursor;
    
    if (moveDistance > 0.001 && progress < 1.0) {
        // Calculate bounce animation
        float bounceProgress = iOSBounce(progress);
        
        // Interpolate position with overshoot
        vec2 direction = normalize(centerCC - centerCP);
        vec2 targetPos = centerCP + (centerCC - centerCP) * bounceProgress;
        
        // Add slight overshoot in the movement direction
        if (progress < 0.6) {
            float overshoot = sin(progress * 3.14159 / 0.6) * 0.02 * moveDistance;
            targetPos += direction * overshoot;
        }
        
        animatedCursorCenter = targetPos;
        animatedCursor.xy = targetPos - vec2(currentCursor.z * 0.5, -currentCursor.w * 0.5);
        
        // Create bouncing trail particles
        for (int i = 0; i < NUM_TRAIL_PARTICLES; i++) {
            float t = float(i) / float(NUM_TRAIL_PARTICLES - 1);
            vec2 trailPos = mix(centerCP, centerCC, t);
            float timeOffset = t * 0.3; // Stagger particle animations
            
            float particle = getTrailParticle(vu, trailPos, 0.015, timeOffset, progress);
            newColor = mix(newColor, TRAIL_COLOR, clamp(particle * 0.4, 0.0, 1.0));
        }
        
        // Add bounce glow around animated cursor
        float glowRadius = 0.02 + 0.01 * sin(progress * 12.0); // Subtle pulsing
        float glow = 1.0 / (distance(vu, animatedCursorCenter) / glowRadius + 1.0);
        glow *= (1.0 - progress * 0.7); // Fade out glow
        newColor = mix(newColor, BOUNCE_COLOR, clamp(glow * 0.2, 0.0, 1.0));
    }
    
    // Draw animated cursor with bounce scaling
    float bounceScale = 1.0;
    if (progress < 1.0 && moveDistance > 0.001) {
        bounceScale = 0.8 + 0.4 * iOSBounce(progress); // Scale between 80% and 120%
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