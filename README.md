# Shader Playground for Ghostty

A collection of custom cursor shaders for the [Ghostty](https://github.com/ghostty-org/ghostty) terminal, managed by a simple helper script. This project also includes a web-based playground for viewing and testing the shaders.

## Shader Gallery

Below is a list of the currently available shaders.

| ID  | Name                      | Title                    | Description                                                                                                                                                           |
| --- | ------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `cursor_blaze`            |                          |                                                                                                                                                                       |
| 2   | `cursor_blaze_no_trail`   |                          |                                                                                                                                                                       |
| 3   | `cursor_bounce`           | Bounce Cursor            | An iOS-style elastic bounce cursor featuring trail particles and authentic bounce physics.                                                                            |
| 4   | `cursor_bounce_clean`     | Clean Bounce Cursor      | A minimal version of the bounce cursor with no trail particles.                                                                                                       |
| 5   | `cursor_digital_dissolve` | Digital Dissolve Cursor  | A "teleportation" effect where the cursor dissolves and reassembles at the new position.                                                                              |
| 6   | `cursor_focus_pulse`      | Focus Pulse Cursor       | A terminal-optimized cursor that subtly pulses when idle and glows when moving. Great for Neovim/tmux.                                                                |
| 7   | `cursor_ligthing`         | Lighting Cursor          | A smooth lighting effect with clean orange/yellow glow trails.                                                                                                        |
| 8   | `cursor_ligthing_fancy`   | Fancy Lightning Cursor   | A jagged lightning effect with electric blue bolts.                                                                                                                   |
| 9   | `cursor_pastel_sparkle`   | Pastel Sparkle Cursor    | A cute and cheerful cursor that leaves a trail of twinkling pastel particles.                                                                                         |
| 10  | `cursor_rainbow`          | Rainbow Cursor           | A terminal-optimized rainbow effect with subtle trail animation.                                                                                                      |
| ... | `...`                     | `...`                    | *And more...*                                                                                                                                                         |


## Installation & Usage

The `switch-shader` script allows you to easily manage and change the active shader for Ghostty.

### 1. Clone the Repository

First, clone this repository to a permanent location on your local machine, such as `~/.config/ghostty/shaders` or `~/git/shader-playground`.

```bash
git clone https://github.com/your-username/shader-playground.git ~/.config/ghostty/shader-playground
```

### 2. Make the Script Executable

Navigate to the cloned directory and run the following command:

```bash
cd ~/.config/ghostty/shader-playground
chmod +x switch-shader
```

### 3. (Recommended) Create a Symlink

To run the script from anywhere, create a symbolic link in a directory that is in your system's `PATH` (e.g., `/usr/local/bin`).

```bash
sudo ln -s "$(pwd)/switch-shader" /usr/local/bin/switch-shader
```

### 4. How to Use

Now you can run the script from anywhere.

**List all available shaders:**
```bash
switch-shader
```

**Switch to a new shader by name or ID:**
```bash
# By name
switch-shader cursor_focus_pulse

# By ID
switch-shader 6
```
The script will update your Ghostty config and restart the application automatically.