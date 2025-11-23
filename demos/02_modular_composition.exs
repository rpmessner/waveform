#!/usr/bin/env elixir

# Demo 2: Modular Composition
#
# This demo shows a more structured approach with helper functions
# and composable patterns. Useful for building complex arrangements.
# Musical style: Chord progression with dynamic variations
#
# Usage:
#   mix run demos/02_modular_composition.exs

defmodule ModularCompositionDemo do
  alias Waveform.PatternScheduler
  alias Waveform.Helpers

  @bpm 92
  @cps @bpm / 240

  # Chord progression: G - B - C - Cm (in MIDI notes)
  @chord_roots [
    # G3
    {0.0, 55},
    # B3
    {1.0, 59},
    # C4
    {2.0, 60},
    # C3
    {3.0, 48}
  ]

  defp start_superdirt do
    IO.puts("Starting SuperCollider and SuperDirt...")
    Helpers.ensure_superdirt_ready()
    IO.puts("✓ SuperDirt ready!\n")
  end

  def play do
    start_superdirt()
    PatternScheduler.set_cps(@cps)

    # Build patterns using composition
    bass_pattern = build_bass(@chord_roots)
    drum_pattern = build_drums()
    melody_pattern = build_melody()

    PatternScheduler.schedule_pattern(:bass, bass_pattern)
    PatternScheduler.schedule_pattern(:drums, drum_pattern)
    PatternScheduler.schedule_pattern(:melody, melody_pattern)

    print_info()
  end

  def play_quiet do
    start_superdirt()
    PatternScheduler.set_cps(@cps)

    # Verse version - quieter, minimal drums
    PatternScheduler.schedule_pattern(:bass, build_bass(@chord_roots, gain: 0.5))
    PatternScheduler.schedule_pattern(:drums, build_drums(gain: 0.4))
    PatternScheduler.schedule_pattern(:melody, build_melody(gain: 0.4))

    IO.puts("🎸 Playing QUIET section...")
  end

  def play_loud do
    start_superdirt()
    PatternScheduler.set_cps(@cps)

    # Chorus version - louder, full drums
    PatternScheduler.schedule_pattern(:bass, build_bass(@chord_roots, gain: 0.9))
    PatternScheduler.schedule_pattern(:drums, build_drums(gain: 0.8))
    PatternScheduler.schedule_pattern(:melody, build_melody(gain: 0.7))
    PatternScheduler.schedule_pattern(:hats, build_hats())

    IO.puts("🎸 Playing LOUD section...")
  end

  # Pattern builders

  defp build_bass(chord_roots, opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.8)

    Enum.map(chord_roots, fn {pos, note} ->
      {pos, [s: "bass", n: note, gain: gain]}
    end)
  end

  defp build_drums(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.7)

    for beat <- [0.0, 1.0, 2.0, 3.0], hit <- [:kick, :snare] do
      case hit do
        :kick -> {beat, [s: "bd", gain: gain]}
        :snare -> {beat + 0.5, [s: "sn", gain: gain * 0.85]}
      end
    end
    |> List.flatten()
  end

  defp build_hats(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.3)

    for i <- 0..15 do
      variant = rem(i, 2)
      gain_adj = if variant == 0, do: 1.0, else: 0.8
      {i * 0.25, [s: "hh", n: variant, gain: gain * gain_adj]}
    end
  end

  defp build_melody(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.5)

    # Simplified melodic pattern
    # Using "arpy" (tuned instruments) from Dirt-Samples
    [
      {0.0, [s: "arpy", n: 67, gain: gain]},
      {0.25, [s: "arpy", n: 71, gain: gain * 0.8]},
      {1.0, [s: "arpy", n: 71, gain: gain]},
      {1.25, [s: "arpy", n: 75, gain: gain * 0.8]},
      {2.0, [s: "arpy", n: 72, gain: gain]},
      {2.25, [s: "arpy", n: 76, gain: gain * 0.8]},
      {3.0, [s: "arpy", n: 72, gain: gain]},
      {3.25, [s: "arpy", n: 75, gain: gain * 0.8]}
    ]
  end

  defp print_info do
    IO.puts("""

    🎹 Demo 2: Modular Composition
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Playing at #{@bpm} BPM

    Available functions:
      ModularCompositionDemo.play()        # Standard version
      ModularCompositionDemo.play_quiet()  # Quiet/verse dynamics
      ModularCompositionDemo.play_loud()   # Loud/chorus dynamics

      PatternScheduler.hush() # Stop everything
    """)
  end
end

# Auto-play when run as script
ModularCompositionDemo.play()
Process.sleep(:infinity)
