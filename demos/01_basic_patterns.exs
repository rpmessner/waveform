#!/usr/bin/env elixir

# Demo 1: Basic Patterns
#
# This demo shows a straightforward approach using PatternScheduler
# with a simple chord progression: G - B - C - Cm
# Musical style: Chord progression with arpeggios
#
# Usage:
#   mix run demos/01_basic_patterns.exs

alias Waveform.PatternScheduler
alias Waveform.Helpers

# Wait for SuperCollider server and start SuperDirt
IO.puts("Starting SuperCollider and SuperDirt...")
Helpers.ensure_superdirt_ready()
IO.puts("✓ SuperDirt ready!\n")

# Set tempo (original is around 92 BPM)
# BPM to CPS: 92 / 240 = 0.383
PatternScheduler.set_cps(0.383)

# Bass line (plays the root notes of the chord progression)
# G(55) - B(59) - C(60) - C(48)
bass = [
  {0.0, [s: "bass", n: 55, gain: 0.8]},
  {1.0, [s: "bass", n: 59, gain: 0.8]},
  {2.0, [s: "bass", n: 60, gain: 0.8]},
  {3.0, [s: "bass", n: 48, gain: 0.9]}
]

# Drums - simple beat
drums = [
  {0.0, [s: "bd", gain: 0.7]},
  {0.5, [s: "sn", gain: 0.6]},
  {1.0, [s: "bd", gain: 0.7]},
  {1.5, [s: "sn", gain: 0.6]},
  {2.0, [s: "bd", gain: 0.7]},
  {2.5, [s: "sn", gain: 0.6]},
  {3.0, [s: "bd", gain: 0.7]},
  {3.5, [s: "sn", gain: 0.6]}
]

# Hi-hats
hats = [
  {0.0, [s: "hh", n: 0, gain: 0.3]},
  {0.25, [s: "hh", n: 1, gain: 0.25]},
  {0.5, [s: "hh", n: 0, gain: 0.3]},
  {0.75, [s: "hh", n: 1, gain: 0.25]},
  {1.0, [s: "hh", n: 0, gain: 0.3]},
  {1.25, [s: "hh", n: 1, gain: 0.25]},
  {1.5, [s: "hh", n: 0, gain: 0.3]},
  {1.75, [s: "hh", n: 1, gain: 0.25]},
  {2.0, [s: "hh", n: 0, gain: 0.3]},
  {2.25, [s: "hh", n: 1, gain: 0.25]},
  {2.5, [s: "hh", n: 0, gain: 0.3]},
  {2.75, [s: "hh", n: 1, gain: 0.25]},
  {3.0, [s: "hh", n: 0, gain: 0.3]},
  {3.25, [s: "hh", n: 1, gain: 0.25]},
  {3.5, [s: "hh", n: 0, gain: 0.3]},
  {3.75, [s: "hh", n: 1, gain: 0.25]}
]

# Guitar-like arpeggios (representing the iconic intro riff)
# Using "arpy" (tuned instruments) from Dirt-Samples
guitar = [
  # G chord arpeggio
  # G4
  {0.0, [s: "arpy", n: 67, gain: 0.5]},
  # B4
  {0.125, [s: "arpy", n: 71, gain: 0.4]},
  # D5
  {0.25, [s: "arpy", n: 74, gain: 0.4]},
  # B4
  {0.5, [s: "arpy", n: 71, gain: 0.4]},

  # B chord arpeggio
  # B4
  {1.0, [s: "arpy", n: 71, gain: 0.5]},
  # D#5
  {1.125, [s: "arpy", n: 75, gain: 0.4]},
  # F#5
  {1.25, [s: "arpy", n: 78, gain: 0.4]},
  # D#5
  {1.5, [s: "arpy", n: 75, gain: 0.4]},

  # C chord arpeggio
  # C5
  {2.0, [s: "arpy", n: 72, gain: 0.5]},
  # E5
  {2.125, [s: "arpy", n: 76, gain: 0.4]},
  # G5
  {2.25, [s: "arpy", n: 79, gain: 0.4]},
  # E5
  {2.5, [s: "arpy", n: 76, gain: 0.4]},

  # Cm chord arpeggio
  # C5
  {3.0, [s: "arpy", n: 72, gain: 0.5]},
  # Eb5
  {3.125, [s: "arpy", n: 75, gain: 0.4]},
  # G5
  {3.25, [s: "arpy", n: 79, gain: 0.4]},
  # Eb5
  {3.5, [s: "arpy", n: 75, gain: 0.4]}
]

# Start all patterns
PatternScheduler.schedule_pattern(:bass, bass)
PatternScheduler.schedule_pattern(:drums, drums)
PatternScheduler.schedule_pattern(:hats, hats)
PatternScheduler.schedule_pattern(:guitar, guitar)

IO.puts("""

🎸 Demo 1: Basic Patterns
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Playing at 92 BPM with 4 patterns

Patterns:
  - :bass   - Chord root notes
  - :drums  - Basic kick/snare
  - :hats   - Hi-hat pattern
  - :guitar - Arpeggiated chords

Commands:
  PatternScheduler.stop_pattern(:hats)   # Stop hi-hats
  PatternScheduler.stop_pattern(:guitar) # Stop guitar
  PatternScheduler.hush()                # Stop everything
""")

# Keep the script running
Process.sleep(:infinity)
