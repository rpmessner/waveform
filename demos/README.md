# Waveform Demo Songs

This directory contains demo files showcasing different approaches to creating music with Waveform and SuperDirt.

## Prerequisites

Before running any demos, make sure:

1. SuperCollider is installed (`brew install supercollider`)
2. SuperDirt is installed (in SuperCollider: `Quarks.install("SuperDirt")`)
3. SuperDirt is running:
   ```elixir
   Waveform.Lang.send_command("SuperDirt.start;")
   ```

Or verify everything with:
```bash
mix waveform.doctor
```

## Demo Files

### 1. Radiohead - Creep

Two implementation styles demonstrating different organizational approaches:

**`creep_simple.exs`** - Simple Pattern Style
- Direct, straightforward pattern definitions
- Patterns defined as plain lists
- Good for: Quick experimentation, simple songs
- Shows: Basic pattern structure, multiple simultaneous patterns

```bash
mix run demos/creep_simple.exs
```

**`creep_modular.exs`** - Modular/Compositional Style
- Patterns built with helper functions
- Supports variations (quiet vs loud sections)
- Good for: Complex arrangements, reusable components
- Shows: Function composition, dynamic variation, modules

```bash
mix run demos/creep_modular.exs
```

### 2. John Coltrane - Giant Steps

**`giant_steps.exs`** - Complex Harmony Demo
- Demonstrates rapid chord changes
- Shows cycle-based timing with dense events
- Good for: Jazz progressions, fast tempos
- Shows: Complex harmonic patterns, tempo variations

```bash
mix run demos/giant_steps.exs
```

### 3. Stevie Wonder - Superstition

**`superstition.exs`** - Funk Groove Demo
- Syncopated rhythms and riffs
- Demonstrates timing precision for funk grooves
- Good for: Rhythmic complexity, groove-based music
- Shows: Syncopation, 16th note patterns, multiple rhythm layers

```bash
mix run demos/superstition.exs
```

## Implementation Patterns Comparison

### Style 1: Simple/Direct Pattern Definition

**Best for:** Quick sketches, simple songs, learning

```elixir
# Define patterns as plain data
bass = [
  {0.0, [s: "bass", n: 55, gain: 0.8]},
  {1.0, [s: "bass", n: 59, gain: 0.8]}
]

# Start playing
PatternScheduler.schedule_pattern(:bass, bass)
```

**Pros:**
- Very straightforward
- Easy to understand
- Minimal boilerplate

**Cons:**
- Hard to reuse
- No built-in variations
- Gets messy with complex songs

### Style 2: Modular/Functional

**Best for:** Complex arrangements, reusable components, variations

```elixir
defmodule MySong do
  def play do
    PatternScheduler.set_cps(0.5)
    PatternScheduler.schedule_pattern(:bass, build_bass())
    PatternScheduler.schedule_pattern(:drums, build_drums())
  end

  def play_quiet do
    PatternScheduler.schedule_pattern(:bass, build_bass(gain: 0.3))
  end

  defp build_bass(opts \\ []) do
    gain = Keyword.get(opts, :gain, 0.8)
    # Build pattern with configurable parameters
    [...]
  end
end
```

**Pros:**
- Highly reusable
- Easy to create variations
- Clean organization

**Cons:**
- More verbose
- Requires more planning

### Style 3: Sectioned/Structured (potential future demo)

**Best for:** Full songs with verse/chorus/bridge structure

```elixir
defmodule SongWithStructure do
  def play do
    play_section(:intro, 4)    # 4 cycles
    play_section(:verse, 8)    # 8 cycles
    play_section(:chorus, 8)
    # etc.
  end

  defp play_section(:intro, _cycles) do
    # Load intro patterns
  end
end
```

## Key Concepts

### Cycle-Based Timing

All events are positioned within a cycle (0.0 to 1.0):

```elixir
[
  {0.0, [...]},    # Start of cycle
  {0.25, [...]},   # Quarter way through
  {0.5, [...]},    # Halfway
  {0.75, [...]},   # Three-quarters
  # Wraps back to 0.0
]
```

### Tempo (CPS)

Convert BPM to Cycles Per Second:

```elixir
# 120 BPM
cps = 120 / 240  # = 0.5
PatternScheduler.set_cps(0.5)
```

### Pattern Control

```elixir
# Start a pattern
PatternScheduler.schedule_pattern(:drums, pattern)

# Update it while playing (hot-swap)
PatternScheduler.update_pattern(:drums, new_pattern)

# Stop one pattern
PatternScheduler.stop_pattern(:drums)

# Stop everything
PatternScheduler.hush()
```

### SuperDirt Parameters

Common parameters you'll use:

- `s` - Sample name ("bd", "sn", "cp", "hh", "bass", etc.)
- `n` - Sample variant (0, 1, 2...)
- `gain` - Volume (0.0 to 1.0+)
- `speed` - Playback speed (1.0 = normal)
- `pan` - Stereo position (-1.0 to 1.0)
- `room` - Reverb amount
- `cutoff` - Filter cutoff frequency

## Tips

1. **Start Simple**: Begin with the simple style, then refactor to modular
2. **Use IEx**: Run `iex -S mix` and experiment interactively
3. **Hot-Swap**: Update patterns while they're playing to hear changes immediately
4. **Layer Gradually**: Start with one pattern, add more one at a time
5. **Mind the Gain**: Keep total gain below 1.0 to avoid clipping

## Next Steps

- Try modifying the patterns
- Create your own song demos
- Experiment with different SuperDirt samples
- Combine multiple implementation styles
- Build a full song structure with sections

## Resources

- [Waveform README](../README.md)
- [SuperDirt GitHub](https://github.com/musikinformatik/SuperDirt)
- [TidalCycles Patterns](https://tidalcycles.org/docs/)
