# Ripple Cursor Effect

A water ripple effect that creates expanding circular waves when the cursor moves, with interference patterns between current and previous positions.

## Visual Design

- **Primary Effect**: Expanding concentric ripples emanating from cursor position
- **Secondary Effect**: Interference patterns when ripples from current and previous positions interact
- **Color Scheme**: Blue-cyan gradient with chromatic dispersion effects
- **Timing**: Fast ripple expansion (8 units/second) with 2.5 second fade

## Technical Features

- **Movement Detection**: Only activates when cursor moves more than 0.001 units
- **Dual Ripple System**: Primary ripples from current position, secondary from previous position
- **Interference Patterns**: Mathematical wave interference creates realistic water-like behavior
- **Chromatic Dispersion**: RGB components fade at different rates for prismatic effect
- **Cursor Highlight**: Soft blue glow at cursor center

## Experimental Features

This is an experimental shader designed for feedback and iteration. Key areas for exploration:

- **Ripple Speed**: Currently 8.0 units/second for primary, 6.0 for secondary
- **Fade Timing**: 2.5 second exponential decay
- **Wave Frequency**: 30.0 for primary ripples, 25.0 for secondary
- **Interference Strength**: Secondary ripples at 60% intensity

## Usage Notes

Best experienced with:
- **Slow to medium cursor movements** for clear ripple formation
- **Auto mode** to see consistent ripple patterns
- **Random mode** for chaotic interference effects