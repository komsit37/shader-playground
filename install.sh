#!/bin/bash

# Shader Playground Installation Script
# This script sets up the shader playground for Ghostty terminal

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the correct directory
if [[ ! -f "switch-shader" || ! -d "shaders" ]]; then
    print_error "Please run this script from the shader-playground directory"
    exit 1
fi

# Get the current directory
SCRIPT_DIR="$(pwd)"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"

print_status "Starting shader playground installation..."

# Create Ghostty config directory if it doesn't exist
if [[ ! -d "$GHOSTTY_CONFIG_DIR" ]]; then
    print_status "Creating Ghostty config directory..."
    mkdir -p "$GHOSTTY_CONFIG_DIR"
    print_success "Created $GHOSTTY_CONFIG_DIR"
fi

# Copy shaders directory
print_status "Copying shaders to Ghostty config directory..."
if [[ -L "$GHOSTTY_CONFIG_DIR/shaders" ]]; then
    print_warning "Shaders symlink exists, removing..."
    rm "$GHOSTTY_CONFIG_DIR/shaders"
elif [[ -d "$GHOSTTY_CONFIG_DIR/shaders" ]]; then
    print_warning "Shaders directory already exists, backing up..."
    mv "$GHOSTTY_CONFIG_DIR/shaders" "$GHOSTTY_CONFIG_DIR/shaders.backup.$(date +%s)"
fi

cp -r "$SCRIPT_DIR/shaders" "$GHOSTTY_CONFIG_DIR/shaders"
print_success "Copied shaders to: $GHOSTTY_CONFIG_DIR/shaders"

# Make switch-shader script executable
print_status "Making switch-shader script executable..."
chmod +x "$SCRIPT_DIR/switch-shader"
print_success "Made switch-shader executable"

# Offer to create symlink for switch-shader script
echo
read -p "Do you want to create a symlink for switch-shader in /usr/local/bin? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Creating symlink for switch-shader script..."
    if command -v sudo >/dev/null 2>&1; then
        sudo ln -sf "$SCRIPT_DIR/switch-shader" /usr/local/bin/switch-shader
        print_success "Created symlink: /usr/local/bin/switch-shader -> $SCRIPT_DIR/switch-shader"
        print_status "You can now run 'switch-shader' from anywhere"
    else
        print_error "sudo not available. Please manually create the symlink:"
        echo "  ln -s \"$SCRIPT_DIR/switch-shader\" /usr/local/bin/switch-shader"
    fi
else
    print_status "Skipping global symlink creation"
    print_status "You can run the script with: $SCRIPT_DIR/switch-shader"
fi

echo
print_success "Installation complete!"
echo
print_status "Next steps:"
echo "  1. Run 'switch-shader' (or '$SCRIPT_DIR/switch-shader') to see available shaders"
echo "  2. Run 'switch-shader <shader-name>' to activate a shader"
echo "  3. Check the README.md for more information"
echo
print_status "Example usage:"
echo "  switch-shader cursor_focus_pulse"
echo "  switch-shader 6"