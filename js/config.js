// Shader configuration and constants
export const SHADER_NAMES = [
  "cursor_ligthing",
  "cursor_ligthing_fancy",
  "cursor_rainbow",
  "cursor_bounce",
  "cursor_bounce_clean",
  "cursor_digital_dissolve",
  "cursor_pastel_sparkle",
  "cursor_focus_pulse",
  "cursor_manga_slash"
];

export const CONFIG = {
  // Animation timing
  INTERVAL: 1000,

  // Default cursor settings
  DEFAULT_CURSOR: {
    width: 10,
    height: 20,
    x: 0,
    y: 0
  },

  // Grid layout ratios
  GRID_RATIO: {
    canvas: 3,    // 75% of height
    description: 1 // 25% of height
  },

  // Theme colors
  COLORS: {
    background: '#1a1a1a',
    surface: '#2a2a2a',
    border: '#333',
    borderLight: '#444',
    text: {
      primary: '#ffffff',
      secondary: '#cccccc',
      muted: '#888'
    }
  },

  // Typography
  FONTS: {
    system: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
    mono: '"Monaco", "Consolas", monospace'
  },

  // Animation modes
  MODES: {
    CLICK: 'click',
    AUTO: 'auto',
    RANDOM: 'rnd'
  },

  // Preset positions for auto mode
  PRESET_POSITIONS: 7
};

// Convert shader name to display title
export function shaderNameToTitle(shaderName) {
  return shaderName
    .replace(/^cursor_/, '') // Remove "cursor_" prefix
    .split('_') // Split on underscores
    .map(word => word.charAt(0).toUpperCase() + word.slice(1)) // Capitalize each word
    .join(' '); // Join with spaces
}

// Generate shader configs from names
export const SHADER_CONFIGS = SHADER_NAMES.map(name => ({
  name: shaderNameToTitle(name),
  file: `${name}.glsl`,
  md: `${name}.md`,
  baseName: name
}));
