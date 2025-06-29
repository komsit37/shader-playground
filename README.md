# Shader Playground for Ghostty

A collection of custom cursor shaders for the [Ghostty](https://github.com/ghostty-org/ghostty) terminal, managed by a simple helper script. This project also includes a web-based playground for viewing and testing the shaders.

## Showcase

View and test all shaders interactively: https://komsit37.github.io/shader-playground/

## Installation & Usage

There are two ways to install and use these shaders:

### Method 1: Manual Installation

1. Copy the desired shader file to your Ghostty shaders directory:

   ```bash
   cp shaders/cursor_focus_pulse.glsl ~/.config/ghostty/shaders/
   ```

2. Update your Ghostty config file (`~/.config/ghostty/config`) to use the shader:
   ```
   custom-shader = shaders/cursor_focus_pulse.glsl
   ```

### Method 2: Using the switch-shader Script

The `switch-shader` script allows you to easily manage and change the active shader for Ghostty.

#### Quick Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/shader-playground.git ~/.config/ghostty/shader-playground
   ```

2. Run the install script:
   ```bash
   cd ~/.config/ghostty/shader-playground
   ./install.sh
   ```
   
   The install script will:
   - Create the Ghostty config directory if needed
   - Copy all shader files to `~/.config/ghostty/shaders`
   - Make the `switch-shader` script executable
   - Optionally create a global symlink for the `switch-shader` command

#### Development Setup

For shader development with live file updates:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/shader-playground.git ~/.config/ghostty/shader-playground
   ```

2. **Create Symlink for Development**
   ```bash
   cd ~/.config/ghostty/shader-playground
   ln -s "$(pwd)/shaders" ~/.config/ghostty/shaders
   ```
   Note: This creates a symlink so shader changes are immediately available without copying files.

3. **Make the Script Executable**
   ```bash
   chmod +x switch-shader
   ```

4. **(Optional) Create Global Symlink**
   ```bash
   sudo ln -s "$(pwd)/switch-shader" /usr/local/bin/switch-shader
   ```

#### How to Use

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

