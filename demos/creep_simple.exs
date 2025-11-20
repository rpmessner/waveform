#!/usr/bin/env elixir

# Radiohead - Creep (Simple Pattern Style)
#
# This demo shows a straightforward approach using PatternScheduler
# with the iconic chord progression: G - B - C - Cm
#
# Usage:
#   1. Start SuperDirt in SuperCollider: SuperDirt.start;
#   2. In IEx: mix run demos/creep_simple.exs

alias Waveform.PatternScheduler
alias Waveform.SuperDirt
alias Waveform.Lang

# Wait for SuperCollider server and start SuperDirt
IO.puts("Waiting for SuperCollider server...")
Lang.wait_for_server()
IO.puts("✓ Server ready!")

IO.puts("\nChecking SuperDirt...")
Lang.send_command("if(SuperDirt.class.notNil, { \"SUPERDIRT_CLASS_EXISTS\".postln; }, { \"SUPERDIRT_CLASS_NOT_FOUND\".postln; });")
Process.sleep(1000)
Lang.send_command("if(~dirt.notNil, { \"DIRT_IS_RUNNING\".postln; }, { \"DIRT_NOT_RUNNING\".postln; });")
Process.sleep(1000)

IO.puts("Starting SuperDirt...")
Lang.send_command("~dirt = SuperDirt(2, s); ~dirt.loadSoundFiles; ~dirt.start(57120, [0, 0]); \"SUPERDIRT_STARTED\".postln;")
Process.sleep(8000)
Lang.send_command("if(~dirt.notNil, { \"DIRT_NOW_RUNNING\".postln; }, { \"DIRT_STILL_NOT_RUNNING\".postln; });")
Process.sleep(1000)
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
guitar = [
  # G chord arpeggio
  {0.0, [s: "superpiano", n: 67, gain: 0.5]},    # G4
  {0.125, [s: "superpiano", n: 71, gain: 0.4]},  # B4
  {0.25, [s: "superpiano", n: 74, gain: 0.4]},   # D5
  {0.5, [s: "superpiano", n: 71, gain: 0.4]},    # B4

  # B chord arpeggio
  {1.0, [s: "superpiano", n: 71, gain: 0.5]},    # B4
  {1.125, [s: "superpiano", n: 75, gain: 0.4]},  # D#5
  {1.25, [s: "superpiano", n: 78, gain: 0.4]},   # F#5
  {1.5, [s: "superpiano", n: 75, gain: 0.4]},    # D#5

  # C chord arpeggio
  {2.0, [s: "superpiano", n: 72, gain: 0.5]},    # C5
  {2.125, [s: "superpiano", n: 76, gain: 0.4]},  # E5
  {2.25, [s: "superpiano", n: 79, gain: 0.4]},   # G5
  {2.5, [s: "superpiano", n: 76, gain: 0.4]},    # E5

  # Cm chord arpeggio
  {3.0, [s: "superpiano", n: 72, gain: 0.5]},    # C5
  {3.125, [s: "superpiano", n: 75, gain: 0.4]},  # Eb5
  {3.25, [s: "superpiano", n: 79, gain: 0.4]},   # G5
  {3.5, [s: "superpiano", n: 75, gain: 0.4]}     # Eb5
]

# Start all patterns
PatternScheduler.schedule_pattern(:bass, bass)
PatternScheduler.schedule_pattern(:drums, drums)
PatternScheduler.schedule_pattern(:hats, hats)
PatternScheduler.schedule_pattern(:guitar, guitar)

IO.puts """

🎸 Radiohead - Creep (Simple Style)
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
"""

# Keep the script running
Process.sleep(:infinity)
