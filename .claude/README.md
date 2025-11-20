# Claude Code Instructions for Waveform Project

## 🎯 Start Here When Beginning a New Session

When you start working on this project, **always check these resources first**:

### 1. Session Documentation (MOST IMPORTANT)
**Location:** `docs/sessions/`

- **Read the latest session**: Check the most recent file in `docs/sessions/` for context on what was recently accomplished
- **Session index**: See `docs/sessions/README.md` for a chronological list
- **What you'll find**: Technical decisions, code coverage metrics, bug fixes, areas for future work, and architectural context

### 2. Project Status

```bash
# Check current test status
mix test

# Check code coverage (21.6% as of 2025-01-19)
MIX_ENV=test mix coveralls

# View recent commits
git log --oneline -10

# Check what's changed
git status
```

### 3. Project Documentation

- **CHANGELOG.md**: High-level project history and user-facing changes
- **README.md**: Project overview, features, and getting started guide
- **docs/sessions/**: Detailed development session context (check here first!)

## 🔑 Key Project Information

### Architecture Overview

Waveform is an OSC transport layer for SuperCollider:

- **OSC**: UDP transport for communicating with SuperCollider
- **Lang**: Manages the sclang process (SuperCollider interpreter)
- **Node**: Allocates and tracks synth nodes
- **Group**: Manages group hierarchy
- **Synth**: High-level API for triggering synths
- **ServerInfo**: Stores server metadata (sample rate) using :persistent_term

### Important Design Patterns

1. **Dependency Injection via Behaviours**: Tests use NoOp transport (see `config/test.exs`)
2. **Agent vs GenServer**: Use Agent for simple state (Node.ID), GenServer for complex behavior (Node, Group, OSC)
3. **Singleton Processes**: Node.ID and Group are singletons - handle carefully in tests
4. **Process Monitoring**: Group monitors process groups for automatic cleanup

### Test Coverage Goals

Current: **21.6%** overall
- Node.ID: 100%
- ServerInfo: 100%
- Synth: 94.1%
- Node: 83.3%
- Group: 62.8%

**Goal:** Increase to 30%+ by adding more OSC and Group tests

### Files That Should NOT Be Modified

- `src/osc.erl`: Erlang OSC encoder/decoder (external dependency)
- Tests use NoOp transport - no actual network I/O

### Common Tasks

```bash
# Run tests
mix test

# Run tests with coverage
MIX_ENV=test mix coveralls

# Detailed coverage report
MIX_ENV=test mix coveralls.detail

# HTML coverage report
MIX_ENV=test mix coveralls.html

# Check if SuperCollider is installed
mix waveform.doctor

# Format code
mix format

# Run static analysis
mix credo
```

## 📝 When You Complete Work

If you complete significant work in a session:

1. **Update session documentation**: Create a new file in `docs/sessions/YYYY-MM-DD-description.md`
2. **Update the session index**: Add your session to `docs/sessions/README.md`
3. **Update CHANGELOG.md**: If there are user-facing changes
4. **Run tests**: Ensure `mix test` passes
5. **Check coverage**: Run `MIX_ENV=test mix coveralls`

## 🐛 Known Issues and Gotchas

1. **Test mode doesn't start the application**: Tests manually start required processes
2. **Singleton conflicts**: Be careful when tests share singleton processes (Node.ID, Group)
3. **Group requires setup**: Call `Group.setup()` to create root synth group before triggering synths
4. **Node.ID is now an Agent**: Changed from GenServer in recent refactoring
5. **ServerInfo uses :persistent_term**: No longer a GenServer

## 🎨 Code Style

- Use dependency injection for testability
- Prefer Edit over Write for existing files
- Keep tests isolated with unique process names
- Use `async: true` for tests when possible
- Suppress expected warnings with `ExUnit.CaptureLog`

## 🔗 Related Projects

- **KinoSpaetzle**: TidalCycles-like live coding for Livebook (primary use case)
- **Harmony**: Optional music theory library for note names

## 💡 Philosophy

Waveform is intentionally **minimal and focused**:
- Low-level OSC transport layer
- No built-in synths (users bring their own or use SuperDirt)
- Pattern-based live coding happens in KinoSpaetzle
- Suitable for Livebook and terminal-based live coding

## 📚 Quick Reference

**Most important files:**
- `docs/sessions/` - Development context (READ THIS FIRST!)
- `CHANGELOG.md` - User-facing changes
- `lib/waveform/synth.ex` - High-level API
- `lib/waveform/osc.ex` - Core OSC transport
- `test/` - Test suite with examples

**Configuration:**
- `config/test.exs` - Test mode uses NoOp transport
- `mix.exs` - Dependencies and coverage settings

---

**Remember:** Always start by reading the latest session documentation in `docs/sessions/`!
