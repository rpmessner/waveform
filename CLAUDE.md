# CLAUDE.md - Waveform (Elixir SuperCollider Client)

## Project Overview

**waveform** is an Elixir library for communicating with SuperCollider via OSC. It provides low-level audio synthesis control, sample playback, and pattern scheduling for desktop-based live coding.

**Purpose:** SuperCollider OSC transport layer - the Elixir equivalent of waveform_js (which is for Web Audio).

**Version:** 0.3.0

**Note:** This is NOT the same as waveform_js. waveform_js is for browsers (Web Audio), waveform is for desktop (SuperCollider).

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Your Application                              │
│           Livebook / Phoenix / CLI / etc.                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      waveform ◀── HERE                          │
│  • OSC messaging to SuperCollider                               │
│  • SuperDirt-compatible events                                  │
│  • Pattern scheduling with hot-swap                             │
│  • MIDI output via midiex                                       │
└────────────────────────────┬────────────────────────────────────┘
                             │ OSC
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SuperCollider                               │
│  • Audio synthesis                                               │
│  • SuperDirt quark for sample playback                          │
└─────────────────────────────────────────────────────────────────┘
```

## Key Modules

| Module | Purpose |
|--------|---------|
| `Waveform.OSC` | Low-level OSC messaging |
| `Waveform.Lang` | Execute SuperCollider code |
| `Waveform.SuperDirt` | SuperDirt-compatible API |
| `Waveform.PatternScheduler` | Cycle-based pattern scheduling |
| `Waveform.Buffer` | Sample buffer management |
| `Waveform.MIDI` | MIDI output via midiex |
| `Waveform.Synth` | Synth node management |

## Quick Reference

```elixir
# Start SuperCollider + SuperDirt
Waveform.SuperDirt.start()

# Play a sound
Waveform.SuperDirt.play(%{s: "bd", gain: 0.8})

# Pattern scheduling
Waveform.PatternScheduler.schedule_pattern("drums", events)
Waveform.PatternScheduler.set_cps(0.5)
Waveform.PatternScheduler.start()

# Stop everything
Waveform.PatternScheduler.hush()
```

## Commands

```bash
mix test              # Run tests (requires SuperCollider)
mix test --exclude integration  # Unit tests only
mix compile           # Compile
```

## Dependencies

- `erlexec` - OS process management (for sclang)
- `recase` - String case conversion
- `midiex` - MIDI output

## Requirements

- SuperCollider installed on system
- SuperDirt quark installed (for sample playback)

## Integration

waveform can be used with:
- **uzu_parser** - Pattern mini-notation parsing
- **uzu_pattern** - Pattern transformations (fast, slow, rev, etc.)

## Related Projects

- **uzu_parser** - Pattern mini-notation parser
- **uzu_pattern** - Pattern transformation library
- **harmony** - Music theory library (scales, chords)
