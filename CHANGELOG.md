# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **[BREAKING]** Minimum required versions updated for modern Elixir/OTP support
  - Now requires Elixir 1.17+ (previously 1.12+)
  - Now requires OTP 27+ (previously OTP 24+)
  - Ensures compatibility with latest language features and tooling

- **[BREAKING]** Migrated from `exexec` to `erlexec` v2.2.2
  - Replaced unmaintained exexec wrapper with direct erlexec usage
  - All functionality remains the same; only internal implementation changed
  - `erlexec` is now a direct dependency in mix.exs

### Added

- `Lang.wait_for_superdirt/1` - Event-driven waiting for SuperDirt initialization
  - Monitors SuperCollider stdout for SuperDirt's ready message
  - Configurable timeout (default: 60 seconds)
  - Immediate return if SuperDirt already running
- Server parameter support in all GenServer/Agent modules for dependency injection
  - Enables isolated testing with `start_supervised!/2`
  - All modules maintain backward compatibility (defaults to module name)

### Fixed

- SuperDirt initialization now properly waits for readiness instead of fixed 15-second sleep
  - Monitors stdout for `"SuperDirt: listening to Tidal on port"` message
  - Faster startup when samples load quickly
  - Prevents premature return if loading takes longer than expected

### Improved

- **Demo Files** - Updated all demos to use event-driven SuperDirt initialization
  - Replaced `Process.sleep` calls with `Helpers.ensure_superdirt_ready/0`
  - Reduced initialization boilerplate from 36 lines to 3 lines per demo
  - Eliminates ~11 seconds of arbitrary waits per demo startup
  - More responsive: returns immediately when SuperDirt is ready
  - Removed song name references for generic demo titles

- **Test Infrastructure** - Refactored all tests to use idiomatic ExUnit patterns
  - All test modules now use `start_supervised!/2` for proper isolation
  - Tests run in parallel with `async: true` for 40% faster execution
  - Eliminated test ordering dependencies and race conditions
  - 100% test pass rate across all random seeds
  - Reduced test code by 56 lines while improving reliability

## [0.3.0] - 2025-11-21

Previous release version.
