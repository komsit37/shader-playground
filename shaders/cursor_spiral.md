# Spiral Cursor Effect

A dynamic particle system creating rotating spiral trails with multiple arms, noise-based perturbations, and movement-responsive connecting trails.

## Visual Design

- **Primary Effect**: 3-armed spiral with rotating particle trails
- **Movement Trail**: Connecting spiral between current and previous cursor positions  
- **Particle System**: Variable-sized particles with color cycling along spiral path
- **Color Scheme**: Multi-hue spectrum shifting through spiral arms with warm trail accents
- **Ambient Elements**: Subtle sparkle field across the canvas

## Technical Features

- **Multi-Arm Spiral**: 3 spiral arms offset by 120 degrees each
- **Particle Animation**: Varying particle sizes with sinusoidal modulation
- **Noise Perturbation**: Procedural noise adds organic movement to spiral paths
- **Movement Response**: Enhanced spiral size and connecting trail on cursor movement
- **Dynamic Coloring**: HSV-like color cycling based on spiral position and time

## Experimental Features

This is an experimental shader designed for feedback and iteration. Key areas for exploration:

- **Spiral Parameters**: 8.0 tightness, 2.0 rotation speed, 0.3 max radius
- **Particle Density**: 0.05 step size creates ~20 particles per arm
- **Noise Scale**: 10.0 frequency for organic path perturbation
- **Trail Dynamics**: 15.0 frequency spiral motion along movement trail

## Usage Notes

Best experienced with:
- **Continuous movement** to see full spiral dynamics and connecting trails
- **Random mode** for chaotic spiral interactions
- **Medium to fast cursor speeds** for optimal particle trail visibility