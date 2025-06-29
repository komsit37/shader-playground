// Adaptive Cursor Shader - Contextual Effects Based on User Behavior
// Analyzes movement patterns to provide intelligent visual feedback

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float getSdfCircle(in vec2 p, in vec2 center, float radius) {
    return distance(p, center) - radius;
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialiasing(float distance) {
    return 1.0 - smoothstep(0.0, normalize(vec2(2.0, 2.0), 0.0).x, distance);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.0), rectangle.y - (rectangle.w / 2.0));
}

// HSV to RGB conversion
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Smooth noise function for organic effects
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Glow effect function
float glow(float distance, float radius, float intensity) {
    return pow(radius / max(distance, 0.001), intensity);
}

// Smooth easing functions
float easeOutCubic(float x) {
    return 1.0 - pow(1.0 - x, 3.0);
}

float easeInOutQuart(float x) {
    return x < 0.5 ? 8.0 * x * x * x * x : 1.0 - pow(-2.0 * x + 2.0, 4.0) / 2.0;
}

// Movement classification thresholds
const float TYPING_DISTANCE = 0.03;    // Character width threshold
const float NEAR_JUMP_DISTANCE = 0.15; // Small navigation
const float FAR_JUMP_DISTANCE = 0.4;   // Large navigation
const float FAST_TYPING_TIME = 0.08;   // Fast typing threshold
const float SLOW_TYPING_TIME = 0.3;    // Slow/deliberate typing
const float VERTICAL_THRESHOLD = 0.02; // Line change detection

