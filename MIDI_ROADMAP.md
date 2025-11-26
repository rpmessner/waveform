# Waveform MIDI Integration - Roadmap

**Status**: Planning Phase
**Purpose**: Add MIDI output as a parallel audio output option to OSC/SuperCollider

---

## Overview

MIDI support will be added to Waveform as an alternative output format, parallel to OSC/SuperCollider. This allows patterns to drive hardware and software synthesizers via MIDI instead of (or in addition to) SuperCollider.

**Key Principle**: MIDI is another audio output format, not a different concern from SuperCollider/OSC. Both convert musical events → audio device commands with precise timing.

---

## Architecture

### Current Audio Flow
```
Waveform.PatternScheduler (timing/scheduling)
  ↓
Waveform.SuperDirt (OSC → SuperCollider)
  ↓
Audio Hardware
```

### With MIDI Support
```
Waveform.PatternScheduler (timing/scheduling)
  ├→ Waveform.SuperDirt (OSC → SuperCollider)
  └→ Waveform.MIDI (MIDI messages → hardware/software)
      ↓
    MIDI Devices
```

### Design Principles

1. **Parallel Output**: MIDI is a peer to SuperDirt, not a replacement
2. **Same Event Format**: Use existing `{pos, params}` tuple format
3. **Precise Timing**: Leverage PatternScheduler's 10ms tick loop
4. **Configuration-Based**: Choose output via configuration, not code changes
5. **Composable**: Support sending to both OSC and MIDI simultaneously

---

## Implementation Plan

### Phase 1: Core MIDI Output (Est. 4-5 hours)

#### 1.1 MIDI Module Foundation

**File**: `lib/waveform/midi.ex`

```elixir
defmodule Waveform.MIDI do
  @moduledoc """
  MIDI output for Waveform.PatternScheduler.

  Parallel to Waveform.SuperDirt (OSC output). Converts pattern events
  to MIDI messages and sends them to configured MIDI ports.

  ## Event Format

  Events use the same format as SuperDirt:

      {cycle_position, [
        note: 60,           # MIDI note number (or uses :s if present)
        velocity: 80,       # MIDI velocity (or uses :gain)
        channel: 1,         # MIDI channel (default: 1)
        duration: 0.25,     # Note duration in cycles
        port: "IAC Driver"  # MIDI port name (optional)
      ]}

  ## Parameter Mapping

  - `:note` or `:n` → MIDI note number
  - `:s` → Sample name converted to note (if numeric or mapped)
  - `:velocity` or `:gain` → MIDI velocity (0-127)
  - `:channel` → MIDI channel (1-16, default: 1)
  - `:duration` → Note length (default: 0.9 of cycle position interval)
  - `:port` → MIDI port name (default: from config)
  - `:cc` → Control change messages (e.g., cc: %{1 => 64, 7 => 100})

  ## Configuration

      config :waveform,
        midi_enabled: true,
        midi_port: "IAC Driver Bus 1",
        midi_default_channel: 1,
        midi_velocity_curve: :linear  # or :exponential

  ## Usage

      # Single MIDI note
      MIDI.play(note: 60, velocity: 80, channel: 1)

      # Pattern with MIDI output
      PatternScheduler.schedule_pattern(:melody, events, output: :midi)

      # Send to both OSC and MIDI
      PatternScheduler.schedule_pattern(:drums, events, output: [:supercollider, :midi])
  """

  # Functions to implement
  def play(params)
  def note_on(note, velocity, channel, port)
  def note_off(note, channel, port)
  def control_change(cc_number, value, channel, port)
  def program_change(program, channel, port)
end
```

**Dependencies**: Add Midiex library to mix.exs (Rustler NIF wrapping midir)

**Tasks**:
- [ ] Add Midiex dependency (`{:midiex, "~> 0.6"}`)
- [ ] Create `Waveform.MIDI` module
- [ ] Implement `play/1` - Convert params to MIDI note on/off
- [ ] Implement `note_on/4` - Send MIDI note on
- [ ] Implement `note_off/3` - Send MIDI note off
- [ ] Handle parameter mapping (note, velocity, channel)
- [ ] Add configuration for default MIDI port and channel

