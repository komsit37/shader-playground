// Manga Slash Zen - Adaptive flowing lines with minimal text obstruction
// Smart line placement that avoids text areas during typing

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

// Smooth noise function
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

// Movement classification
bool isTyping(float distance, float verticalMovement) {
    return distance < 0.03 && verticalMovement < 0.02;
}

bool isNavigation(float distance) {
    return distance > 0.15;
}

// Zen flowing line - graceful, minimal obstruction
float zenFlowLine(vec2 p, vec2 start, vec2 end, float thickness, float time, float seed, bool avoidText) {
    vec2 direction = normalize(end - start);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    float totalLength = distance(start, end);
    
    if (totalLength < 0.001) return 0.0;
    
    vec2 localP = p - start;
    float alongPath = dot(localP, direction);
    float acrossPath = dot(localP, perpendicular);
    
    float t = clamp(alongPath / totalLength, 0.0, 1.0);
    
    // Graceful curve with minimal noise
    float curveOffset = sin(t * 8.0 + time * 2.0 + seed) * thickness * 0.3;
    
    // Text avoidance - create gaps in the line for typing
    float textAvoidance = 1.0;
    if (avoidText) {
        // Create gaps where text would be (horizontal strips)
        float textLineHeight = 0.04; // Approximate line height
        float textY = floor(p.y / textLineHeight) * textLineHeight;
        float distanceToTextLine = abs(p.y - textY);
        
        // Reduce line intensity near text baseline
        if (distanceToTextLine < textLineHeight * 0.3) {
            textAvoidance = 0.2; // Subtle hint instead of full line
        }
    }
    
    // Smooth, graceful line
    float lineIntensity = thickness / (abs(acrossPath - curveOffset) * 100.0 + 0.003);
    
    return lineIntensity * textAvoidance;
}

// Minimal speed lines for navigation
float zenSpeedLines(vec2 p, vec2 center, vec2 direction, float progress, float seed) {
    vec2 perpendicular = vec2(-direction.y, direction.x);
    
    float lines = 0.0;
    // Fewer, more elegant lines
    for (int i = 0; i < 3; i++) {
        float lineOffset = (float(i) - 1.0) * 0.025;
        vec2 lineStart = center + perpendicular * lineOffset;
        vec2 lineEnd = lineStart + direction * 0.08 * (1.0 - progress);
        
        float lineIntensity = zenFlowLine(p, lineStart, lineEnd, 0.001, 0.0, seed + float(i), false);
        lines += lineIntensity * (1.0 - progress) * 0.4;
    }
    
    return lines;
}

// Subtle glow effect for cursor
float zenGlow(vec2 p, vec2 center, float radius, float intensity) {
    float dist = distance(p, center);
    return exp(-dist * 50.0) * intensity;
}

// Easing functions
float easeOut(float t) {
    return 1.0 - (1.0 - t) * (1.0 - t);
}

float easeInOut(float t) {
    return t * t * (3.0 - 2.0 * t);
}

