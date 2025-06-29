// Manga Slash Storm - Fully adaptive manga effects combining all techniques
// Most intelligent variant that adapts to user behavior patterns

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

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// Hash and noise functions
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Advanced movement classification
const float TYPING_DISTANCE = 0.03;
const float NEAR_JUMP_DISTANCE = 0.15;
const float FAR_JUMP_DISTANCE = 0.4;
const float FAST_TYPING_TIME = 0.08;
const float VERTICAL_THRESHOLD = 0.02;

// Digital dissolve slash fragment (for typing)
float dissolveSlashFragment(vec2 pos, vec2 center, float size, float randomSeed, float progress) {
    vec2 offset = vec2(
        noise(center * 12.0 + randomSeed) - 0.5,
        noise(center * 18.0 + randomSeed + 50.0) - 0.5
    ) * 0.06 * progress;
    
    vec2 fragmentPos = center + offset;
    float alpha = progress < 0.7 ? (1.0 - progress * 1.4) : 0.0;
    
    // Jagged slash fragment
    vec2 localPos = pos - fragmentPos;
    float angle = atan(localPos.y, localPos.x);
    float jaggedRadius = size * (0.8 + 0.4 * sin(angle * 8.0 + randomSeed));
    
    if (distance(pos, fragmentPos) < jaggedRadius) {
        return alpha;
    }
    return 0.0;
}

// Flowing slash line (for navigation)
float flowingSlashLine(vec2 p, vec2 start, vec2 end, float thickness, float time, float seed, float intensity) {
    vec2 direction = normalize(end - start);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    float totalLength = distance(start, end);
    
    if (totalLength < 0.001) return 0.0;
    
    vec2 localP = p - start;
    float alongPath = dot(localP, direction);
    float acrossPath = dot(localP, perpendicular);
    float t = clamp(alongPath / totalLength, 0.0, 1.0);
    
    // Dynamic slash with multiple layers
    float waveOffset = sin(t * 15.0 + time * 5.0 + seed) * thickness * intensity;
    float mainSlash = thickness * intensity / (abs(acrossPath - waveOffset) * 60.0 + 0.002);
    
    // Secondary jagged edges
    float jaggedSlash = 0.0;
    for (int i = 0; i < 3; i++) {
        float offset = (float(i) - 1.0) * thickness * 0.5;
        float jaggedWave = sin(t * 20.0 + float(i) * 2.0 + seed) * thickness * 0.3 * intensity;
        jaggedSlash += thickness * 0.8 / (abs(acrossPath - offset - jaggedWave) * 80.0 + 0.003);
    }
    
    return mainSlash + jaggedSlash;
}

// Speed burst effect (for fast actions)
float speedBurst(vec2 p, vec2 center, vec2 direction, float progress, float intensity, float seed) {
    vec2 perpendicular = vec2(-direction.y, direction.x);
    
    float burst = 0.0;
    int lineCount = int(intensity * 6.0) + 3;
    
    for (int i = 0; i < 8; i++) {
        if (i >= lineCount) break;
        
        float angleOffset = (float(i) - float(lineCount) * 0.5) * 0.3;
        vec2 burstDir = direction * cos(angleOffset) + perpendicular * sin(angleOffset);
        
        vec2 lineStart = center;
        vec2 lineEnd = center + burstDir * 0.12 * intensity * (1.0 - progress);
        
        float lineIntensity = flowingSlashLine(p, lineStart, lineEnd, 0.002, 0.0, seed + float(i), intensity);
        burst += lineIntensity * (1.0 - progress) * 0.4;
    }
    
    return burst;
}

// Ripple effect for search/jump actions
float searchRipple(vec2 p, vec2 center, float time, float progress, float intensity) {
    float dist = distance(p, center);
    float ripple = 0.0;
    
    for (int i = 0; i < 3; i++) {
        float rippleTime = time - float(i) * 0.08;
        if (rippleTime > 0.0) {
            float rippleRadius = rippleTime * intensity * 0.4;
            float rippleDist = abs(dist - rippleRadius);
            ripple += (1.0 / (rippleDist * 200.0 + 0.01)) * max(0.0, 1.0 - rippleTime / 0.3);
        }
    }
    
    return ripple;
}

