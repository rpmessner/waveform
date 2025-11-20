#!/usr/bin/env elixir

# John Coltrane - Giant Steps
#
# Famous for its rapid chord changes through three key centers.
# This demo demonstrates complex harmonic patterns.
#
# Usage:
#   mix run demos/giant_steps.exs

defmodule GiantStepsDemo do
  alias Waveform.PatternScheduler
  alias Waveform.Lang

  @bpm 240  # Coltrane's version is blazingly fast
  @cps @bpm / 240

  defp start_superdirt do
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
  end

  # The famous "Coltrane changes" - chord roots in MIDI notes
  # Progresses through B major, G major, and Eb major centers
  @chord_changes [
    # First phrase (bars 1-4)
    {0.0, 59},    # B
    {0.125, 62},  # D
    {0.25, 55},   # G
    {0.375, 58},  # Bb
    {0.5, 51},    # Eb
    {0.75, 57},   # A
    {0.875, 62},  # D
    {1.0, 55},    # G

    # Second phrase (bars 5-8)
    {1.125, 58},  # Bb
    {1.25, 51},   # Eb
    {1.5, 54},    # F#
    {1.625, 59},  # B
    {1.75, 53},   # F
    {1.875, 58},  # Bb
    {2.0, 51},    # Eb

    # Third phrase (bars 9-12)
    {2.25, 57},   # A
    {2.375, 62},  # D
    {2.5, 55},    # G
    {2.75, 61},   # C#
    {2.875, 54},  # F#
    {3.0, 59},    # B

    # Final phrase (bars 13-16)
    {3.25, 53},   # F
    {3.375, 58},  # Bb
    {3.5, 51},    # Eb
    {3.75, 61},   # C#
    {3.875, 54}   # F#
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

  def play_slow do
    start_superdirt()
    # Practice version at half speed
    PatternScheduler.set_cps(@cps / 2)

    PatternScheduler.schedule_pattern(:bass, build_walking_bass(gain: 0.8))
    PatternScheduler.schedule_pattern(:ride, build_ride_cymbal(gain: 0.3))
    PatternScheduler.schedule_pattern(:kick, build_kick(gain: 0.5))

    IO.puts "🎷 Playing at half speed (120 BPM)..."
  end

  defp build_walking_bass(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.7)

    Enum.map(@chord_changes, fn {pos, note} ->
      # Use lower octave for bass
      bass_note = note - 12
      {pos, [s: "bass", n: bass_note, gain: gain, cutoff: 800]}
    end)
  end

  defp build_ride_cymbal(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.4)

    # Jazz swing pattern (approximated)
    for i <- 0..31 do
      variant = rem(i, 3)
      swing_gain = case rem(i, 2) do
        0 -> gain        # Downbeat
        1 -> gain * 0.7  # Upbeat
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

    # Simplified melodic fragments echoing the chord changes
    [
      {0.0, [s: "superpiano", n: 71, gain: gain]},      # B4
      {0.25, [s: "superpiano", n: 67, gain: gain]},     # G4
      {0.5, [s: "superpiano", n: 63, gain: gain]},      # Eb4
      {1.0, [s: "superpiano", n: 67, gain: gain]},      # G4
      {1.5, [s: "superpiano", n: 66, gain: gain]},      # F#4
      {2.0, [s: "superpiano", n: 63, gain: gain]},      # Eb4
      {2.5, [s: "superpiano", n: 67, gain: gain]},      # G4
      {3.0, [s: "superpiano", n: 71, gain: gain]},      # B4
      {3.5, [s: "superpiano", n: 63, gain: gain]}       # Eb4
    ]
  end

  defp print_info do
    IO.puts """

    🎷 John Coltrane - Giant Steps
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Playing at #{@bpm} BPM (incredibly fast!)

    This piece is famous for its complex "Coltrane changes"
    moving through three key centers: B, G, and Eb

    Available functions:
      GiantStepsDemo.play()       # Full speed (240 BPM!)
      GiantStepsDemo.play_slow()  # Half speed (120 BPM)

      PatternScheduler.stop_pattern(:melody)
      PatternScheduler.hush()     # Stop everything
    """
  end
end

GiantStepsDemo.play()
Process.sleep(:infinity)