#### 1.2 Port Management

**File**: `lib/waveform/midi/port.ex`

```elixir
defmodule Waveform.MIDI.Port do
  @moduledoc """
  MIDI port discovery and management.
  """

  def list_ports()
  def open_port(port_name)
  def close_port(port_name)
  def ensure_port_open(port_name)
end
```

**Tasks**:
- [ ] Implement port discovery (list available MIDI devices)
- [ ] Implement port opening/closing
- [ ] Add port caching (keep open for performance)
- [ ] Handle port errors gracefully

#### 1.3 PatternScheduler Integration

**File**: `lib/waveform/pattern_scheduler.ex` (modify existing)

**Changes**:
```elixir
# In PatternScheduler
defp play_event(event, pattern_id, opts) do
  output = opts[:output] || :supercollider

  case output do
    :supercollider ->
      SuperDirt.play(event)
    :midi ->
      MIDI.play(event)
    outputs when is_list(outputs) ->
      Enum.each(outputs, fn out ->
        case out do
          :supercollider -> SuperDirt.play(event)
          :midi -> MIDI.play(event)
        end
      end)
  end
end
```

**Tasks**:
- [ ] Add `:output` option to `schedule_pattern/3`
- [ ] Support `:supercollider`, `:midi`, or list of both
- [ ] Update `play_event/3` to route to appropriate output
- [ ] Maintain backward compatibility (default to SuperCollider)

---

### Phase 2: Advanced Features (Est. 3-4 hours)

#### 2.1 Control Change Messages

**Features**:
- [ ] Support CC messages in event params
- [ ] Implement `control_change/4`
- [ ] Map common params to CCs (e.g., cutoff → CC74)
- [ ] Tests for CC messages

**Usage**:
```elixir
# Send CC along with note
{0.0, [
  note: 60,
  cc: %{1 => 64, 7 => 100}  # Modulation + Volume
]}
```

#### 2.2 Program Change

**Features**:
- [ ] Implement `program_change/3`
- [ ] Support in event params
- [ ] Tests for program changes

**Usage**:
```elixir
# Change program (instrument) before note
{0.0, [note: 60, program: 5]}
```

#### 2.3 Note Duration Handling

**Features**:
- [ ] Calculate note-off timing based on duration param
- [ ] Schedule note-off with Process.send_after
- [ ] Handle overlapping notes (same pitch, different timing)
- [ ] Tests for duration accuracy

#### 2.4 Velocity Curves

**Features**:
- [ ] Linear velocity mapping (default)
- [ ] Exponential velocity mapping (more musical)
- [ ] Custom velocity curves via configuration
- [ ] Map `:gain` (0.0-1.0) → velocity (0-127)

---

### Phase 3: Multi-Port & Advanced Routing (Est. 2-3 hours)

#### 3.1 Multi-Port Support

**Features**:
- [ ] Route different patterns to different ports
- [ ] Per-event port specification
- [ ] Port aliases in configuration
- [ ] Tests for multi-port routing

**Configuration**:
```elixir
config :waveform,
  midi_ports: %{
    drums: "IAC Driver Bus 1",
    synth: "USB MIDI Device",
    hardware: "MIDI Out 1"
  }
```

**Usage**:
```elixir
# Route pattern to specific port
PatternScheduler.schedule_pattern(:drums, events,
  output: :midi,
  midi_port: :drums  # Uses port alias from config
)

# Or specify per-event
{0.0, [note: 60, port: :synth]}
```

#### 3.2 MIDI Channel Routing

**Features**:
- [ ] Per-pattern channel assignment
- [ ] Per-event channel override
- [ ] Multi-channel patterns
- [ ] Tests for channel routing

**Usage**:
```elixir
# Pattern on channel 10 (drums)
PatternScheduler.schedule_pattern(:drums, events,
  output: :midi,
  midi_channel: 10
)

# Multi-channel pattern
drums = [
  {0.0, [note: 36, channel: 10]},  # Kick on channel 10
  {0.5, [note: 60, channel: 1]}    # Melody on channel 1
]
```

