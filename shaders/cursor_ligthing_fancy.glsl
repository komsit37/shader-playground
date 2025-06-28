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

float ease(float x) {
    return pow(1.0 - x, 4.0); // Sharper fade
}

float glow(float distance, float radius, float intensity) {
    return pow(radius / distance, intensity);
}

// Random function for generating jagged lightning
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Generate lightning bolt path
float lightningBolt(vec2 p, vec2 start, vec2 end, float time, float seed) {
    vec2 direction = normalize(end - start);
    vec2 perpendicular = vec2(-direction.y, direction.x);
    
    float totalLength = distance(start, end);
    vec2 localP = p - start;
    
    // Project point onto main direction
    float alongPath = dot(localP, direction);
    float acrossPath = dot(localP, perpendicular);
    
    // Normalize position along path (0 to 1)
    float t = clamp(alongPath / totalLength, 0.0, 1.0);
    
    // Create jagged displacement using multiple octaves of noise
    float displacement = 0.0;
    float amplitude = 0.015;
    float frequency = 8.0;
    
    for (int i = 0; i < 4; i++) {
        float noise = random(vec2(t * frequency + seed, float(i) + seed)) - 0.5;
        displacement += noise * amplitude;
        amplitude *= 0.6;
        frequency *= 2.0;
    }
    
    // Add time-based flicker
    displacement *= (0.8 + 0.4 * sin(time * 25.0 + seed * 10.0));
    
    // Distance from jagged lightning path
    float distanceFromPath = abs(acrossPath - displacement);
    
    // Create multiple lightning branches
    float mainBolt = 1.0 / (distanceFromPath * 400.0 + 1.0);
    
    // Add secondary branches
    float branch1 = 0.0;
    float branch2 = 0.0;
    
    if (t > 0.3 && t < 0.7) {
        vec2 branchDir1 = normalize(direction + perpendicular * 0.8);
        float branchDisp1 = sin(t * 15.0 + seed) * 0.008;
        float branchDist1 = abs(dot(localP - direction * totalLength * 0.5, vec2(-branchDir1.y, branchDir1.x)) - branchDisp1);
        branch1 = 0.3 / (branchDist1 * 600.0 + 1.0);
    }
    
    if (t > 0.2 && t < 0.8) {
        vec2 branchDir2 = normalize(direction - perpendicular * 0.6);
        float branchDisp2 = cos(t * 12.0 + seed * 1.5) * 0.006;
        float branchDist2 = abs(dot(localP - direction * totalLength * 0.6, vec2(-branchDir2.y, branchDir2.x)) - branchDisp2);
        branch2 = 0.2 / (branchDist2 * 800.0 + 1.0);
    }
    
    return mainBolt + branch1 + branch2;
}

const vec4 CURSOR_COLOR = vec4(0.9, 0.9, 1.0, 1.0);
const vec4 LIGHTNING_COLOR = vec4(0.6, 0.8, 1.0, 1.0);
const vec4 GLOW_COLOR = vec4(0.3, 0.6, 1.0, 0.8);
const float DURATION = 0.25; // Fast fade for rapid typing
const float GLOW_RADIUS = 0.012;
const float GLOW_INTENSITY = 1.2;

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

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    
    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float moveDistance = distance(centerCC, centerCP);
    
    vec4 newColor = vec4(fragColor);
    
    // Only show lightning if there was significant cursor movement
    if (moveDistance > 0.001 && progress < 1.0) {
        float easedProgress = ease(progress);
        float seed = iTimeCursorChange; // Use time as seed for consistent bolt pattern
        
        // Generate lightning bolt
        float lightning = lightningBolt(vu, centerCP, centerCC, iTime, seed);
        
        // Fade lightning over time
        lightning *= (1.0 - easedProgress);
        
        // Add electric blue lightning
        newColor = mix(newColor, LIGHTNING_COLOR, clamp(lightning, 0.0, 1.0));
        
        // Add glow effect around lightning path
        if (lightning > 0.01) {
            float glowIntensity = glow(1.0 / (lightning + 0.1), GLOW_RADIUS, GLOW_INTENSITY);
            glowIntensity *= (1.0 - easedProgress) * 0.3;
            newColor = mix(newColor, GLOW_COLOR, clamp(glowIntensity, 0.0, 1.0));
        }
    }
    
    // Draw current cursor with electric glow
    float cursorGlow = glow(abs(sdfCurrentCursor), GLOW_RADIUS * 0.8, GLOW_INTENSITY * 0.7);
    newColor = mix(newColor, CURSOR_COLOR * 0.8, antialising(sdfCurrentCursor));
    newColor = mix(newColor, GLOW_COLOR, clamp(cursorGlow * 0.1, 0.0, 1.0));
    
    fragColor = newColor;
}