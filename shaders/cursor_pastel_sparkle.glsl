#include "ghostty_wrapper.glsl"

// A cute, sparkling cursor with a pastel color palette.
// - When idle, it has a soft, continuous sparkle.
// - When moving, it leaves a trail of twinkling pastel particles.

// Helper function for random values
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
    vec2 frag_coord = gl_FragCoord.xy;
    float dist_from_cursor = distance(frag_coord, u_cursor_pos);
    float movement = length(u_cursor_delta);

    vec3 color = vec3(0.0);

    // --- Base Cursor Shape ---
    float base_size = u_cursor_size * 0.8;
    float base_falloff = smoothstep(base_size, 0.0, dist_from_cursor);
    vec3 base_color = vec3(1.0, 0.7, 0.85); // Soft pink
    color += base_color * base_falloff;

    // --- Sparkle Effect ---
    float time = u_time * 2.0;
    vec2 sparkle_coord = frag_coord + vec2(sin(time), cos(time)) * 5.0;
    float sparkle_rand = rand(floor(sparkle_coord / 8.0) * 8.0);

    if (sparkle_rand > 0.95) {
        float sparkle_dist = distance(frag_coord, u_cursor_pos + vec2(rand(frag_coord.xy) - 0.5, rand(frag_coord.yx) - 0.5) * 15.0);
        float sparkle_size = 2.0 + (sin(time + sparkle_rand * 10.0) * 0.5 + 0.5) * 2.0;
        float sparkle_falloff = smoothstep(sparkle_size, 0.0, sparkle_dist);
        color += vec3(1.0, 1.0, 0.8) * sparkle_falloff;
    }

    // --- Motion Trail ---
    if (movement > 0.1) {
        for (int i = 1; i <= 3; i++) {
            float step = float(i) * 0.15;
            vec2 past_pos = u_cursor_pos - u_cursor_delta * step;
            float trail_dist = distance(frag_coord, past_pos);

            float trail_rand = rand(floor(past_pos / 8.0) * 8.0);
            float trail_size = (3.0 - float(i)) * 1.5;
            float trail_falloff = smoothstep(trail_size, 0.0, trail_dist);

            vec3 trail_color = vec3(0.7, 0.8, 1.0); // Pastel blue
            if (trail_rand > 0.66) trail_color = vec3(1.0, 0.9, 0.7); // Pastel yellow
            if (trail_rand > 0.33) trail_color = vec3(1.0, 0.7, 0.85); // Pastel pink

            color += trail_color * trail_falloff * (1.0 - step * 2.0);
        }
    }

    gl_FragColor = vec4(color, 1.0);
}