// Easing functions
float easeOut(float t) { return 1.0 - (1.0 - t) * (1.0 - t); }
float easeInOut(float t) { return t * t * (3.0 - 2.0 * t); }
float easeOutQuart(float t) { return 1.0 - pow(1.0 - t, 4.0); }

// Adaptive color palette
const vec3 TYPING_COLOR = vec3(0.3, 0.8, 0.6);        // Calm green for typing
const vec3 FAST_TYPING_COLOR = vec3(0.4, 0.9, 1.0);   // Bright cyan for fast typing
const vec3 EDIT_COLOR = vec3(1.0, 0.4, 0.3);          // Red for editing
const vec3 NAV_COLOR = vec3(0.7, 0.5, 1.0);           // Purple for navigation
const vec3 SEARCH_COLOR = vec3(0.2, 0.7, 1.0);        // Blue for search
const vec3 SLASH_CORE = vec3(1.0, 0.95, 0.9);         // Hot white core
const vec3 CURSOR_DEFAULT = vec3(0.9, 0.9, 0.9);      // Default cursor

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

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);
    float timeDelta = iTime - iTimeCursorChange;
    float velocity = moveDistance / max(timeDelta, 0.001);
    float verticalMovement = abs(centerCC.y - centerCP.y);
    float horizontalMovement = abs(centerCC.x - centerCP.x);
    
    // Advanced movement classification
    bool isTyping = moveDistance < TYPING_DISTANCE && verticalMovement < VERTICAL_THRESHOLD;
    bool isFastTyping = isTyping && timeDelta < FAST_TYPING_TIME;
    bool isSlowTyping = isTyping && timeDelta > 0.2;
    bool isEditing = moveDistance < NEAR_JUMP_DISTANCE && timeDelta < 0.15;
    bool isNearJump = moveDistance > TYPING_DISTANCE && moveDistance < NEAR_JUMP_DISTANCE;
    bool isFarJump = moveDistance > FAR_JUMP_DISTANCE;
    bool isVerticalNav = verticalMovement > horizontalMovement && moveDistance > TYPING_DISTANCE;
    bool isSearching = isFarJump && velocity > 3.0;
    
    // Adaptive timing and intensity
    float baseDuration = 0.35;
    float duration = isTyping ? 0.25 : (isFarJump ? 0.5 : baseDuration);
    float progress = clamp((iTime - iTimeCursorChange) / duration, 0.0, 1.0);
    float intensity = isTyping ? 0.6 : (isFarJump ? 1.2 : 1.0);
    
    vec4 newColor = vec4(fragColor);
    vec3 effectColor = vec3(0.0);
    float effectAlpha = 0.0;
    
    if (moveDistance > 0.001 && progress < 1.0) {
        vec2 direction = normalize(centerCC - centerCP);
        float seed = iTimeCursorChange;
        
        // TYPING EFFECTS
        if (isTyping) {
            if (isFastTyping) {
                // Fast typing: Digital dissolve fragments at previous position
                for (int i = 0; i < 8; i++) {
                    float angle = float(i) * 0.785; // 45 degree intervals
                    vec2 fragmentCenter = centerCP + vec2(cos(angle), sin(angle)) * moveDistance * 2.0;
                    
                    float fragment = dissolveSlashFragment(vu, fragmentCenter, 0.006, seed + float(i), progress);
                    if (fragment > 0.0) {
                        effectColor = FAST_TYPING_COLOR;
                        effectAlpha += fragment * 0.4;
                    }
                }
                
                // Speed burst for very fast typing
                if (velocity > 10.0) {
                    float burst = speedBurst(vu, centerCP, direction, progress, 0.8, seed);
                    effectColor = mix(effectColor, SLASH_CORE, 0.3);
                    effectAlpha += burst * 0.5;
                }
            } else {
                // Normal typing: Subtle flowing trail
                float flow = flowingSlashLine(vu, centerCP, centerCC, 0.004, iTime, seed, 0.5);
                effectColor = TYPING_COLOR;
                effectAlpha = flow * (1.0 - easeOut(progress)) * 0.3;
            }
        }
        
        // EDITING EFFECTS
        else if (isEditing) {
            // Correction slash with pulsing
            float editFlow = flowingSlashLine(vu, centerCP, centerCC, 0.008, iTime, seed, 1.2);
            float pulse = sin(iTime * 12.0) * 0.3 + 0.7;
            
            effectColor = EDIT_COLOR;
            effectAlpha = editFlow * (1.0 - easeInOut(progress)) * pulse * 0.6;
            
            // Correction sparks
            for (int i = 0; i < 4; i++) {
                float sparkAngle = float(i) * 1.57 + iTime * 3.0;
                vec2 sparkPos = centerCP + vec2(cos(sparkAngle), sin(sparkAngle)) * 0.02;
                float spark = 1.0 / (distance(vu, sparkPos) * 300.0 + 0.01);
                effectAlpha += spark * (1.0 - progress) * 0.2;
            }
        }
        
        // NAVIGATION EFFECTS
        else if (isSearching) {
            // Search: Ripple effect with dramatic slash
            float ripple = searchRipple(vu, centerCC, timeDelta, progress, 2.0);
            float mainSlash = flowingSlashLine(vu, centerCP, centerCC, 0.012, iTime, seed, 1.5);
            
            effectColor = SEARCH_COLOR;
            effectAlpha = (ripple * 0.3 + mainSlash * 0.7) * (1.0 - easeOutQuart(progress));
            
            // Search burst
            float burst = speedBurst(vu, centerCC, direction, progress, 1.0, seed);
            effectColor = mix(effectColor, SLASH_CORE, burst * 0.4);
            effectAlpha += burst * 0.4;
        }
        
        else if (isVerticalNav) {
            // Vertical navigation: Flowing vertical lines
            float mainFlow = flowingSlashLine(vu, centerCP, centerCC, 0.010, iTime, seed, 1.0);
            
            // Additional vertical flow lines
            vec2 perpendicular = vec2(-direction.y, direction.x);
            for (int i = 0; i < 3; i++) {
                float offset = (float(i) - 1.0) * moveDistance * 0.2;
                vec2 flowStart = centerCP + perpendicular * offset;
                vec2 flowEnd = centerCC + perpendicular * offset;
                mainFlow += flowingSlashLine(vu, flowStart, flowEnd, 0.006, iTime, seed + float(i), 0.7) * 0.6;
            }
            
            effectColor = NAV_COLOR;
            effectAlpha = mainFlow * (1.0 - easeOut(progress)) * 0.8;
        }
        
        else if (isFarJump) {
            // Long jump: Dramatic slash with speed lines
            float mainSlash = flowingSlashLine(vu, centerCP, centerCC, 0.015, iTime, seed, 1.3);
            float speedEffect = speedBurst(vu, centerCP, direction, progress, 1.0, seed);
            
            effectColor = NAV_COLOR;
            effectAlpha = (mainSlash + speedEffect) * (1.0 - easeOut(progress)) * 0.9;
            
            // Core intensity
            if (effectAlpha > 0.5) {
                effectColor = mix(effectColor, SLASH_CORE, (effectAlpha - 0.5) * 2.0);
            }
        }
        
        else if (isNearJump) {
            // Near jump: Moderate flowing effect
            float flow = flowingSlashLine(vu, centerCP, centerCC, 0.008, iTime, seed, 0.8);
            effectColor = mix(NAV_COLOR, TYPING_COLOR, 0.5);
            effectAlpha = flow * (1.0 - easeOut(progress)) * 0.6;
        }
    }
    
    // Apply effects
    if (effectAlpha > 0.0) {
        newColor = mix(newColor, vec4(effectColor, 1.0), clamp(effectAlpha, 0.0, 0.9));
    }
    
    // Adaptive cursor
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    
    vec3 cursorColor = CURSOR_DEFAULT;
    if (isFastTyping) cursorColor = FAST_TYPING_COLOR;
    else if (isTyping) cursorColor = TYPING_COLOR;
    else if (isEditing) cursorColor = EDIT_COLOR;
    else if (isSearching) cursorColor = SEARCH_COLOR;
    else if (isVerticalNav || isFarJump) cursorColor = NAV_COLOR;
    
    newColor = mix(newColor, vec4(cursorColor, 0.9), antialising(sdfCurrentCursor));
    
    fragColor = newColor;
}