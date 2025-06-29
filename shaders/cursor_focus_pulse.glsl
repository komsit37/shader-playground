#include "ghostty_wrapper.glsl"

// A terminal-optimized cursor for focus and clarity.
// - When idle, it has a subtle, slow pulsing glow.
// - When moving, it has a soft, brighter glow to make tracking easy.
// Ideal for use in Neovim and tmux.

void main() {
    vec2 frag_coord = gl_FragCoord.xy;
    float dist_from_cursor = distance(frag_coord, u_cursor_pos);
    float movement = length(u_cursor_delta);

    vec3 color = vec3(0.0);

    // --- Static State: Subtle pulsing glow ---
    if (movement < 0.1) {
        float pulse_speed = 2.5;
        float pulse_min = 0.1;
        float pulse_max = 0.3;
        float pulse = (sin(u_time * pulse_speed) * 0.5 + 0.5) * (pulse_max - pulse_min) + pulse_min;

        float glow_size = u_cursor_size * 1.5;
        float falloff = smoothstep(glow_size, 0.0, dist_from_cursor);

        color = vec3(0.8, 0.8, 0.9) * falloff * pulse;
    }
    // --- Moving State: Soft motion glow ---
    else {
        // Make the glow stronger with more movement
        float intensity = clamp(movement / 15.0, 0.4, 1.2);

        float glow_size = u_cursor_size * 2.5;
        float falloff = smoothstep(glow_size, 0.0, dist_from_cursor);

        color = vec3(0.7, 0.8, 1.0) * falloff * intensity;
    }

    // Output as an additive color
    gl_FragColor = vec4(color, 1.0);
}
