#!/usr/bin/env elixir

# Demo 4: Complex Harmony
#
# Demonstrates rapid chord changes through multiple key centers.
# Shows complex harmonic patterns at fast tempos.
# Musical style: Jazz progression with dense chord changes
#
# Usage:
#   mix run demos/04_complex_harmony.exs

defmodule ComplexHarmonyDemo do
  alias Waveform.PatternScheduler
  alias Waveform.Lang

  # Default to a learnable tempo (original Giant Steps is 240 BPM!)
  @bpm 120
  @cps @bpm / 240

  defp start_superdirt do
    IO.puts("Waiting for SuperCollider server...")
    Lang.wait_for_server()
    IO.puts("✓ Server ready!")

    IO.puts("\nChecking SuperDirt...")

    Lang.send_command(
      "if(SuperDirt.class.notNil, { \"SUPERDIRT_CLASS_EXISTS\".postln; }, { \"SUPERDIRT_CLASS_NOT_FOUND\".postln; });"
    )

    Process.sleep(1000)

    Lang.send_command(
      "if(~dirt.notNil, { \"DIRT_IS_RUNNING\".postln; }, { \"DIRT_NOT_RUNNING\".postln; });"
    )

    Process.sleep(1000)

    IO.puts("Starting SuperDirt...")

    Lang.send_command(
      "~dirt = SuperDirt(2, s); ~dirt.loadSoundFiles; ~dirt.start(57120, [0, 0]); \"SUPERDIRT_STARTED\".postln;"
    )

    Process.sleep(8000)

    Lang.send_command(
      "if(~dirt.notNil, { \"DIRT_NOW_RUNNING\".postln; }, { \"DIRT_STILL_NOT_RUNNING\".postln; });"
    )

    Process.sleep(1000)
    IO.puts("✓ SuperDirt ready!\n")
  end

  # Chord progression moving through multiple key centers
  # Slower harmonic rhythm to clearly hear each change
  @chord_changes [
    # Cycle 1: Start in C, move to E (major 3rd up)
    # C
    {0.0, 60},
    # E
    {0.5, 64},

    # Cycle 2: Move to Ab (major 3rd up from E)
    # Ab
    {1.0, 68},
    # Back to C (completing the symmetrical division)
    {1.5, 60},

    # Cycle 3: Descend by whole steps
    # D
    {2.0, 62},
    # C
    {2.5, 60},

    # Cycle 4: Final progression through fourths
    # F
    {3.0, 65},
    # C (back home)
    {3.25, 60},
    # G
    {3.5, 67},
    # C (resolution)
    {3.75, 60}
  ]

  def play do
    start_superdirt()
    PatternScheduler.set_cps(@cps)

    # Walking bass through the changes
    bass_pattern = build_walking_bass()

    # Jazz ride cymbal pattern
    ride_pattern = build_ride_cymbal()

    # Walking quarter notes on bass
    kick_pattern = build_kick()

    # Melodic fragments
    melody_pattern = build_melody()

    PatternScheduler.schedule_pattern(:bass, bass_pattern)
    PatternScheduler.schedule_pattern(:ride, ride_pattern)
    PatternScheduler.schedule_pattern(:kick, kick_pattern)
    PatternScheduler.schedule_pattern(:melody, melody_pattern)

    print_info()
  end

  def play_fast do
    start_superdirt()
    # Original blazing fast tempo
    # 240 BPM (2x speed)
    PatternScheduler.set_cps(@bpm / 120)

    PatternScheduler.schedule_pattern(:bass, build_walking_bass(gain: 0.8))
    PatternScheduler.schedule_pattern(:ride, build_ride_cymbal(gain: 0.3))
    PatternScheduler.schedule_pattern(:kick, build_kick(gain: 0.5))
    PatternScheduler.schedule_pattern(:melody, build_melody(gain: 0.6))

    IO.puts("🎷 Playing at FULL speed (240 BPM - original tempo)...")
  end

  defp build_walking_bass(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.7)

    Enum.map(@chord_changes, fn {pos, note} ->
      # Use arpy for melodic bass (bass sample is too percussive)
      # Transpose down an octave
      bass_note = note - 12
      {pos, [s: "arpy", n: bass_note, gain: gain, speed: 0.8]}
    end)
  end

  defp build_ride_cymbal(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.4)

    # Jazz swing pattern (approximated)
    for i <- 0..31 do
      variant = rem(i, 3)

      swing_gain =
        case rem(i, 2) do
          # Downbeat
          0 -> gain
          # Upbeat
          1 -> gain * 0.7
        end

      {i * 0.125, [s: "hh", n: variant, gain: swing_gain]}
    end
  end

  defp build_kick(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.6)

    # Four-on-the-floor with jazz feel
    for i <- 0..15 do
      {i * 0.25, [s: "bd", gain: gain, speed: 1.2]}
    end
  end

  defp build_melody(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.6)

    # Melodic line that outlines each chord change
    # Using "arpy" (tuned instruments) from Dirt-Samples
    [
      # Cycle 1: C major (C-E-G) → E major (E-G#-B)
      # C5 (root)
      {0.0, [s: "arpy", n: 72, gain: gain]},
      # E5 (3rd)
      {0.125, [s: "arpy", n: 76, gain: gain]},
      # G5 (5th)
      {0.25, [s: "arpy", n: 79, gain: gain]},
      # E5 (new root)
      {0.5, [s: "arpy", n: 76, gain: gain]},
      # G#5 (3rd)
      {0.625, [s: "arpy", n: 80, gain: gain]},
      # B5 (5th)
      {0.75, [s: "arpy", n: 83, gain: gain]},

      # Cycle 2: Ab major (Ab-C-Eb) → back to C
      # Ab5 (root)
      {1.0, [s: "arpy", n: 80, gain: gain]},
      # C6 (3rd)
      {1.125, [s: "arpy", n: 84, gain: gain]},
      # Eb6 (5th)
      {1.25, [s: "arpy", n: 87, gain: gain]},
      # C5 (back home)
      {1.5, [s: "arpy", n: 72, gain: gain]},
      # E5
      {1.625, [s: "arpy", n: 76, gain: gain]},
      # G5
      {1.75, [s: "arpy", n: 79, gain: gain]},

      # Cycle 3: D major (D-F#-A) → C major
      # D5 (root)
      {2.0, [s: "arpy", n: 74, gain: gain]},
      # F#5 (3rd)
      {2.125, [s: "arpy", n: 78, gain: gain]},
      # A5 (5th)
      {2.25, [s: "arpy", n: 81, gain: gain]},
      # C5
      {2.5, [s: "arpy", n: 72, gain: gain]},
      # E5
      {2.625, [s: "arpy", n: 76, gain: gain]},
      # G5
      {2.75, [s: "arpy", n: 79, gain: gain]},

      # Cycle 4: F → C → G → C (resolution)
      # F5
      {3.0, [s: "arpy", n: 77, gain: gain]},
      # A5
      {3.125, [s: "arpy", n: 81, gain: gain]},
      # C5
      {3.25, [s: "arpy", n: 72, gain: gain]},
      # G5
      {3.5, [s: "arpy", n: 79, gain: gain]},
      # B5
      {3.625, [s: "arpy", n: 83, gain: gain]},
      # C5 (final resolution)
      {3.75, [s: "arpy", n: 72, gain: gain]}
    ]
  end

  defp print_info do
    IO.puts("""

    🎷 Demo 4: Complex Harmony
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Playing at #{@bpm} BPM (moderate tempo to hear changes)

    This demonstrates chord movement through multiple key centers
    The progression uses symmetrical patterns and distant modulations

    Pattern: C → E → Ab → C (major 3rds), then descending steps

    Listen for how the bass line creates harmonic motion!

    Available functions:
      ComplexHarmonyDemo.play()       # Default (120 BPM)
      ComplexHarmonyDemo.play_fast()  # Challenge mode (240 BPM!)

      PatternScheduler.stop_pattern(:melody)
      PatternScheduler.hush()     # Stop everything
    """)
  end
end

ComplexHarmonyDemo.play()
Process.sleep(:infinity)
