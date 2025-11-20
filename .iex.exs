# Waveform IEx Configuration
# Loaded automatically when starting IEx in this project

# Core Waveform modules
alias Waveform.SuperDirt
alias Waveform.PatternScheduler
alias Waveform.Synth
alias Waveform.OSC
alias Waveform.Lang
alias Waveform.Helpers

# OSC internals (if you need low-level control)
alias Waveform.OSC.Group
alias Waveform.OSC.Node

# Helper functions for interactive use
defmodule IExHelpers do
  @moduledoc """
  Convenience functions for working with Waveform in IEx.
  """

  def start do
    IO.puts("🎵 Starting SuperDirt...")
    Helpers.ensure_superdirt_ready()
    IO.puts("✓ Ready to make music!\n")
    help()
  end

  def help do
    IO.puts("""
    🎹 Waveform Quick Reference
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    ## Getting Started
      IExHelpers.start()              # Start SuperDirt and setup

    ## Play Samples
      SuperDirt.play(s: "bd")         # Kick drum
      SuperDirt.play(s: "sn", n: 2)   # Snare variant 2
      SuperDirt.play(s: "arpy", n: 60, gain: 0.8)  # Melodic

    ## Pattern Scheduling
      PatternScheduler.set_cps(0.5)   # Set tempo (120 BPM)

      pattern = [
        {0.0, [s: "bd"]},
        {0.5, [s: "sn"]}
      ]
      PatternScheduler.schedule_pattern(:drums, pattern)

      PatternScheduler.stop_pattern(:drums)
      PatternScheduler.hush()         # Stop all patterns

    ## Run Demos (ordered by complexity)
      c "demos/01_basic_patterns.exs"       # Basic patterns
      c "demos/02_modular_composition.exs"  # Modular style
      c "demos/03_syncopated_rhythm.exs"    # Funk groove
      c "demos/04_complex_harmony.exs"      # Jazz harmony

    ## System Checks
      Mix.Task.run("waveform.check")  # Test SuperDirt
      Mix.Task.run("waveform.doctor") # Verify system

    ## Samples Available (from Dirt-Samples)
      bd, sn, hh, cp, arpy, bass, casio, juno, moog, pad,
      pluck, sitar, stab, and 200+ more!

    ## Help
      h SuperDirt                     # Module docs
      h PatternScheduler
      IExHelpers.samples()            # List common samples
    """)
  end

  def samples do
    IO.puts("""
    📦 Common Dirt-Samples
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Drums:        bd, sn, hh, cp, rim, clap, kick
    Percussion:   tabla, hand, chin, casio
    Bass:         bass, bass0, bass1, bass2, bass3, jungbass
    Melodic:      arpy, pluck, sitar, moog, juno, pad, padlong
    Synth:        stab, feel, future, glass, glitch
    FX:           dr, dr2, dr55, dr_few

    💡 Use with n: parameter for variants
      SuperDirt.play(s: "bd", n: 0)   # First kick variant
      SuperDirt.play(s: "bd", n: 5)   # Sixth kick variant

    Full list: https://github.com/tidalcycles/Dirt-Samples
    """)
  end

  def quick_beat do
    IO.puts("🥁 Starting a quick beat...")
    PatternScheduler.set_cps(0.5625) # 135 BPM

    drums = [
      {0.0, [s: "bd", gain: 0.8]},
      {0.5, [s: "sn", gain: 0.7]},
      {1.0, [s: "bd", gain: 0.8]},
      {1.5, [s: "sn", gain: 0.7]}
    ]

    hats = [
      {0.0, [s: "hh", n: 0, gain: 0.3]},
      {0.25, [s: "hh", n: 1, gain: 0.25]},
      {0.5, [s: "hh", n: 0, gain: 0.3]},
      {0.75, [s: "hh", n: 1, gain: 0.25]},
      {1.0, [s: "hh", n: 0, gain: 0.3]},
      {1.25, [s: "hh", n: 1, gain: 0.25]},
      {1.5, [s: "hh", n: 0, gain: 0.3]},
      {1.75, [s: "hh", n: 1, gain: 0.25]}
    ]

    PatternScheduler.schedule_pattern(:drums, drums)
    PatternScheduler.schedule_pattern(:hats, hats)

    IO.puts("✓ Beat playing! Use PatternScheduler.hush() to stop")
  end
end

# Welcome message
IO.puts("\n🎵 Waveform loaded!")
IO.puts("Type: IExHelpers.help() for quick reference")
IO.puts("      IExHelpers.start() to initialize SuperDirt\n")