// Zen color palette - calming, non-distracting
const vec3 ZEN_BLUE = vec3(0.4, 0.7, 0.9);       // Calming blue
const vec3 ZEN_PURPLE = vec3(0.6, 0.5, 0.9);     // Gentle purple
const vec3 ZEN_TEAL = vec3(0.3, 0.8, 0.7);       // Soft teal
const vec3 ZEN_WHITE = vec3(0.9, 0.9, 0.95);     // Warm white
const vec3 CURSOR_COLOR = vec3(0.8, 0.8, 0.85);  // Subtle cursor

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
    float verticalMovement = abs(centerCC.y - centerCP.y);
    
    // Adaptive timing based on movement type
    float duration = isTyping(moveDistance, verticalMovement) ? 0.25 : 0.4;
    float progress = clamp((iTime - iTimeCursorChange) / duration, 0.0, 1.0);
    
    vec4 newColor = vec4(fragColor);
    
    // Show effects only with movement
    if (moveDistance > 0.001 && progress < 1.0) {
        vec2 direction = normalize(centerCC - centerCP);
        float seed = iTimeCursorChange;
        bool isTypingMode = isTyping(moveDistance, verticalMovement);
        bool isNavMode = isNavigation(moveDistance);
        
        // Adaptive effects based on movement type
        if (isTypingMode) {
            // Minimal, text-friendly effects for typing
            
            // Subtle cursor trail - very thin, text-aware
            float trailThickness = 0.003;
            float trailFlow = zenFlowLine(vu, centerCP, centerCC, trailThickness, iTime, seed, true);
            
            // Gentle fade with minimal opacity
            float fade = (1.0 - easeOut(progress)) * 0.3;
            
            // Soft teal color for typing
            if (trailFlow > 0.0) {
                newColor = mix(newColor, vec4(ZEN_TEAL, 0.4), trailFlow * fade);
            }
            
            // Minimal cursor glow
            float cursorGlow = zenGlow(vu, centerCC, 0.02, 0.2);
            newColor = mix(newColor, vec4(ZEN_TEAL, 0.3), cursorGlow * fade);
            
        } else if (isNavMode) {
            // More dramatic effects for navigation
            
            // Main flowing line - elegant, full visibility
            float mainFlow = zenFlowLine(vu, centerCP, centerCC, 0.008, iTime, seed, false);
            
            // Secondary flowing lines for dramatic effect
            float secondaryFlow = 0.0;
            vec2 perpendicular = vec2(-direction.y, direction.x);
            for (int i = 0; i < 2; i++) {
                float offset = (float(i) - 0.5) * moveDistance * 0.3;
                vec2 secStart = centerCP + perpendicular * offset;
                vec2 secEnd = centerCC + perpendicular * offset;
                
                secondaryFlow += zenFlowLine(vu, secStart, secEnd, 0.004, iTime, seed + float(i), false) * 0.6;
            }
            
            // Speed lines for navigation
            float speedEffect = zenSpeedLines(vu, centerCP, direction, progress, seed);
            
            // Rich fade for navigation
            float fade = (1.0 - easeOut(progress)) * 0.7;
            
            // Apply flowing colors
            float totalFlow = mainFlow + secondaryFlow;
            
            // Core flow - purple/blue gradient
            if (totalFlow > 0.3) {
                newColor = mix(newColor, vec4(ZEN_WHITE, 0.8), clamp(totalFlow - 0.3, 0.0, 0.5) * fade);
            }
            
            // Main flow - blue/purple
            if (totalFlow > 0.1) {
                newColor = mix(newColor, vec4(ZEN_PURPLE, 0.6), clamp(totalFlow - 0.1, 0.0, 0.4) * fade);
            }
            
            // Outer flow - blue
            if (totalFlow > 0.05) {
                newColor = mix(newColor, vec4(ZEN_BLUE, 0.5), clamp(totalFlow - 0.05, 0.0, 0.3) * fade);
            }
            
            // Speed lines
            if (speedEffect > 0.0) {
                newColor = mix(newColor, vec4(ZEN_WHITE, 0.6), speedEffect * fade);
            }
            
        } else {
            // Medium effects for small movements
            
            float mediumFlow = zenFlowLine(vu, centerCP, centerCC, 0.005, iTime, seed, false);
            float fade = (1.0 - easeOut(progress)) * 0.5;
            
            // Balanced blue effect
            if (mediumFlow > 0.0) {
                newColor = mix(newColor, vec4(ZEN_BLUE, 0.5), mediumFlow * fade);
            }
        }
    }
    
    // Draw current cursor with adaptive styling
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    
    // Cursor color adapts to movement type
    vec3 cursorColor = CURSOR_COLOR;
    if (isTyping(moveDistance, verticalMovement)) {
        cursorColor = ZEN_TEAL;
    } else if (isNavigation(moveDistance)) {
        cursorColor = ZEN_PURPLE;
    }
    
    newColor = mix(newColor, vec4(cursorColor, 0.8), antialising(sdfCurrentCursor));
    
    fragColor = newColor;
}