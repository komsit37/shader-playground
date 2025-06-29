# Pulse Cursor Effect

A heartbeat-inspired effect creating rhythmic pulsing rings with varying intensity, sparkle effects on movement, and organic color variations.

## Visual Design

- **Primary Effect**: Multiple expanding rings with heartbeat rhythm (lub-dub pattern)
- **Movement Response**: Sparkle particles and intensity boost when cursor moves
- **Color Scheme**: Warm gradient shifting from pink-red to cyan-blue across rings
- **Timing**: 1.5 beats per second with double-pulse heartbeat pattern

## Technical Features

- **Heartbeat Rhythm**: Dual pulse pattern mimicking cardiac rhythm
- **Multi-Ring System**: 4 rings with staggered timing (0.15s offset each)
- **Dynamic Thickness**: Ring thickness varies with heartbeat intensity
- **Movement Detection**: Sparkle effect and intensity boost on cursor movement
- **Color Cycling**: Each ring has unique color parameters based on trigonometric functions

## Experimental Features

This is an experimental shader designed for feedback and iteration. Key areas for exploration:

- **Heartbeat Rate**: Currently 1.5 BPM, adjustable for different feels
- **Ring Count**: 4 rings with 0.15s timing offset between each
- **Sparkle Threshold**: 98% noise threshold for movement-triggered sparkles
- **Color Variation**: Sine/cosine functions create organic color shifts

## Usage Notes

Best experienced with:
- **Click mode** to trigger intense bursts manually
- **Movement sensitivity** - even small movements trigger sparkle effects
- **Auto mode** for consistent heartbeat rhythm without movement noise