---

### Phase 4: Testing & Documentation (Est. 2-3 hours)

#### 4.1 Unit Tests

**File**: `test/waveform/midi_test.exs`

**Tests**:
- [ ] Note on/off message formatting
- [ ] Parameter conversion (gain → velocity, etc.)
- [ ] Duration handling
- [ ] Control change messages
- [ ] Program change messages
- [ ] Channel validation (1-16)
- [ ] Port handling

#### 4.2 Integration Tests

**File**: `test/waveform/pattern_scheduler_midi_test.exs`

**Tests**:
- [ ] Pattern scheduling with MIDI output
- [ ] Multi-output (OSC + MIDI simultaneously)
- [ ] Hot-swapping MIDI patterns
- [ ] Timing accuracy
- [ ] Multi-port routing
- [ ] Error handling (port not found, etc.)

#### 4.3 Documentation

**Updates**:
- [ ] Add MIDI section to README.md
- [ ] Document event parameter mapping
- [ ] Add MIDI configuration options
- [ ] Create MIDI usage examples
- [ ] Document port discovery
- [ ] Add troubleshooting section

**Example README Section**:
```markdown
### MIDI Output

Waveform supports MIDI output as an alternative to SuperCollider:

```elixir
alias Waveform.PatternScheduler

# List available MIDI ports
Waveform.MIDI.Port.list_ports()

# Configure MIDI port
config :waveform,
  midi_port: "IAC Driver Bus 1",
  midi_default_channel: 1

# Schedule pattern with MIDI output
melody = [
  {0.0, [note: 60, velocity: 80]},
  {0.25, [note: 64, velocity: 70]},
  {0.5, [note: 67, velocity: 90]}
]

PatternScheduler.schedule_pattern(:melody, melody, output: :midi)

# Send to both SuperCollider and MIDI
PatternScheduler.schedule_pattern(:drums, events, output: [:supercollider, :midi])
```
```

---

## Parameter Mapping Reference

### Note Mapping

| Event Param | MIDI Message | Notes |
|-------------|--------------|-------|
| `:note` or `:n` | Note number (0-127) | Direct mapping |
| `:s` | Note number | If numeric string (e.g., "60") or mapped sample name |

### Velocity Mapping

| Event Param | MIDI Velocity | Conversion |
|-------------|---------------|------------|
| `:velocity` | Direct (0-127) | Clamp to 0-127 |
| `:gain` or `:amp` | Scaled (0.0-1.0 → 0-127) | With velocity curve |

### Other Parameters

| Event Param | MIDI Message | Notes |
|-------------|--------------|-------|
| `:channel` | Channel (1-16) | Default from config |
| `:duration` | Note-off timing | In cycles, converted to ms |
| `:port` | MIDI port selection | Port alias or name |
| `:program` | Program change | 0-127 |
| `:cc` | Control change | Map of CC# → value |

### Control Change Mappings (Optional)

Common CC mappings for convenience:

| Param | CC# | Description |
|-------|-----|-------------|
| `:cutoff` | 74 | Filter cutoff |
| `:resonance` | 71 | Filter resonance |
| `:attack` | 73 | Envelope attack |
| `:release` | 72 | Envelope release |
| `:reverb` | 91 | Reverb send |
| `:delay` | 94 | Delay send |
| `:pan` | 10 | Pan position |

---

## Configuration Options

```elixir
config :waveform,
  # Enable/disable MIDI
  midi_enabled: true,

  # Default MIDI port
  midi_port: "IAC Driver Bus 1",

  # Default MIDI channel (1-16)
  midi_default_channel: 1,

  # Velocity curve (:linear, :exponential, or custom function)
  midi_velocity_curve: :linear,

  # Port aliases for easy routing
  midi_ports: %{
    drums: "IAC Driver Bus 1",
    synth: "USB MIDI Device",
    hardware: "MIDI Out 1"
  },

  # CC mapping (optional convenience)
  midi_cc_mapping: %{
    cutoff: 74,
    resonance: 71,
    reverb: 91
  },

  # Note duration default (fraction of cycle interval)
  midi_default_duration: 0.9
```

