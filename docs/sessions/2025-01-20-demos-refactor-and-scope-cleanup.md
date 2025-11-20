# Session: 2025-01-20 - Demos Refactor and Scope Cleanup

## Overview

This session focused on improving the demo files and clarifying Waveform's scope as a pure OSC transport layer. Key changes include fixing sample dependencies, renaming demos to be more descriptive, and removing music theory features that belong in higher-level integrations.

## Changes Made

### 1. Fixed Sample Dependencies

**Problem:** Demos used `superpiano` which requires the optional sc3-plugins extension, not available by default.

**Solution:**
- Replaced all `superpiano` usage with `arpy` (tuned instruments from standard Dirt-Samples)
- Updated `test_superpiano.exs` to document sc3-plugins requirement
- Added sc3-plugins installation instructions to README

**Files changed:**
- `demos/superstition.exs` → `demos/03_syncopated_rhythm.exs`
- `demos/creep_simple.exs` → `demos/01_basic_patterns.exs`
- `demos/creep_modular.exs` → `demos/02_modular_composition.exs`
- `demos/giant_steps.exs` → `demos/04_complex_harmony.exs`
- `README.md` (added sc3-plugins section)
- `test_superpiano.exs` (documentation updates)

### 2. Converted Script to Mix Task

**Problem:** `check_superdirt.exs` was a utility script in the demos folder, but demos should be examples of using Waveform.

**Solution:**
- Created `lib/mix/tasks/waveform.check.ex` - proper Mix task
- Deleted `demos/check_superdirt.exs`
- Updated all references to use `mix waveform.check`

**Files changed:**
- `lib/mix/tasks/waveform.check.ex` (new)
- `demos/check_superdirt.exs` (deleted)
- `README.md`
- `lib/mix/tasks/waveform.install_samples.ex`

### 3. Renamed Demos by Complexity

**Problem:** Demo file names referenced songs they didn't actually sound like (Creep, Giant Steps, Superstition), causing confusion about what they demonstrate.

**Solution:** Renamed demos to descriptive, complexity-ordered names:
- `creep_simple.exs` → `01_basic_patterns.exs` (easiest)
- `creep_modular.exs` → `02_modular_composition.exs`
- `superstition.exs` → `03_syncopated_rhythm.exs`
- `giant_steps.exs` → `04_complex_harmony.exs` (most advanced)

**Rationale:**
- Demos showcase pattern scheduler features, not song recreations
- Numbered ordering shows clear learning progression
- Names describe what's being taught (patterns, composition, rhythm, harmony)

**Files changed:**
- All demo files renamed and headers updated
- Module names updated (`CreepDemo` → `ModularCompositionDemo`, etc.)
- `demos/README.md` completely rewritten
- `.iex.exs` quick reference updated
- All mix task output messages updated

### 4. Improved Complex Harmony Demo

**Problem:**
- Chord changes at 240 BPM were too fast to hear
- 22 chord changes in 4 cycles was overwhelming
- Bass sample was too percussive to articulate pitches
- Melody didn't relate to chord changes

**Solution:**
- Slowed default tempo to 120 BPM (kept 240 BPM as `play_fast()` challenge mode)
- Reduced to 10 chord changes with slower harmonic rhythm (0.25-0.5 cycles per chord)
- Switched bass from "bass" sample to "arpy" (melodic, clear pitch articulation)
- Rewrote melody to arpegiate each chord (24 notes outlining harmony)
- Created clearer harmonic progression: C → E → Ab → C (symmetrical), then D → C, F → C → G → C

**Files changed:**
- `demos/04_complex_harmony.exs`

### 5. Updated .iex.exs with Helpful Tools

**Problem:** `.iex.exs` had stale module references and wasn't particularly helpful for interactive use.

**Solution:** Complete rewrite with:
- Current Waveform module aliases
- `IExHelpers` module with:
  - `start()` - Initialize SuperDirt with welcome
  - `help()` - Quick reference guide
  - `samples()` - List common Dirt-Samples
  - `quick_beat()` - Instant demo pattern
- Welcome message on IEx startup

**Files changed:**
- `.iex.exs`

### 6. Removed Harmony Integration

**Problem:** Waveform is meant to be a lightweight OSC transport layer, but had optional integration with the Harmony music theory library for note name support (`Synth.play("c4")`).

**Rationale for removal:**
- Music theory features (note names, scales, chords) are higher-level concerns
- Belong in integration layers like KinoSpaetzle, not the transport layer
- Keeps Waveform focused on its core mission
- Users can add Harmony directly if needed

**Solution:**
- Removed Harmony dependency from `mix.exs`
- Simplified `Synth.play/2` to only accept MIDI numbers
- Removed conditional Harmony support code
- Removed Harmony tests
- Updated README (removed "Using Note Names" section)
- Removed Harmony aliases from `.iex.exs`
- Kept Harmony in "Related Projects" as reference

**Files changed:**
- `mix.exs`
- `lib/waveform/synth.ex`
- `test/waveform/synth_test.exs`
- `README.md`
- `.iex.exs`

## Impact

### User Experience
- Demos now work with just Dirt-Samples (no sc3-plugins needed)
- Clear learning progression from simple to complex
- Better demo names set accurate expectations
- `mix waveform.check` is more discoverable than running a script
- `.iex.exs` provides helpful interactive tools

### Code Quality
- Cleaner scope - Waveform is purely a transport layer
- More idiomatic (Mix task vs script)
- Better organized demos
- Removed optional dependency complexity

### Documentation
- More accurate (demos describe what they teach, not songs they reference)
- Clearer installation requirements
- Better quick reference in IEx

## Testing

- All tests pass after changes
- `mix waveform.check` task works correctly
- Demos renamed successfully with no broken references
- Synth tests pass without Harmony dependency

## Future Considerations

- Consider adding more progressive demos showing pattern hot-swapping
- KinoSpaetzle will integrate Harmony for music theory features
- May want to add Livebook notebooks as complementary to .exs demos

## Files Modified

```
Modified:
  .iex.exs
  README.md
  demos/README.md
  lib/mix/tasks/waveform.install.ex
  lib/mix/tasks/waveform.install_samples.ex
  lib/waveform/synth.ex
  mix.exs
  test/waveform/synth_test.exs

Added:
  demos/01_basic_patterns.exs
  demos/02_modular_composition.exs
  demos/03_syncopated_rhythm.exs
  demos/04_complex_harmony.exs
  lib/mix/tasks/waveform.check.ex

Deleted:
  demos/check_superdirt.exs
  demos/creep_modular.exs
  demos/creep_simple.exs
  demos/giant_steps.exs
  demos/superstition.exs
```

## Related Sessions

- [2025-11-20-dirt-samples-buffer-fix.md](2025-11-20-dirt-samples-buffer-fix.md) - When demos were first created
- [2025-01-19-pattern-scheduler-and-superdirt-verification.md](2025-01-19-pattern-scheduler-and-superdirt-verification.md) - Pattern scheduler implementation
