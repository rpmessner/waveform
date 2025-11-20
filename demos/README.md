# Waveform Demo Patterns

This directory contains demo files showcasing different approaches to creating music with Waveform and SuperDirt, ordered by complexity from beginner to advanced.

## Prerequisites

Before running any demos, make sure:

1. SuperCollider is installed (`brew install supercollider`)
2. SuperDirt is installed (in SuperCollider: `Quarks.install("SuperDirt")`)
3. Dirt-Samples are installed (`mix waveform.install_samples`)

Or verify everything with:
```bash
mix waveform.doctor
mix waveform.check
```

## Demo Files (Ordered by Complexity)

### 1. Basic Patterns (Easiest)

**`01_basic_patterns.exs`** - Simple Pattern Style
- Direct, straightforward pattern definitions
- Patterns defined as plain lists
- Good for: Quick experimentation, learning the basics
- Shows: Basic pattern structure, multiple simultaneous patterns
- Musical style: Simple chord progression with arpeggios

```bash
mix run demos/01_basic_patterns.exs
```

**What you'll learn:**
- How to define patterns as data
- Cycle-based timing (0.0 to 1.0)
- Basic SuperDirt parameters (s, n, gain)
- Running multiple patterns simultaneously

### 2. Modular Composition

**`02_modular_composition.exs`** - Modular/Compositional Style
- Patterns built with helper functions
- Supports variations (quiet vs loud sections)
- Good for: Complex arrangements, reusable components
- Shows: Function composition, dynamic variation, modules
- Musical style: Chord progression with dynamic controls

```bash
mix run demos/02_modular_composition.exs
```

**What you'll learn:**
- Organizing patterns with functions
- Creating variation functions (play_quiet, play_loud)
- Parameterized pattern builders
- Module-based organization

### 3. Syncopated Rhythm

**`03_syncopated_rhythm.exs`** - Funk Groove Demo
- Syncopated rhythms and riffs
- Demonstrates timing precision for funk grooves
- Good for: Rhythmic complexity, groove-based music
- Shows: Syncopation, 16th note patterns, multiple rhythm layers
- Musical style: Funk groove with syncopated elements

```bash
mix run demos/03_syncopated_rhythm.exs
```

**What you'll learn:**
- Syncopated rhythms (off-beat timing)
- 16th note patterns (0.0625 increments)
- Layering multiple rhythmic elements
- Creating groove with timing precision

### 4. Complex Harmony (Most Advanced)

**`04_complex_harmony.exs`** - Complex Harmony Demo
- Demonstrates rapid chord changes
- Shows cycle-based timing with dense events
- Good for: Jazz progressions, fast tempos
- Shows: Complex harmonic patterns, tempo variations
- Musical style: Fast chord progression through multiple key centers

```bash
mix run demos/04_complex_harmony.exs
```

**What you'll learn:**
- Rapid chord changes (8+ per cycle)
- Dense event patterns
- Fast tempos (240 BPM)
- Walking bass patterns
- Complex harmonic movement

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

**Example:** `01_basic_patterns.exs`

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

**Examples:** `02_modular_composition.exs`, `03_syncopated_rhythm.exs`, `04_complex_harmony.exs`

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

- `s` - Sample name ("bd", "sn", "cp", "hh", "bass", "arpy", etc.)
- `n` - Sample variant or MIDI note number (0, 1, 2... or 60, 64, 67...)
- `gain` - Volume (0.0 to 1.0+)
- `speed` - Playback speed (1.0 = normal)
- `pan` - Stereo position (-1.0 to 1.0)
- `room` - Reverb amount
- `cutoff` - Filter cutoff frequency

## Suggested Learning Path

1. **Start with `01_basic_patterns.exs`**
   - Understand cycle-based timing
   - Get comfortable with basic patterns
   - Experiment with changing parameters

2. **Try `02_modular_composition.exs`**
   - See how to organize code with functions
   - Try the different variations (play_quiet, play_loud)
   - Understand parameterized patterns

3. **Explore `03_syncopated_rhythm.exs`**
   - Learn about syncopation and groove
   - Practice with 16th note timing
   - Layer multiple rhythmic elements

4. **Challenge yourself with `04_complex_harmony.exs`**
   - Handle dense, rapid patterns
   - Work with complex harmonic movement
   - Try the slow version (play_slow) first

## Tips

1. **Start Simple**: Run the demos in order (01 → 04)
2. **Use IEx**: Run `iex -S mix` and experiment interactively
3. **Hot-Swap**: Update patterns while they're playing to hear changes immediately
4. **Layer Gradually**: Start with one pattern, add more one at a time
5. **Mind the Gain**: Keep total gain below 1.0 to avoid clipping
6. **Modify and Experiment**: Change notes, timing, samples - make them your own!

## Next Steps

- Try modifying the patterns
- Create your own musical patterns
- Experiment with different SuperDirt samples (see: `IExHelpers.samples()`)
- Combine implementation styles
- Build a full song structure with sections

## Resources

- [Waveform README](../README.md)
- [SuperDirt GitHub](https://github.com/musikinformatik/SuperDirt)
- [Dirt-Samples Library](https://github.com/tidalcycles/Dirt-Samples)
- [TidalCycles Documentation](https://tidalcycles.org/docs/)
