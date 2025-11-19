# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Replaced Sonic Pi server info mechanism with standard SuperCollider `/status` command
  - Removed internal `sonic-pi-server-info` synth and `/sonic-pi/server-info` OSC path
  - Now uses standard `/status` and `/status.reply` messages for server capabilities
  - ServerInfo module simplified to use SuperCollider defaults for bus/buffer counts
  - More portable and standard SuperCollider integration

### Removed
- Sonic Pi-specific server information gathering
- Internal node/group allocation for server info queries

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

[0.2.0]: https://github.com/rpmessner/waveform/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rpmessner/waveform/releases/tag/v0.1.0