---

## Dependencies

**Selected Library**: [Midiex](https://hex.pm/packages/midiex) v0.6.3

Midiex is a Rustler NIF wrapping the [midir](https://github.com/boddlnagg/midir) Rust library (740+ stars, actively maintained).

**Why Midiex over alternatives:**

| Library | Status | Pros | Cons |
|---------|--------|------|------|
| **midiex** ✓ | Active (Sept 2024) | Precompiled binaries, cross-platform, virtual ports | Pre-1.0 API |
| portmidi | Stale (2019) | Well-tested | Requires C compiler, no updates in 5+ years |
| midiclient | Limited | Pure Elixir | macOS only |

**Midiex Features:**
- **Precompiled binaries** - No Rust toolchain required for users
- **Cross-platform** - macOS (ARM/x86), Linux (x86/ARM/RISC-V), Windows
- **Virtual ports** - App can appear as MIDI device (except Windows)
- **Hot-plug support** - Device notifications on macOS
- **Backend drivers** - ALSA, CoreMIDI, WinMM, WinRT, JACK

**Installation:**
```elixir
# mix.exs
{:midiex, "~> 0.6"}
```

**Basic API:**
```elixir
# List ports
Midiex.ports()

# Create virtual output
conn = Midiex.create_virtual_output("Waveform")

# Send MIDI messages (raw bytes)
Midiex.send_msg(conn, <<0x90, 60, 127>>)  # Note On: middle C, velocity 127
Midiex.send_msg(conn, <<0x80, 60, 0>>)    # Note Off: middle C
```

---

## Success Criteria

### Functional Requirements
- ✅ Can send MIDI note on/off messages
- ✅ Timing accuracy within 5ms
- ✅ Support multiple MIDI ports
- ✅ Support all 16 MIDI channels
- ✅ Control change and program change messages
- ✅ Can run MIDI + OSC simultaneously
- ✅ Hot-swappable MIDI patterns

### Code Quality
- ✅ 25+ unit tests
- ✅ 10+ integration tests
- ✅ Comprehensive documentation
- ✅ Example patterns demonstrating features
- ✅ No memory leaks or port resource issues

### Performance
- ✅ <5ms latency for MIDI messages
- ✅ Handle 100+ MIDI messages per second
- ✅ No timing drift over long sessions
- ✅ Efficient port management (reuse connections)

---

## Usage Examples

### Example 1: Basic MIDI Pattern

```elixir
alias Waveform.PatternScheduler

# Simple melody
melody = [
  {0.0, [note: 60, velocity: 80]},
  {0.25, [note: 64, velocity: 70]},
  {0.5, [note: 67, velocity: 90]},
  {0.75, [note: 72, velocity: 85]}
]

PatternScheduler.schedule_pattern(:melody, melody,
  output: :midi,
  midi_port: "IAC Driver Bus 1",
  midi_channel: 1
)
```

### Example 2: Multi-Port Drums

```elixir
# Kick on one port, snare on another
drums = [
  {0.0, [note: 36, port: :kick_out]},
  {0.5, [note: 38, port: :snare_out]}
]

PatternScheduler.schedule_pattern(:drums, drums, output: :midi)
```

### Example 3: MIDI + OSC Simultaneously

```elixir
# Drive both SuperCollider and MIDI synth
pattern = [
  {0.0, [s: "bd"]},
  {0.5, [s: "sn"]}
]

PatternScheduler.schedule_pattern(:hybrid, pattern,
  output: [:supercollider, :midi],
  midi_channel: 10  # MIDI drums channel
)
```

### Example 4: Control Changes

```elixir
# Sweeping filter while playing
synth = [
  {0.0, [note: 60, cc: %{74 => 0}]},    # Low cutoff
  {0.25, [cc: %{74 => 50}]},            # Mid cutoff (no note)
  {0.5, [cc: %{74 => 100}]},            # High cutoff
  {0.75, [cc: %{74 => 0}]}              # Back to low
]

PatternScheduler.schedule_pattern(:sweep, synth, output: :midi)
```

---

## Integration with HarmonyServer

HarmonyServer will use Waveform's MIDI support transparently:

```elixir
# In HarmonyServer
events = HarmonyServer.parse("bd sd hh sd")

HarmonyServer.schedule_pattern(:drums, events,
  bpm: 140,
  audio_engine: :midi,  # Routes to Waveform.MIDI
  midi_port: "IAC Driver"
)
```

HarmonyServer's EventConverter already produces the correct format - no changes needed!

---

## Timeline

| Phase | Description | Est. Time | Dependencies |
|-------|-------------|-----------|--------------|
| 1 | Core MIDI output | 4-5h | Midiex library |
| 2 | Advanced features (CC, program change) | 3-4h | Phase 1 |
| 3 | Multi-port & routing | 2-3h | Phase 1 |
| 4 | Testing & docs | 2-3h | Phases 1-3 |

**Total**: 11-15 hours

---

## Open Questions

1. **Should MIDI timing be quantized?**
   - Option: Add optional quantize grid for cleaner MIDI recording
   - Recommendation: Leave to users, keep raw timing by default

2. **MPE (MIDI Polyphonic Expression) support?**
   - Advanced feature for future
   - Low priority for initial implementation

3. **MIDI clock/sync?**
   - Send MIDI clock messages for external sync
   - Medium priority, useful for hardware sequencers

4. **MIDI input?**
   - Record MIDI into patterns
   - Future extension, out of scope for initial MIDI output

---

## Future Extensions (Post-Initial MIDI Output)

### MIDI Input Support

**Use Case**: Play along with patterns using MIDI keyboard/controller

```elixir
# Listen to MIDI input
Waveform.MIDI.Input.start_listening("USB MIDI Keyboard", fn event ->
  case event do
    {:note_on, note, velocity, channel} ->
      # Trigger SuperDirt sample or synth
      SuperDirt.play(note: note, velocity: velocity)

    {:control_change, cc, value, channel} ->
      # Modulate pattern parameters
      PatternScheduler.set_param(:cutoff, value / 127.0)
  end
end)

# Record MIDI input to pattern
Waveform.MIDI.Input.record(:keyboard, duration: 4.0)
# => Returns pattern events that can be scheduled
```

**Features**:
- Receive MIDI note on/off events
- Receive CC messages for parameter control
- Real-time pattern parameter modulation
- MIDI recording into pattern format
- Multiple simultaneous MIDI inputs
- MIDI learn for parameter mapping

**Benefits**:
- Play along with Uzu/HarmonyServer patterns
- Live performance with keyboard/pads
- Hardware controller integration
- Pattern recording from MIDI instruments

### OSC Input Support

**Use Case**: Bidirectional communication with SuperCollider and other tools

```elixir
# Listen for OSC messages
Waveform.OSC.Input.listen("/pattern/update", fn [pattern_id, bpm] ->
  PatternScheduler.set_cps(bpm / 240.0)
end)

# Receive from other live coding tools
Waveform.OSC.Input.listen("/tidal/event", fn params ->
  # Convert external OSC to pattern event
  SuperDirt.play(params)
end)

# Monitor SuperCollider events
Waveform.OSC.Input.listen("/scsynth/status", fn status ->
  Logger.info("SuperCollider status: #{inspect(status)}")
end)
```

**Features**:
- Receive OSC messages from SuperCollider
- Bidirectional communication with other tools
- Pattern synchronization across tools
- External control of pattern parameters
- Server status monitoring
- Extensible message routing

**Use Cases**:
- Sync with other live coding environments (TidalCycles, Sonic Pi)
- Control from OSC-enabled hardware (TouchOSC, Lemur)
- Integrate with visual tools (Processing, openFrameworks)
- Receive feedback from SuperCollider (node triggers, etc.)
- Cross-application pattern coordination

---

**Status**: Ready for implementation when approved