// Effect parameters
const float TYPING_GLOW_RADIUS = 0.006;
const float TYPING_INTENSITY = 1.2;
const float EDIT_PULSE_FREQ = 8.0;
const float SEARCH_RIPPLE_SPEED = 2.0;
const float NAVIGATION_TRAIL_WIDTH = 0.012;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    // Normalize coordinates
    vec2 vu = normalize(fragCoord, 1.0);
    vec2 offsetFactor = vec2(-0.5, 0.5);
    
    // Normalize cursor data
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.0), normalize(iCurrentCursor.zw, 0.0));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.0), normalize(iPreviousCursor.zw, 0.0));
    
    // Calculate movement characteristics
    vec2 centerCurrent = getRectangleCenter(currentCursor);
    vec2 centerPrevious = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCurrent, centerPrevious);
    float timeDelta = iTime - iTimeCursorChange;
    float velocity = moveDistance / max(timeDelta, 0.001);
    float verticalMovement = abs(centerCurrent.y - centerPrevious.y);
    float horizontalMovement = abs(centerCurrent.x - centerPrevious.x);
    
    // Movement classification
    bool isTyping = moveDistance < TYPING_DISTANCE && verticalMovement < VERTICAL_THRESHOLD;
    bool isFastTyping = isTyping && timeDelta < FAST_TYPING_TIME;
    bool isSlowTyping = isTyping && timeDelta > SLOW_TYPING_TIME;
    bool isNearJump = moveDistance > TYPING_DISTANCE && moveDistance < NEAR_JUMP_DISTANCE;
    bool isFarJump = moveDistance > FAR_JUMP_DISTANCE;
    bool isVerticalNav = verticalMovement > horizontalMovement && moveDistance > TYPING_DISTANCE;
    bool isEditing = moveDistance < NEAR_JUMP_DISTANCE && timeDelta < 0.15; // Quick corrections
    bool isSearching = isFarJump && velocity > 2.0; // Fast long jumps (search results)
    
    // Base cursor SDF - use the same positioning as other working shaders
    float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    
    vec4 newColor = vec4(fragColor);
    vec3 effectColor = vec3(0.0);
    float effectAlpha = 0.0;
    
    // ===== TYPING EFFECTS =====
    if (isTyping && moveDistance > 0.001) {
        float typingProgress = clamp(timeDelta / 0.25, 0.0, 1.0);
        float fade = 1.0 - easeOutCubic(typingProgress);
        
        if (isFastTyping) {
            // Intense blue-white glow for fast typing
            float intensity = TYPING_INTENSITY * 1.5;
            float glowEffect = glow(abs(sdfCursor), TYPING_GLOW_RADIUS, intensity);
            effectColor = mix(vec3(0.3, 0.7, 1.0), vec3(1.0, 1.0, 1.0), velocity * 0.3);
            effectAlpha = glowEffect * fade * 0.8;
            
            // Add subtle ripple rings for very fast typing
            if (velocity > 8.0) {
                float ringDistance = getSdfCircle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), 0.02 + timeDelta * 0.15);
                float ring = 1.0 - smoothstep(-0.002, 0.002, abs(ringDistance));
                effectAlpha += ring * fade * 0.3;
            }
        } else if (isSlowTyping) {
            // Gentle green glow for deliberate typing
            float glowEffect = glow(abs(sdfCursor), TYPING_GLOW_RADIUS * 0.8, TYPING_INTENSITY * 0.7);
            effectColor = vec3(0.2, 0.8, 0.4);
            effectAlpha = glowEffect * fade * 0.4;
        } else {
            // Standard typing - yellow/orange glow
            float glowEffect = glow(abs(sdfCursor), TYPING_GLOW_RADIUS, TYPING_INTENSITY);
            effectColor = vec3(1.0, 0.8, 0.2);
            effectAlpha = glowEffect * fade * 0.6;
        }
    }
    
    // ===== EDITING/CORRECTION EFFECTS =====
    else if (isEditing) {
        float editProgress = clamp(timeDelta / 0.2, 0.0, 1.0);
        float pulse = sin(iTime * EDIT_PULSE_FREQ) * 0.5 + 0.5;
        float fade = 1.0 - easeInOutQuart(editProgress);
        
        // Red pulsing glow for corrections/edits
        float glowEffect = glow(abs(sdfCursor), TYPING_GLOW_RADIUS * 1.2, TYPING_INTENSITY);
        effectColor = vec3(1.0, 0.3, 0.2);
        effectAlpha = glowEffect * fade * (0.5 + pulse * 0.3);
        
        // Add correction trail
        vec2 trailVec = centerCurrent - centerPrevious;
        vec2 perpendicular = normalize(vec2(-trailVec.y, trailVec.x)) * 0.003;
        for (int i = 0; i < 3; i++) {
            float t = float(i) / 2.0;
            vec2 trailPoint = mix(centerPrevious, centerCurrent, t);
            float trailSdf = getSdfCircle(vu, trailPoint + perpendicular * sin(t * 6.0), 0.002);
            effectAlpha += antialiasing(trailSdf) * fade * 0.2;
        }
    }
    
    // ===== NAVIGATION EFFECTS =====
    else if (isNearJump || isFarJump) {
        float navProgress = clamp(timeDelta / 0.4, 0.0, 1.0);
        float fade = 1.0 - easeOutCubic(navProgress);
        
        if (isSearching) {
            // Cyan ripple effect for search navigation
            effectColor = vec3(0.0, 0.8, 1.0);
            
            // Multiple expanding ripples
            for (int i = 0; i < 3; i++) {
                float rippleTime = timeDelta - float(i) * 0.1;
                if (rippleTime > 0.0) {
                    float rippleRadius = rippleTime * SEARCH_RIPPLE_SPEED * 0.3;
                    float rippleDistance = getSdfCircle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), rippleRadius);
                    float ripple = 1.0 - smoothstep(-0.003, 0.003, abs(rippleDistance));
                    effectAlpha += ripple * max(0.0, 1.0 - rippleTime / 0.4) * 0.4;
                }
            }
        } else if (isVerticalNav) {
            // Purple trail for vertical navigation (scrolling, line jumps)
            effectColor = vec3(0.8, 0.4, 1.0);
            
            // Vertical motion lines
            vec2 direction = normalize(centerCurrent - centerPrevious);
            for (int i = 0; i < 5; i++) {
                float t = float(i) / 4.0;
                vec2 linePoint = mix(centerPrevious, centerCurrent, t);
                float lineSdf = getSdfRectangle(vu, linePoint, vec2(0.001, moveDistance * 0.1));
                effectAlpha += antialiasing(lineSdf) * fade * 0.3;
            }
        } else {
            // Orange arrow trail for horizontal navigation
            effectColor = vec3(1.0, 0.6, 0.0);
            
            // Direction arrow effect
            vec2 direction = normalize(centerCurrent - centerPrevious);
            vec2 arrowHead = centerCurrent;
            vec2 arrowTail = centerCurrent - direction * min(moveDistance, 0.05);
            
            // Arrow shaft
            float shaftSdf = getSdfRectangle(vu, (arrowHead + arrowTail) * 0.5, 
                                          vec2(NAVIGATION_TRAIL_WIDTH * 0.5, distance(arrowHead, arrowTail) * 0.5));
            effectAlpha += antialiasing(shaftSdf) * fade * 0.5;
            
            // Arrow head (triangle approximation with circles)
            for (int i = 0; i < 3; i++) {
                vec2 headOffset = direction * float(i) * 0.005;
                float headSize = 0.008 - float(i) * 0.002;
                float headSdf = getSdfCircle(vu, arrowHead - headOffset, headSize);
                effectAlpha += antialiasing(headSdf) * fade * 0.6;
            }
        }
    }
    
    // ===== APPLY EFFECTS =====
    if (effectAlpha > 0.0) {
        newColor = mix(newColor, vec4(effectColor, 1.0), effectAlpha);
    }
    
    // ===== DRAW CURSOR =====
    // Adaptive cursor color based on current activity
    vec3 cursorColor = vec3(0.9, 0.9, 0.9); // Default
    if (isTyping) {
        cursorColor = isFastTyping ? vec3(0.7, 0.9, 1.0) : 
                     isSlowTyping ? vec3(0.6, 1.0, 0.7) : vec3(1.0, 0.9, 0.6);
    } else if (isEditing) {
        cursorColor = vec3(1.0, 0.6, 0.5);
    } else if (isSearching) {
        cursorColor = vec3(0.5, 0.9, 1.0);
    } else if (isVerticalNav) {
        cursorColor = vec3(0.9, 0.7, 1.0);
    } else if (isNearJump || isFarJump) {
        cursorColor = vec3(1.0, 0.8, 0.4);
    }
    
    // Cursor opacity based on activity level
    float cursorOpacity = 0.7;
    if (isFastTyping) cursorOpacity = 0.9;
    else if (isEditing) cursorOpacity = 0.8;
    else if (isSearching) cursorOpacity = 0.85;
    
    newColor = mix(newColor, vec4(cursorColor, cursorOpacity), antialiasing(sdfCursor));
    
    fragColor = newColor;
}