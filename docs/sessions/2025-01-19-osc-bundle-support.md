# Session: OSC Bundle Support Implementation

**Date:** January 19, 2025 (continuation)
**Duration:** ~1 hour
**Branch:** master

## Overview

This session implemented OSC bundle support with timestamps for the SuperDirt module, replacing the TODO that sent regular OSC messages. This enables precise timing and look-ahead scheduling for pattern-based audio.

## What Was Accomplished

### 1. OSC Bundle Implementation

Updated `lib/waveform/super_dirt/udp.ex` to use OSC bundles with timestamps:

**Before:**
```elixir
# Sent regular OSC messages
encoded = :osc.encode(message)
:ok = :gen_udp.send(state.socket, state.host, state.port, encoded)
```

**After:**
```elixir
# Creates OSC bundles with timestamps and latency
latency = Map.get(state, :latency, 0.02)
time = :osc.now() + latency
encoded = :osc.pack_ts(time, message)
:ok = :gen_udp.send(state.socket, state.host, state.port, encoded)
```

### 2. Configurable Latency

Added latency management to `Waveform.SuperDirt`:

- **State field:** Added `latency: 0.02` (20ms default) to State struct
- **Init option:** Can configure latency on startup: `SuperDirt.start_link(latency: 0.05)`
- **New functions:**
  - `set_latency/1` - Update latency dynamically
  - `get_latency/0` - Get current latency value

### 3. Documentation Updates

Updated module documentation to explain:
- OSC bundles are now used for all `/dirt/play` messages
- Default 20ms latency for scheduling stability
- How latency affects timing
- When to adjust latency (responsive vs stable)

### 4. Comprehensive Tests

Added 13 new tests in two test modules:

**`test/waveform/super_dirt_test.exs`** (6 new tests):
- Default latency verification
- `get_latency/0` functionality
- `set_latency/1` with various values (float, int, zero)
- Latency persistence across play calls

**`test/waveform/super_dirt/udp_test.exs`** (new file, 7 tests):
- Bundle creation with correct latency
- OSC message sending without bundles
- Bundle format verification (#bundle header)
- Bundle timestamp verification
- Bundle encode/decode round-trip

## Test Results

**All tests passing:** 72/72 tests ✅

**Coverage improvements:**
- `super_dirt/udp.ex`: 0% → 100% (6/6 lines)
- `super_dirt.ex`: 96.7% → 97.2% (36/36 lines, 1 missed)
- Overall project: 44.3%

## Technical Details

### OSC Library Usage

Discovered and utilized the vendored OSC library (`src/osc.erl`) from Sonic Pi:

**Key functions:**
- `:osc.now()` - Get current time as float (seconds since epoch)
- `:osc.pack_ts(time, message)` - Create OSC bundle with timestamp
- `:osc.encode_time(time)` - Convert to NTP timestamp format
- `:osc.decode(bundle)` - Decode for testing/verification

**Bundle format:**
```
"#bundle\0"    (8 bytes - header)
<timestamp>     (8 bytes - NTP time)
<size>          (4 bytes - message size)
<message>       (variable - encoded OSC message)
```

### Latency Strategy

**Default 20ms latency** chosen because:
- Gives SuperDirt time to process events before playback
- Small enough for responsive live coding
- Large enough to prevent jitter/dropouts
- Standard for audio applications

**Adjustable for different use cases:**
- 10ms - More responsive, risk of jitter
- 20ms - Balanced (default)
- 50ms+ - Very stable, higher perceived latency

### Design Decisions

1. **Latency in state, not hardcoded** - Allows runtime adjustment
2. **Latency in init options** - Can configure per-instance if needed
3. **Map.get with default** - Backward compatible with old state
4. **Public get/set functions** - Clean API for pattern engines

## Files Changed

**Modified:**
- `lib/waveform/super_dirt.ex` - Added latency field, get/set functions, docs
- `lib/waveform/super_dirt/udp.ex` - Implemented bundle support

**Added:**
- `test/waveform/super_dirt/udp_test.exs` - Bundle format verification tests

**Updated:**
- `test/waveform/super_dirt_test.exs` - Latency management tests

## API Changes

### New Public Functions

```elixir
# Set scheduling latency (seconds)
SuperDirt.set_latency(0.05)

# Get current latency
SuperDirt.get_latency()
# => 0.02
```

### New Init Options

```elixir
# Start with custom latency
{Waveform.SuperDirt, [latency: 0.05]}
```

### Behavior Changes

**Breaking:** None - backward compatible

**Enhancement:** All `SuperDirt.play/1` calls now use OSC bundles with timestamps instead of immediate messages.

## Impact on KinoSpaetzle

This implementation provides the foundation for precise pattern scheduling:

### What KinoSpaetzle Can Now Do

1. **Look-ahead scheduling** - Schedule events in advance
2. **Precise timing** - OSC bundles ensure accurate playback
3. **Latency control** - Adjust for different performance needs
4. **Stable patterns** - Events scheduled ahead of time

### Next Steps for Pattern Engine

With bundle support complete, the next priority is implementing a pattern scheduler that:

1. **Schedules events ahead** - Uses the latency window to queue events
2. **Cycle-based timing** - Converts pattern cycles to timestamps
3. **Hot-swappable patterns** - Updates schedule without stopping
4. **Multiple patterns** - Manages concurrent pattern streams

See roadmap in project notes for detailed scheduler design.

## Verification

To verify bundle support is working:

```elixir
# Start Waveform (ensure SuperDirt is loaded in SuperCollider)
Application.ensure_all_started(:waveform)
Waveform.Lang.send_command("SuperDirt.start;")

# Play with default latency (20ms in future)
Waveform.SuperDirt.play(s: "bd")

# Adjust latency for testing
Waveform.SuperDirt.set_latency(0.1)  # 100ms
Waveform.SuperDirt.play(s: "cp")

# Check current setting
Waveform.SuperDirt.get_latency()
# => 0.1
```

## Future Enhancements

1. **Scheduled play function** - `play_at(params, timestamp)` for explicit timing
2. **Relative scheduling** - `play_in(params, seconds)` for delta timing
3. **Pattern scheduler** - High-level loop/pattern management (roadmap item #3)
4. **Bundle batching** - Send multiple events in one bundle for efficiency

## Related Documentation

- Previous session: `docs/sessions/2025-01-19-superdirt-integration.md`
- OSC spec: http://opensoundcontrol.org/spec-1_0
- SuperDirt API: https://github.com/musikinformatik/SuperDirt

## Notes for Future Sessions

**When working with scheduling:**

1. **Latency is scheduling window** - Events must be scheduled within `latency` seconds
2. **Timestamps are absolute** - Use `:osc.now() + offset` for timing
3. **Bundle overhead** - ~20 bytes per bundle (negligible)
4. **State management** - Latency persists across calls, reset if needed

**Testing bundles:**

- Use `udp_test.exs` pattern for format verification
- `:osc.decode/1` for inspecting bundle contents
- Timestamp tolerance when comparing (±1 second is safe)

## Conclusion

OSC bundle support is now fully implemented and tested. SuperDirt messages are scheduled with configurable latency for precise timing. This completes roadmap item #2 and provides the foundation for pattern scheduling (roadmap item #3).

**Status:** ✅ Complete - All tests passing, 100% coverage on new code
