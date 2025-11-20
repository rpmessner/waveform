# Session: SuperDirt Integration

**Date:** January 19, 2025
**Duration:** Full session
**Branch:** master

## Overview

This session implemented SuperDirt integration for Waveform, enabling communication with SuperDirt (TidalCycles' audio engine) on port 57120, separate from the existing direct SuperCollider OSC communication on port 57110.

## What Was Accomplished

### 1. SuperDirt Module Implementation

Created a complete SuperDirt communication layer with **96.7% test coverage**:

- **`lib/waveform/super_dirt.ex`** (294 lines) - Main SuperDirt GenServer
  - OSC message sending to port 57120 (`/dirt/play`)
  - Pattern event playback with automatic parameter handling
  - Cycle tracking for event sequencing
  - Tempo control (CPS - cycles per second)
  - Control messages (hush, mute, unmute, unsolo)

- **Transport Layer** (similar to OSC module)
  - `lib/waveform/super_dirt/transport.ex` - Behaviour definition
  - `lib/waveform/super_dirt/udp.ex` - Production UDP implementation
  - `lib/waveform/super_dirt/no_op.ex` - Test implementation

### 2. API Design

**Sample Playback:**
```elixir
SuperDirt.play(s: "bd", n: 0, gain: 0.8)
SuperDirt.play(s: "cp", speed: 1.5, room: 0.3, size: 0.8)
```

**Control Commands:**
```elixir
SuperDirt.hush()         # Stop all sounds
SuperDirt.mute_all()     # Mute all patterns
SuperDirt.unmute_all()   # Unmute all patterns
SuperDirt.unsolo_all()   # Clear solo state
```

**Tempo Control:**
```elixir
SuperDirt.set_cps(0.5)        # 120 BPM
SuperDirt.set_cps(140 / 240)  # 140 BPM
```

### 3. Automatic Parameter Handling

SuperDirt requires specific metadata parameters. The module automatically adds:
- `cps` - Cycles per second (tempo)
- `cycle` - Event position since startup (incremented on each play)
- `delta` - Event duration (default: 1.0)
- `orbit` - Track/orbit number (default: 0)

User parameters (s, n, speed, gain, effects) are passed through unchanged.

### 4. Test Suite (23 tests, 100% passing)

Created comprehensive tests in `test/waveform/super_dirt_test.exs`:

- **play/1 tests** (9 tests)
  - Basic sound playback
  - Multiple parameters
  - Effect parameters (room, size, delay)
  - Custom orbit and delta
  - Pan, begin, end parameters
  - String vs atom sound names

- **Control message tests** (4 tests)
  - hush, mute_all, unmute_all, unsolo_all

- **set_cps/1 tests** (4 tests)
  - Float, integer, BPM conversion

- **Cycle tracking tests** (2 tests)
  - Single increment
  - Multiple increments

- **State management tests** (4 tests)
  - Default CPS (0.5625 = 135 BPM)
  - Default port (57120)
  - Default host (localhost)
  - CPS updates

### 5. Configuration Updates

**Test Configuration** (`config/test.exs`):
```elixir
config :waveform,
  osc_transport: Waveform.OSC.NoOp,
  superdirt_transport: Waveform.SuperDirt.NoOp  # Added
```

**Supervision Tree** (`lib/waveform/application.ex`):
```elixir
children = [
  {Waveform.Lang, nil},
  {Waveform.OSC, nil},
  {Waveform.SuperDirt, []},  # Added
  {Waveform.OSC.Node.ID, 100},
  {Waveform.OSC.Node, nil},
  {Waveform.OSC.Group, nil}
]
```

## Key Technical Decisions

### 1. Separate Module vs Extending OSC

**Decision:** Created separate `Waveform.SuperDirt` module

**Rationale:**
- SuperDirt and SuperCollider serve different purposes
- Different ports (57120 vs 57110)
- Different message formats (`/dirt/play` vs `/s_new`)
- Users may want only one or the other
- Cleaner separation of concerns

### 2. Dual Communication Architecture

Waveform now supports two independent communication paths to the same SuperCollider instance:

```
┌─────────────────────────────────┐
│   Waveform.SuperDirt            │  → Port 57120
│   (pattern-based samples)       │
└─────────────┬───────────────────┘
              ↓
┌─────────────────────────────────┐
│   SuperDirt Library             │
│   (inside SuperCollider)        │
└─────────────┬───────────────────┘
              ↓
┌─────────────────────────────────┐
│   Waveform.OSC / Waveform.Lang  │  → Port 57110
│   (direct synth control)        │
└─────────────┬───────────────────┘
              ↓
┌─────────────────────────────────┐
│   scsynth (SuperCollider)       │
└─────────────────────────────────┘
```

Users can use both simultaneously:
```elixir
# SuperDirt sample playback
SuperDirt.play(s: "bd")

# Direct synth control
Synth.trigger("custom_synth", freq: 220)
```

### 3. OSC Bundle Support Deferred

**Current Implementation:** Sends messages as regular OSC commands

**Planned:** OSC bundles with timestamps (TODO in `lib/waveform/super_dirt/udp.ex:14`)

**Rationale:**
- The erlang-osc library's bundle format needs investigation
- Regular OSC messages work for basic functionality
- Bundles are needed for precise timing in pattern engines
- Can be added later without breaking API

### 4. Cycle Counter Design

**Implementation:** GenServer state tracks cycle counter, increments on each `play/1`

**Rationale:**
- Simple, stateful approach
- Matches TidalCycles' cycle-based timing model
- Foundation for future pattern scheduling
- Can be reset/synchronized later if needed

## Architecture Notes

### SuperDirt vs TidalCycles Responsibilities

**Important clarification discovered during session:**

SuperDirt is **NOT** a pattern parser. It's only a sample playback engine:

**SuperDirt does:**
- Receive individual OSC events (`/dirt/play`)
- Play samples from its library
- Apply effects (reverb, delay, filters)
- Manage orbits (independent audio tracks)

**SuperDirt does NOT:**
- Parse pattern strings (e.g., `"bd cp sn cp"`)
- Understand mini-notation
- Schedule future events
- Handle pattern transformations

**TidalCycles does:**
- Parse pattern languages
- Evaluate patterns over time
- Send pre-computed events to SuperDirt

**Implication for KinoSpaetzle:**
The pattern parsing and scheduling engine needs to be built separately. Waveform.SuperDirt just provides the transport layer for triggering individual events.

### Sample/Sound Parameter (`s:`)

The `s:` parameter is simply the **sample folder name** in SuperDirt's sample library:

```
SuperDirt-samples/
├── bd/           ← s: "bd"
├── cp/           ← s: "cp"
├── sn/           ← s: "sn"
└── ...
```

The `n:` parameter selects which variant (file) within that folder:
```elixir
SuperDirt.play(s: "bd", n: 0)  # bd/BD0000.wav
SuperDirt.play(s: "bd", n: 1)  # bd/BD0001.wav
```

Waveform doesn't know or care what samples exist - it just sends the names to SuperDirt.

## Coverage Report

Overall coverage increased from **21.6% → 28.9%** (+7.3%)

```
COV    FILE                                        LINES RELEVANT   MISSED
 96.7% lib/waveform/super_dirt.ex                    294       31        1
100.0% lib/waveform/super_dirt/no_op.ex               16        2        0
  0.0% lib/waveform/super_dirt/transport.ex           41        0        0
  0.0% lib/waveform/super_dirt/udp.ex                 25        4        4
```

**Total tests:** 58 (up from 35)
**All passing:** 0 failures

## Commits Created

1. **Add SuperDirt transport layer modules**
   - Added transport behaviour
   - Added UDP and NoOp implementations
   - Configurable for testing

2. **Add Waveform.SuperDirt GenServer implementation**
   - Main SuperDirt module with play/1 and control functions
   - Automatic parameter handling (cps, cycle, delta, orbit)
   - Cycle tracking and tempo control

3. **Add SuperDirt to supervision tree and test config**
   - Updated Application supervisor
   - Added superdirt_transport config

4. **Add comprehensive SuperDirt test suite**
   - 23 tests covering all functionality
   - 96.7% coverage

## Areas for Future Work

### 1. OSC Bundle Support with Timestamps

Currently sends regular OSC messages. SuperDirt expects bundles with timestamps for precise scheduling:

```elixir
# TODO in lib/waveform/super_dirt/udp.ex
{:bundle, timestamp, [message]}
```

**Priority:** Medium - needed for pattern engines with look-ahead scheduling

### 2. Pattern Scheduling Utilities (Roadmap Item #2)

The next critical feature for KinoSpaetzle:
- Cycle-based timing model
- Event scheduling with latency compensation
- BPM/cycle synchronization
- Look-ahead scheduling

### 3. Buffer Management (Roadmap Item #6)

For custom sample playback:
- Load audio files into SuperCollider buffers
- Buffer ID allocation
- Buffer info queries

### 4. Sample Rate API

`Waveform.ServerInfo` stores sample rate but doesn't expose it. Add:
```elixir
ServerInfo.sample_rate()  # Returns: 48000
```

### 5. Error Handling

SuperCollider silently fails if synths/samples don't exist. Consider:
- Synth definition validation
- Error callbacks when playback fails
- List available samples/synths

## Related Files Modified

**New Files:**
- `lib/waveform/super_dirt.ex`
- `lib/waveform/super_dirt/transport.ex`
- `lib/waveform/super_dirt/udp.ex`
- `lib/waveform/super_dirt/no_op.ex`
- `test/waveform/super_dirt_test.exs`

**Modified Files:**
- `lib/waveform/application.ex` - Added SuperDirt to supervision tree
- `config/test.exs` - Added superdirt_transport config

## Notes for Future Claude Sessions

When working with SuperDirt:

1. **Two separate ports:**
   - Port 57110: Direct SuperCollider (Waveform.OSC)
   - Port 57120: SuperDirt (Waveform.SuperDirt)

2. **Both can be used simultaneously** in the same SuperCollider session

3. **SuperDirt must be loaded in SuperCollider first:**
   ```elixir
   Waveform.Lang.send_command("SuperDirt.start;")
   ```

4. **Sample names are just strings** - SuperDirt looks them up in its sample library

5. **Test mode uses NoOp transport** - no actual UDP messages sent

6. **Cycle counter is stateful** - increments on each play/1 call

## Resources

- SuperDirt documentation: https://github.com/musikinformatik/SuperDirt
- TidalCycles SuperDirt API: https://userbase.tidalcycles.org/SuperDirt_API.html
- TidalCycles OSC docs: https://tidalcycles.org/docs/configuration/MIDIOSC/osc/
- Previous session: docs/sessions/2025-01-19-test-coverage.md
