# KinoSpaetzle Integration Guide

**Last Updated:** January 19, 2025
**Waveform Version:** 0.3.0 (unreleased)
**Target:** [KinoSpaetzle](https://github.com/rpmessner/kino_spaetzle)

This document provides a complete reference for integrating KinoSpaetzle with Waveform's SuperDirt and pattern scheduling features.

## Overview

Waveform now provides **everything** KinoSpaetzle needs for TidalCycles-style live coding:

✅ **SuperDirt Integration** - Sample playback and effects
✅ **Pattern Scheduler** - High-precision continuous pattern playback
✅ **OSC Bundles** - Precise timing with configurable latency
✅ **Hot-Swappable Patterns** - Change patterns while playing
✅ **Tempo Control** - Instant BPM/CPS changes
✅ **Verification Tools** - Check if SuperDirt is ready

## Installation & Setup

### 1. Add Waveform Dependency

```elixir
# In mix.exs
def deps do
  [
    {:waveform, "~> 0.3.0"}  # Or git for unreleased version
  ]
end
```

### 2. User Prerequisites

Users need both SuperCollider and SuperDirt installed. Waveform provides tools to verify this:

```bash
# Check if everything is ready
mix waveform.doctor
```

This will check:
- SuperCollider installation (sclang, scsynth)
- SuperDirt Quark installation
- Provide installation instructions if missing

### 3. Runtime Verification

Before sending patterns, verify SuperDirt is loaded:

```elixir
# Option 1: Load SuperDirt via Waveform
Waveform.Lang.send_command("SuperDirt.start;")

# Option 2: Check if it's already loaded
case Waveform.SuperDirt.verify() do
  :ok ->
    # Ready to go!
  {:error, reason} ->
    # Show error to user
end
```

## Core Features for KinoSpaetzle

### 1. SuperDirt Sample Playback

**Module:** `Waveform.SuperDirt`
**Location:** `lib/waveform/super_dirt.ex`

#### Basic Sample Triggering

```elixir
alias Waveform.SuperDirt

# Play a bass drum
SuperDirt.play(s: "bd")

# Play with parameters
SuperDirt.play(
  s: "cp",           # Sample name
  n: 3,              # Sample variant
  speed: 1.5,        # Playback speed
  gain: 0.8,         # Volume
  pan: 0.25,         # Stereo position (-1 to 1)
  room: 0.3,         # Reverb amount
  size: 0.8,         # Reverb size
  orbit: 0           # Audio track (0-11)
)
```

#### Control Commands

```elixir
SuperDirt.hush()         # Emergency stop all sounds
SuperDirt.mute_all()     # Mute all patterns
SuperDirt.unmute_all()   # Unmute all patterns
SuperDirt.unsolo_all()   # Clear solo state
```

#### Tempo Control

```elixir
# Set cycles per second (CPS)
SuperDirt.set_cps(0.5625)  # 135 BPM (default)

# Convert BPM to CPS
bpm = 140
SuperDirt.set_cps(bpm / 240)

# Get current CPS
cps = SuperDirt.get_cps()
```

#### Latency Control

SuperDirt uses OSC bundles with timestamps for precise scheduling:

```elixir
# Adjust scheduling latency (default: 20ms)
SuperDirt.set_latency(0.02)  # 20ms - balanced
SuperDirt.set_latency(0.01)  # 10ms - more responsive, risk of jitter
SuperDirt.set_latency(0.05)  # 50ms - very stable, higher latency

# Get current latency
latency = SuperDirt.get_latency()  # => 0.02
```

#### Automatic Parameters

`SuperDirt.play/1` automatically adds these parameters if not provided:

- `cps` - Cycles per second (from state)
- `cycle` - Event position (auto-incremented)
- `delta` - Event duration (default: 1.0)
- `orbit` - Track number (default: 0)

### 2. Pattern Scheduler

**Module:** `Waveform.PatternScheduler`
**Location:** `lib/waveform/pattern_scheduler.ex`

This is the core engine for continuous pattern playback.

#### Starting the Scheduler

The scheduler starts automatically with Waveform's supervision tree. No manual start needed!

#### Setting Tempo

```elixir
alias Waveform.PatternScheduler

# Set global tempo
PatternScheduler.set_cps(0.5625)  # 135 BPM
PatternScheduler.set_cps(0.5)     # 120 BPM
PatternScheduler.set_cps(0.75)    # 180 BPM

# Tempo changes are instant!
```

#### Scheduling Patterns

Patterns are defined as lists of `{cycle_position, params}` tuples:

```elixir
# Define a drum pattern
# Cycle positions are floats from 0.0 to 1.0
drums = [
  {0.0, [s: "bd"]},      # Kick at start of cycle
  {0.25, [s: "cp"]},     # Clap at 1/4
  {0.5, [s: "sn"]},      # Snare at 1/2
  {0.75, [s: "cp"]}      # Clap at 3/4
]

# Start the pattern looping
PatternScheduler.schedule_pattern(:drums, drums)
```

**Key Points:**
- Pattern ID (`:drums`) can be any atom
- Patterns loop automatically at cycle boundaries
- Multiple patterns can play simultaneously
- Each pattern runs independently

#### Hot-Swapping Patterns

Change a pattern while it's playing without stopping:

```elixir
# Update the drums pattern
new_drums = [
  {0.0, [s: "bd", n: 1]},
  {0.5, [s: "bd", n: 2]}
]

PatternScheduler.update_pattern(:drums, new_drums)
# New pattern takes effect immediately!
```

#### Stopping Patterns

```elixir
# Stop a specific pattern
PatternScheduler.stop_pattern(:drums)

# Emergency stop ALL patterns
PatternScheduler.hush()
```

#### Timing Model

The scheduler uses **cycle-based timing**:

- **Cycle Position:** Float from 0.0 to 1.0 (position within one cycle)
- **CPS:** Cycles per second (tempo)
- **Look-Ahead:** 10ms tick interval for responsive scheduling
- **No Drift:** Uses monotonic clock and cycle arithmetic

**Example Timeline:**
```
CPS = 0.5 (one cycle every 2 seconds)

Cycle:    0.0 -----> 1.0 -----> 2.0 -----> 3.0
Time:     0s        2s         4s         6s
          [pattern loop]  [pattern loop]
```

#### Advanced: Multiple Patterns

```elixir
# Kick pattern
kicks = [{0.0, [s: "bd"]}, {0.5, [s: "bd"]}]
PatternScheduler.schedule_pattern(:kicks, kicks)

# Hi-hat pattern (8th notes)
hats = [
  {0.0, [s: "hh"]}, {0.125, [s: "hh"]},
  {0.25, [s: "hh"]}, {0.375, [s: "hh"]},
  {0.5, [s: "hh"]}, {0.625, [s: "hh"]},
  {0.75, [s: "hh"]}, {0.875, [s: "hh"]}
]
PatternScheduler.schedule_pattern(:hats, hats)

# Bass pattern
bass = [{0.0, [s: "bass", n: 0]}, {0.75, [s: "bass", n: 2]}]
PatternScheduler.schedule_pattern(:bass, bass)

# All three play simultaneously!
```

### 3. OSC Bundle Support

**Module:** `Waveform.SuperDirt.UDP`
**Location:** `lib/waveform/super_dirt/udp.ex`

All SuperDirt messages are sent as OSC bundles with timestamps for precise timing.

**How it works:**
1. Event is scheduled by PatternScheduler
2. `SuperDirt.play/1` is called
3. OSC bundle is created with timestamp = `now + latency`
4. Bundle is sent to SuperDirt (port 57120)
5. SuperDirt plays the event at the exact timestamp

**Benefits:**
- No timing jitter
- Precise synchronization
- Look-ahead scheduling
- Stable playback even under load

## Integration Architecture

### Recommended Flow for KinoSpaetzle

```
┌─────────────────────────────────────────┐
│  KinoSpaetzle (Pattern Parser)          │
│  - Parse Uzu mini-notation              │
│  - Convert to event lists                │
│  - Handle pattern transformations        │
└──────────────┬──────────────────────────┘
               │
               │ events = [{0.0, [s: "bd"]}, ...]
               ↓
┌─────────────────────────────────────────┐
│  Waveform.PatternScheduler               │
│  - Cycle-based timing                    │
│  - Look-ahead scheduling                 │
│  - Hot-swappable patterns                │
└──────────────┬──────────────────────────┘
               │
               │ SuperDirt.play(params)
               ↓
┌─────────────────────────────────────────┐
│  Waveform.SuperDirt                      │
│  - OSC bundle creation                   │
│  - Timestamp calculation                 │
│  - Parameter formatting                  │
└──────────────┬──────────────────────────┘
               │
               │ OSC bundle with timestamp
               ↓
┌─────────────────────────────────────────┐
│  SuperDirt (in SuperCollider)            │
│  - Sample playback                       │
│  - Effects processing                    │
│  - Audio output                          │
└─────────────────────────────────────────┘
```

### What KinoSpaetzle Should Do

1. **Parse Patterns** - Convert mini-notation to event lists
   ```elixir
   "bd cp sn cp" -> [
     {0.0, [s: "bd"]},
     {0.25, [s: "cp"]},
     {0.5, [s: "sn"]},
     {0.75, [s: "cp"]}
   ]
   ```

2. **Schedule Patterns** - Send to PatternScheduler
   ```elixir
   PatternScheduler.schedule_pattern(pattern_id, events)
   ```

3. **Handle Updates** - When user changes pattern
   ```elixir
   PatternScheduler.update_pattern(pattern_id, new_events)
   ```

4. **Control Playback** - Start/stop/tempo
   ```elixir
   PatternScheduler.stop_pattern(pattern_id)
   PatternScheduler.set_cps(new_cps)
   ```

### What Waveform Handles

- ✅ Precise timing and scheduling
- ✅ OSC communication with SuperDirt
- ✅ Cycle-based arithmetic
- ✅ Look-ahead window management
- ✅ Event deduplication
- ✅ Tempo changes
- ✅ Multiple concurrent patterns

## API Reference

### Waveform.SuperDirt

```elixir
# Sample playback
@spec play(keyword()) :: :ok
SuperDirt.play(s: "bd", n: 0, gain: 0.8)

# Control
@spec hush() :: :ok
@spec mute_all() :: :ok
@spec unmute_all() :: :ok
@spec unsolo_all() :: :ok

# Tempo
@spec set_cps(number()) :: :ok
@spec get_cps() :: float()

# Latency
@spec set_latency(number()) :: :ok
@spec get_latency() :: float()

# Verification
@spec verify() :: :ok | {:error, atom()}
```

### Waveform.PatternScheduler

```elixir
# Starting (automatic via supervision tree)
@spec start_link(keyword()) :: GenServer.on_start()

# Tempo
@spec set_cps(number()) :: :ok

# Pattern management
@spec schedule_pattern(atom(), [{float(), keyword()}]) :: :ok
@spec update_pattern(atom(), [{float(), keyword()}]) :: :ok
@spec stop_pattern(atom()) :: :ok
@spec hush() :: :ok
```

### Waveform.Lang

```elixir
# Send commands to SuperCollider
@spec send_command(String.t()) :: :ok

# Example: Load SuperDirt
Waveform.Lang.send_command("SuperDirt.start;")
```

## Common Parameters

SuperDirt accepts many parameters. Here are the most common ones KinoSpaetzle users will want:

### Core Parameters

- `s` - Sample/sound name (e.g., "bd", "cp", "sn")
- `n` - Sample variant number (default: 0)
- `speed` - Playback speed (default: 1.0)
- `gain` - Volume (default: 1.0)
- `pan` - Stereo position, -1 (left) to 1 (right)
- `orbit` - Audio track/orbit (0-11, default: 0)

### Envelope

- `attack` - Attack time
- `decay` - Decay time
- `sustain` - Sustain level
- `release` - Release time

### Effects

- `room` - Reverb amount (0-1)
- `size` - Reverb size (0-1)
- `delay` - Delay amount (0-1)
- `delaytime` - Delay time
- `delayfeedback` - Delay feedback
- `crush` - Bit crusher amount
- `coarse` - Sample rate reduction

### Filters

- `cutoff` - Low-pass filter cutoff frequency
- `resonance` - Filter resonance
- `hcutoff` - High-pass filter cutoff
- `hresonance` - High-pass resonance
- `bandf` - Band-pass filter frequency
- `bandq` - Band-pass filter Q

### Sample Manipulation

- `begin` - Start position in sample (0-1)
- `end` - End position in sample (0-1)
- `loop` - Number of times to loop
- `legato` - Note length relative to delta

See [SuperDirt documentation](https://github.com/musikinformatik/SuperDirt) for complete parameter list.

## Example: Complete Integration

Here's a minimal example of how KinoSpaetzle might use Waveform:

```elixir
defmodule KinoSpaetzle.Player do
  alias Waveform.PatternScheduler
  alias Waveform.SuperDirt

  def start_pattern(pattern_id, uzu_string) do
    # 1. Parse the Uzu pattern
    events = parse_uzu(uzu_string)

    # 2. Schedule it
    PatternScheduler.schedule_pattern(pattern_id, events)
  end

  def update_pattern(pattern_id, uzu_string) do
    # Parse and hot-swap
    events = parse_uzu(uzu_string)
    PatternScheduler.update_pattern(pattern_id, events)
  end

  def stop_pattern(pattern_id) do
    PatternScheduler.stop_pattern(pattern_id)
  end

  def set_tempo(bpm) do
    cps = bpm / 240
    PatternScheduler.set_cps(cps)
  end

  def hush do
    PatternScheduler.hush()
  end

  # Example parser (simplified)
  defp parse_uzu("bd cp sn cp") do
    [
      {0.0, [s: "bd"]},
      {0.25, [s: "cp"]},
      {0.5, [s: "sn"]},
      {0.75, [s: "cp"]}
    ]
  end
end
```

## Testing Without SuperDirt

Waveform provides a NoOp transport for testing:

```elixir
# In config/test.exs
config :waveform,
  superdirt_transport: Waveform.SuperDirt.NoOp

# Now tests won't send actual UDP packets
```

## Troubleshooting

### SuperDirt Not Found

**Error:** `mix waveform.doctor` reports SuperDirt not installed

**Solution:**
```supercollider
// In SuperCollider IDE
Quarks.install("SuperDirt");
thisProcess.recompile;
```

### No Sound Output

**Possible causes:**
1. SuperDirt not started in SuperCollider
   ```elixir
   Waveform.Lang.send_command("SuperDirt.start;")
   ```

2. Wrong audio device selected in SuperCollider

3. Volume/gain too low
   ```elixir
   SuperDirt.play(s: "bd", gain: 1.5)
   ```

### Timing Issues

**Symptoms:** Events play late or jittery

**Solutions:**
1. Increase latency for stability
   ```elixir
   SuperDirt.set_latency(0.05)  # 50ms
   ```

2. Check system load - pattern scheduler needs CPU time

3. Verify SuperCollider server is running smoothly

## Migration Notes

### From Direct OSC

If KinoSpaetzle was planning to send OSC messages directly:

**Before (hypothetical):**
```elixir
:osc.encode({"/dirt/play", [s: "bd"]})
|> send_to_superdirt()
```

**After (with Waveform):**
```elixir
SuperDirt.play(s: "bd")
# Waveform handles OSC encoding, bundles, timestamps, etc.
```

### From Custom Scheduler

If KinoSpaetzle was planning to build its own scheduler:

**Before (hypothetical):**
```elixir
# Custom timing logic, Process.send_after, etc.
```

**After (with Waveform):**
```elixir
# Just provide events, Waveform handles all timing
events = [{0.0, [s: "bd"]}, {0.5, [s: "sn"]}]
PatternScheduler.schedule_pattern(:drums, events)
```

## Performance Characteristics

### Pattern Scheduler

- **Tick Interval:** 10ms (100 ticks/second)
- **Look-Ahead:** 20ms by default (configurable)
- **Overhead:** ~2400 window checks/second with 3 patterns of 8 events each
- **Drift:** None (uses monotonic clock and cycle arithmetic)
- **Latency:** Configurable, 10-50ms typical

### Memory Usage

- **Per Pattern:** ~200 bytes (small struct with event list)
- **Scheduled Events:** MapSet tracks sent events (grows slowly)
- **Cleanup:** Consider periodic cleanup of old scheduled events (not implemented yet)

### Concurrency

- All modules are GenServers, safe for concurrent access
- Multiple KinoSpaetzle cells can use the same scheduler
- Pattern IDs must be unique (use cell-specific prefixes)

## Future Enhancements

Potential future additions to Waveform that might benefit KinoSpaetzle:

- [ ] Buffer management for custom samples
- [ ] MIDI support
- [ ] Pattern callbacks (on cycle, on event)
- [ ] Pattern query API (get current patterns, state)
- [ ] Scheduled event cleanup
- [ ] Pattern groups/namespaces

## Getting Help

- **Waveform Issues:** https://github.com/rpmessner/waveform/issues
- **Session Docs:** See `docs/sessions/` for recent changes
- **SuperDirt Docs:** https://github.com/musikinformatik/SuperDirt
- **TidalCycles Reference:** https://tidalcycles.org/

## Version History

- **v0.3.0** (unreleased) - SuperDirt integration, PatternScheduler
- **v0.2.0** (2025-01-19) - Simplified OSC transport
- **v0.1.0** (2024-01-30) - Initial release

---

**Happy Live Coding!** 🎵
