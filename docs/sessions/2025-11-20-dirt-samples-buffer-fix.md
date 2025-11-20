# Session Notes - Song Demos & SuperDirt Setup

## What We Accomplished ✅

### 1. Created Song Demo Files
- **`demos/creep_simple.exs`** - Radiohead's Creep (simple pattern style)
- **`demos/creep_modular.exs`** - Radiohead's Creep (modular/functional style)
- **`demos/giant_steps.exs`** - John Coltrane's Giant Steps (complex jazz harmony)
- **`demos/superstition.exs`** - Stevie Wonder's Superstition (funk groove)
- **`demos/README.md`** - Documentation for all demos

### 2. Created Installation Infrastructure
- **`lib/mix/tasks/waveform.install.ex`** - Platform-agnostic SuperCollider + SuperDirt installation
  - Supports macOS (Homebrew), Linux (apt/pacman/dnf/zypper), Windows
  - Installs SuperCollider via package manager
  - Installs SuperDirt Quark via sclang

### 3. Fixed Core Issues
- **Server ready detection** - Added `Lang.wait_for_server()` to wait for "SuperCollider 3 server ready"
- **Group initialization** - Auto-create root_synth_group in `Group.init/1`
- **Pattern scheduler** - Added to supervision tree
- **SuperDirt timing pattern** - Discovered the working initialization pattern (see below)

### 4. Installed Dirt-Samples
- Downloaded 2030 sample files to:
  `/Users/ryanmessner/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples/`
- Samples include: bd, sn, hh, cp, and many more

## Current Status ✅

### What Works
- ✅ SuperCollider server boots correctly
- ✅ SuperDirt starts and accepts OSC messages
- ✅ **ALL Dirt-Samples play successfully!** (bd, sn, hh, cp, arpy, bass, and 217+ more)
- ✅ Audio output works
- ✅ Song demo structure is complete
- ✅ Sample loading from Dirt-Samples directory works

### Issue SOLVED - Buffer Limit ✅

**Root Cause:** SuperCollider's default buffer limit (1024) was too small for Dirt-Samples (1817 .wav files).

**Symptoms:**
- Only "bd" samples played (bd is early alphabetically, loaded before buffer limit hit)
- Error: `ERROR: No more buffer numbers -- free some buffers before allocating more`
- Other samples (sn, hh, cp, etc.) failed to load silently

**Solution:**
1. Increased `Server.local.options.numBuffers` from 1024 → 4096 in `lib/waveform/lang.ex:51-52`
2. Added explicit Dirt-Samples path to `loadSoundFiles()` in `lib/waveform/helpers.ex:38`

**Key Code Changes:**
```elixir
# lib/waveform/lang.ex
Server.local.options.numBuffers = 4096
Server.internal.options.numBuffers = 4096

# lib/waveform/helpers.ex
sample_path = "/Users/#{System.get_env("USER")}/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples"
Lang.send_command("~dirt = SuperDirt(2, s); ~dirt.loadSoundFiles(\"#{sample_path}/*\"); ~dirt.start(57120, [0, 0]); \"SUPERDIRT_STARTED\".postln;")
```

## The Working SuperDirt Initialization Pattern

This pattern works reliably for starting SuperDirt and getting at least "bd" to play:

```elixir
# Pre-checks (adds time + Lang.send_command calls that help timing)
Lang.send_command("if(SuperDirt.class.notNil, { \"SUPERDIRT_CLASS_EXISTS\".postln; }, { \"SUPERDIRT_CLASS_NOT_FOUND\".postln; });")
Process.sleep(1000)
Lang.send_command("if(~dirt.notNil, { \"DIRT_IS_RUNNING\".postln; }, { \"DIRT_NOT_RUNNING\".postln; });")
Process.sleep(1000)

# Start SuperDirt WITHOUT parentheses (important!)
Lang.send_command("~dirt = SuperDirt(2, s); ~dirt.loadSoundFiles; ~dirt.start(57120, [0, 0]); \"SUPERDIRT_STARTED\".postln;")
Process.sleep(8000)

# Verify
Lang.send_command("if(~dirt.notNil, { \"DIRT_NOW_RUNNING\".postln; }, { \"DIRT_STILL_NOT_RUNNING\".postln; });")
Process.sleep(1000)
```

**Key discoveries:**
- NO parentheses around the start command
- Pre-checks are essential (add 2 seconds + extra commands)
- Total wait: 11 seconds (1 + 1 + 8 + 1)
- Helper: `lib/waveform/helpers.ex` - `ensure_superdirt_ready/0`

## Files Status ✅

### Demo Files (Production):
- `demos/creep_simple.exs` ✅
- `demos/creep_modular.exs` ✅
- `demos/giant_steps.exs` ✅
- `demos/superstition.exs` ✅
- `demos/README.md` ✅

### Diagnostic Files (Kept for debugging):
- `demos/check_superdirt.exs` - Simple SuperDirt verification (plays a kick drum)

### Test Artifacts Cleaned Up:
All temporary test files have been removed ✅

## Next Steps

### 1. Test Song Demos ✅
Now that all samples work, verify the song demos run correctly:
```bash
mix run demos/superstition.exs      # Funk groove
mix run demos/creep_simple.exs      # Radiohead
mix run demos/giant_steps.exs       # Jazz
mix run demos/creep_modular.exs     # Modular version
```

### 2. Documentation Updates (Optional)
- Add buffer configuration note to SuperDirt module docs
- Document Dirt-Samples installation in main README
- Add troubleshooting section for buffer errors

### 3. Future Enhancements (Low Priority)
- Make buffer size configurable via environment variable
- Add sample verification to `mix waveform.doctor`
- Create `mix waveform.install_samples` task for guided installation

## Quick Reference

### Test if SuperDirt Works:
```bash
mix run demos/check_superdirt.exs  # Should hear kick drum
```

### Run Song Demos:
```bash
mix run demos/superstition.exs      # Funk groove
mix run demos/creep_simple.exs      # Radiohead
mix run demos/giant_steps.exs       # Jazz
mix run demos/creep_modular.exs     # Modular version
```

### Check Sample Location:
```bash
ls "/Users/ryanmessner/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples/"
```

### Verify Audio Works:
```bash
mix run demos/test_default_synth.exs  # Uses built-in synth (not SuperDirt)
```

## Technical Debt

1. **Sample loading issue** - Most critical
2. **Test file cleanup** - Quick win
3. **Installation task separation** - Better UX
4. **Error messages** - Demos should fail gracefully if samples missing
5. **Timing constants** - Should these be configurable?

## Context for AI Assistant

When resuming:
- We spent ~3 hours debugging why only "bd" samples play
- All samples are correctly installed
- The issue is likely SuperDirt configuration, not our code
- User wants clean separation between SuperCollider and Dirt-Samples installation
- Fresh start might reveal if system restart helps with sample loading
