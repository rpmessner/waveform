#!/usr/bin/env elixir

# Demo 3: Syncopated Rhythm
#
# Demonstrates funky grooves with syncopated rhythms
# and precision timing with 16th note patterns.
# Musical style: Funk groove with syncopation
#
# Usage:
#   mix run demos/03_syncopated_rhythm.exs

defmodule SyncopatedRhythmDemo do
  alias Waveform.PatternScheduler
  alias Waveform.Lang

  @bpm 100
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

  def play do
    start_superdirt()
    PatternScheduler.set_cps(@cps)

    # The iconic riff
    funk_riff = build_funk_riff()

    # Funky drum groove
    drums = build_funky_drums()

    # Hi-hat pattern
    hats = build_hats()

    # Bass line
    bass = build_bass()

    PatternScheduler.schedule_pattern(:riff, funk_riff)
    PatternScheduler.schedule_pattern(:drums, drums)
    PatternScheduler.schedule_pattern(:hats, hats)
    PatternScheduler.schedule_pattern(:bass, bass)

    print_info()
  end

  defp build_funk_riff(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.6)

    # The famous syncopated clavinet riff (simplified)
    # Eb minor pentatonic-based riff
    # Using "arpy" (tuned instruments) from Dirt-Samples
    [
      # Bar 1
      # Eb4
      {0.0, [s: "arpy", n: 63, gain: gain, speed: 1.5]},
      {0.0625, [s: "arpy", n: 63, gain: gain * 0.7, speed: 1.5]},
      # F#4
      {0.1875, [s: "arpy", n: 66, gain: gain, speed: 1.5]},
      # Eb4
      {0.25, [s: "arpy", n: 63, gain: gain, speed: 1.5]},
      # Bb3
      {0.4375, [s: "arpy", n: 58, gain: gain, speed: 1.5]},
      # Eb4
      {0.5, [s: "arpy", n: 63, gain: gain, speed: 1.5]},

      # Bar 2
      # Eb4
      {1.0, [s: "arpy", n: 63, gain: gain, speed: 1.5]},
      {1.0625, [s: "arpy", n: 63, gain: gain * 0.7, speed: 1.5]},
      # F#4
      {1.1875, [s: "arpy", n: 66, gain: gain, speed: 1.5]},
      # Eb4
      {1.25, [s: "arpy", n: 63, gain: gain, speed: 1.5]},
      # Bb3
      {1.4375, [s: "arpy", n: 58, gain: gain, speed: 1.5]},
      # Db4
      {1.5, [s: "arpy", n: 61, gain: gain, speed: 1.5]}
    ]
  end

  defp build_funky_drums(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.8)

    [
      # Kick pattern
      {0.0, [s: "bd", gain: gain]},
      {0.375, [s: "bd", gain: gain * 0.7]},
      {0.5, [s: "bd", gain: gain * 0.6]},
      {1.0, [s: "bd", gain: gain]},
      {1.375, [s: "bd", gain: gain * 0.7]},
      {1.5, [s: "bd", gain: gain * 0.6]},

      # Snare pattern (syncopated)
      {0.25, [s: "sn", gain: gain * 0.9]},
      {0.625, [s: "sn", gain: gain * 0.5]},
      {0.75, [s: "sn", gain: gain * 0.6]},
      {1.25, [s: "sn", gain: gain * 0.9]},
      {1.625, [s: "sn", gain: gain * 0.5]},
      {1.75, [s: "sn", gain: gain * 0.6]}
    ]
  end

  defp build_hats(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.4)

    # Steady 16th notes with accents
    for i <- 0..15 do
      variant = rem(i, 2)
      # Accent on beats and off-beats
      accent = if rem(i, 4) == 0, do: 1.2, else: 1.0
      {i * 0.125, [s: "hh", n: variant, gain: gain * accent]}
    end
  end

  defp build_bass(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.75)

    # Funky syncopated bass line
    [
      # Eb2
      {0.0, [s: "bass", n: 39, gain: gain]},
      {0.1875, [s: "bass", n: 39, gain: gain * 0.6]},
      # F#2
      {0.375, [s: "bass", n: 42, gain: gain * 0.8]},
      # Eb2
      {0.5, [s: "bass", n: 39, gain: gain]},
      # Bb2
      {0.75, [s: "bass", n: 46, gain: gain * 0.7]},
      # Eb2
      {1.0, [s: "bass", n: 39, gain: gain]},
      {1.1875, [s: "bass", n: 39, gain: gain * 0.6]},
      # F#2
      {1.375, [s: "bass", n: 42, gain: gain * 0.8]},
      # Db2
      {1.5, [s: "bass", n: 37, gain: gain]},
      # Bb2
      {1.75, [s: "bass", n: 46, gain: gain * 0.7]}
    ]
  end

  defp print_info do
    IO.puts("""

    🥁 Demo 3: Syncopated Rhythm
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Playing at #{@bpm} BPM

    Features:
      - Syncopated clavinet-style riff
      - Funky drum groove
      - Syncopated bass line
      - Steady hi-hats

    Commands:
      PatternScheduler.stop_pattern(:riff)   # Silence the riff
      PatternScheduler.stop_pattern(:drums)  # Just bass & riff
      PatternScheduler.stop_pattern(:bass)   # Remove bass
      PatternScheduler.hush()                # Stop everything
    """)
  end
end

SyncopatedRhythmDemo.play()
Process.sleep(:infinity)
