# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-11-20

### Added
- **Pattern Scheduler** - High-precision continuous pattern playback
  - Cycle-based timing model (like TidalCycles)
  - Look-ahead scheduling with 10ms tick interval
  - Pattern hot-swapping without stopping playback
  - Multiple concurrent patterns
  - `PatternScheduler.schedule_pattern/2` - Start a looping pattern
  - `PatternScheduler.update_pattern/2` - Change pattern while playing
  - `PatternScheduler.stop_pattern/1` - Stop a specific pattern
  - `PatternScheduler.set_cps/1` - Adjust tempo (cycles per second)
  - `PatternScheduler.hush/0` - Emergency stop all patterns
  - MapSet-based deduplication prevents event double-triggering
  - No drift over time using monotonic clock and cycle arithmetic
- **SuperDirt OSC Bundle Support** - Messages now sent with timestamps for precise scheduling
  - All `/dirt/play` messages wrapped in OSC bundles with timestamps
  - Configurable latency (default 20ms) for scheduling stability
  - New `SuperDirt.set_latency/1` to adjust scheduling latency
  - New `SuperDirt.get_latency/0` to query current latency
  - Enables look-ahead scheduling for pattern engines
  - Foundation for precise pattern timing in KinoSpaetzle

### Changed
- Replaced Sonic Pi server info mechanism with standard SuperCollider `/status` command
  - Removed internal `sonic-pi-server-info` synth and `/sonic-pi/server-info` OSC path
  - Now uses standard `/status` and `/status.reply` messages for server capabilities
  - ServerInfo module simplified to use SuperCollider defaults for bus/buffer counts
  - More portable and standard SuperCollider integration
- **BREAKING**: Renamed `OSC.load_synthdefs/0` to `OSC.load_synthdef_dir/1`
  - Now requires explicit path argument
  - No longer auto-loads built-in synthdefs on startup
  - Users must define or load their own synth definitions
- **BREAKING**: Simplified `OSC.Group` API - removed stack-based group management
  - Changed from per-process group stacks to single group per process
  - Removed `activate_synth_group/2` and `restore_synth_group/1` functions
  - Added simpler `set_process_group/2` and `get_process_group/1` functions
  - `synth_group/1` remains as backwards-compatible alias
  - Still monitors processes and automatically cleans up on process death
  - Reduces complexity while maintaining essential functionality
- Added platform-specific sclang path detection
  - `Lang` module now detects macOS, Linux, and Windows installations
  - Same platform detection as `mix waveform.doctor` task
  - Falls back to sensible defaults for each platform

### Removed
- Sonic Pi-specific server information gathering
- Internal node/group allocation for server info queries
- All built-in Sonic Pi synth definitions (~90 .scsyndef files)
  - Users should define synths in SuperCollider directly
  - Or use SuperDirt for TidalCycles-style live coding
  - Or load custom synthdefs from their own directory
- `OSC.save_synthdef/2` function (use standard file operations instead)
- `OSC.load_user_synthdefs/0` function (use `load_synthdef_dir/1` instead)
- `Waveform.AudioBus` module - automatic bus allocation removed
  - Not needed for basic synth triggering
  - Users can manage bus numbers directly in synth parameters if needed
  - Simplifies supervision tree (6 processes instead of 7)

## [0.2.0] - 2025-11-19

### Fixed
- **CRITICAL**: Fixed unlinked spawn in OSC UDP receiver - now uses supervised Task
- **MEMORY LEAK**: Fixed unbounded list growth in Node tracking - now uses maps with periodic pruning
- **MEMORY LEAK**: Fixed per-process group tracking leak - added process monitors to clean up dead processes
- Fixed hardcoded magic node IDs that could conflict with user nodes - now uses high IDs (1M+) for system nodes
- Added comprehensive error handling to UDP receive loop with graceful degradation
- Moved synchronous calls out of OSC init to prevent startup deadlocks

### Changed
- **BREAKING**: Removed macro-based synth definition system (`Waveform.Synth.Def`)
  - The complex DSL for defining synths has been removed
  - Users should define synths directly in SuperCollider instead
  - This simplifies the library to focus on OSC transport
- **BREAKING**: Removed `Waveform.Beat` and `Waveform.Track` modules
  - High-level sequencing features removed
  - Library now focuses on low-level OSC messaging
  - Users can build their own sequencing on top of the OSC API
- **BREAKING**: Removed `Waveform.Synth.Manager` and `Waveform.Synth.FX`
  - SonicPi-specific synth name mappings removed
  - Effects routing removed
  - Library is now synth-engine agnostic
- **BREAKING**: Simplified `Waveform.Synth` API
  - New `trigger/3` function for straightforward synth triggering
  - Simplified `play/2` function for note-based synthesis
  - Removed chord and progression helpers (use Harmony library directly if needed)
- Made `Harmony` dependency optional
  - Note name support is now opt-in
  - MIDI numbers work without any dependencies

### Added
- Comprehensive documentation for all public modules
- Package metadata for Hex publishing
- MIT License
- This changelog

### Removed
- SmartCell integration (will be handled by dedicated packages like KinoSpaetzle)
- 20+ UGen definition modules
- SonicPi synth definitions
- Beat/Track sequencing macros
- Utility modules no longer needed

## [0.1.0] - 2024-01-30

### Changed
- Moved music theory code to separate `harmony` library
- Updated README for Livebook usage
- Switched from Porcelain to ExExec for process management

### Added
- Initial SuperCollider OSC communication
- Node and group management
- Audio bus allocation
- Basic synth triggering API
- Macro-based synth definitions (later removed in 0.2.0)

[0.3.0]: https://github.com/rpmessner/waveform/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/rpmessner/waveform/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rpmessner/waveform/releases/tag/v0.1.0
