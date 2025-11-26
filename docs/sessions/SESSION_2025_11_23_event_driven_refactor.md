# Development Session - November 23, 2025: Event-Driven Refactor

## Summary

This session focused on eliminating polling with `Process.sleep` and replacing version-dependent string matching with custom marker constants. The main achievements were:

1. **Process.sleep Audit** - Comprehensive review of all sleep calls in the codebase
2. **Event-Driven Quarks Installation** - Replaced 2-second polling loop with event monitoring
3. **Marker Constants** - Introduced version-independent detection strings for all SC events
4. **Error Handling** - Added proper failure detection for Quarks installation
5. **Code Review** - Conducted peer review of `start_superdirt/1` function refactor

## Context from Previous Sessions

On November 22-23, 2025, we had already implemented:
- Event-driven SuperDirt readiness detection via `Lang.wait_for_superdirt/1`
- Replaced fixed 15-second sleeps with responsive event monitoring
- Created `Helpers.ensure_superdirt_ready/1` for high-level convenience

However, several issues remained:
- Version-dependent string matching ("SuperCollider 3 server ready", "SuperDirt: listening to Tidal on port")
- 2-second polling loop for Quarks installation (up to 10 minutes of polling)
- String duplication across modules
- Dead `verify()` function with stale documentation references

## Changes Made

### 1. Process.sleep Audit

Identified all `Process.sleep` calls and categorized them:

| Location | Status | Reason |
|----------|--------|--------|
| `lib/waveform/osc.ex:236` | ✅ Keep | Error recovery backoff (prevents tight CPU loops) |
| `lib/mix/tasks/waveform.install_samples.ex:219` | ✅ **REMOVED** | Replaced with event-driven monitoring |
| `lib/mix/tasks/waveform.check.ex:48` | ✅ **REMOVED** | Redundant (handled by `ensure_superdirt_ready`) |
| `lib/mix/tasks/waveform.check.ex:91` | ✅ Keep | Sample playback timing (UX) |
| `test/**/*.exs` (6 instances) | ✅ Keep | Test synchronization (acceptable pattern) |

**Result:** Removed 2 unnecessary sleeps, kept 8 legitimate uses.

### 2. Introduced Marker Constants (lib/waveform/lang.ex)

Created centralized, version-independent marker strings:

```elixir
# Marker strings emitted by SuperCollider for event detection
# These are custom strings we control, making detection version-independent
# Other modules should use these public functions to ensure consistency
@marker_server_ready "WAVEFORM_SERVER_READY"
@marker_superdirt_ready "WAVEFORM_SUPERDIRT_READY"
@marker_superdirt_failed "WAVEFORM_SUPERDIRT_FAILED"
@marker_quarks_install_complete "WAVEFORM_QUARKS_INSTALL_COMPLETE"
@marker_quarks_install_failed "WAVEFORM_QUARKS_INSTALL_FAILED"

# Public accessor functions for other modules
def marker_server_ready, do: @marker_server_ready
def marker_superdirt_ready, do: @marker_superdirt_ready
def marker_superdirt_failed, do: @marker_superdirt_failed
def marker_quarks_install_complete, do: @marker_quarks_install_complete
def marker_quarks_install_failed, do: @marker_quarks_install_failed
```

**Rationale for keeping markers in Lang:**
- Lang owns the stdout detection mechanism
- Acts as the protocol layer between SC and Elixir
- Avoids circular dependencies
- Single source of truth for all wire protocol strings
- Similar to how HTTP status codes live in HTTP modules, not controllers

### 3. Updated Server Boot Detection (lib/waveform/lang.ex:62-78)

**Before:**
```elixir
Server.default.boot
```

**After:**
```supercollider
Server.default.waitForBoot({
  "WAVEFORM_SERVER_READY".postln;
});
```

Now emits our custom marker instead of relying on SC's version-specific message.

### 4. Updated SuperDirt Startup (lib/waveform/super_dirt.ex:262-274)

**Before:**
```supercollider
fork {
  ~dirt = SuperDirt(2, s);
  ~dirt.loadSoundFiles("#{sample_path}/*");
  ~dirt.start(57120, [0, 0]);
};
```

**After:**
```supercollider
fork {
  ~dirt = SuperDirt(2, s);
  ~dirt.loadSoundFiles("#{sample_path}/*");
  ~dirt.start(57120, [0, 0]);
  s.sync;
  "#{Waveform.Lang.marker_superdirt_ready()}".postln;
};
```

Added explicit synchronization and marker emission using Lang constant.

### 5. Event-Driven Quarks Installation (lib/mix/tasks/waveform.install_samples.ex)

**Before (Polling):**
```elixir
defp wait_for_installation(sample_path, max_attempts) do
  Enum.reduce_while(1..max_attempts, 0, fn attempt, prev_count ->
    Process.sleep(2000)  # ❌ Polls every 2 seconds
    current_count = count_wav_files(sample_path)
    check_installation_progress(current_count, prev_count, ...)
  end)
end
```

**After (Event-Driven):**
```elixir
# Install with error handling and completion detection
Lang.send_command("""
Routine({
  var success = false;
  try {
    Quarks.install("Dirt-Samples");
    2.wait;
    if(Quarks.isInstalled("Dirt-Samples"), {
      "#{Lang.marker_quarks_install_complete()}".postln;
    }, {
      "#{Lang.marker_quarks_install_failed()}".postln;
    });
  } {
    |err|
    "#{Lang.marker_quarks_install_failed()}".postln;
    err.postln;
  };
}).play;
""")

# Wait for event instead of polling
case Lang.wait_for_quarks_installation(timeout: 600_000) do
  :ok -> installation_complete(...)
  {:error, :installation_error} -> handle_error(...)
  {:timeout, _} -> installation_timeout(...)
end
```

### 6. Added Quarks Installation API (lib/waveform/lang.ex)

New public API similar to `wait_for_superdirt`:

```elixir
@doc """
Wait for Quarks installation to complete.

Blocks until the Quarks installation process has finished downloading
and installing the package. Returns immediately if already complete.

## Options

- `:timeout` - Maximum time to wait in milliseconds (default: 600000 / 10 minutes)

## Returns

- `:ok` - Installation completed successfully
- `{:error, :installation_error}` - Installation failed
- `{:timeout, reason}` - Timed out waiting for installation
"""
def wait_for_quarks_installation(opts \\ []) do
  timeout = Keyword.get(opts, :timeout, 600_000)
  GenServer.call(@me, :wait_for_quarks_installation, timeout)
end
```

Updated State struct:
```elixir
defstruct(
  sclang_pid: nil,
  sclang_os_pid: nil,
  server_ready: false,
  server_ready_subscribers: [],
  superdirt_ready: false,
  superdirt_ready_subscribers: [],
  quarks_installation_ready: false,      # NEW
  quarks_installation_subscribers: []    # NEW
)
```

### 7. Updated stdout Detection (lib/waveform/lang.ex:354-381)

**Before:**
```elixir
cond do
  line =~ "SuperCollider 3 server ready" ->  # ❌ Version-dependent
    send(@me, :server_ready)

  line =~ "SuperDirt: listening to Tidal on port" ->  # ❌ External dependency
    send(@me, :superdirt_ready)
end
```

**After:**
```elixir
cond do
  # Primary detection: our custom markers (version-independent)
  line =~ @marker_server_ready ->
    Waveform.OSC.setup()
    send(@me, :server_ready)

  line =~ @marker_superdirt_ready ->
    send(@me, :superdirt_ready)

  line =~ @marker_quarks_install_complete ->
    send(@me, :quarks_installation_ready)

  line =~ @marker_quarks_install_failed ->
    send(@me, {:quarks_installation_failed, :installation_error})

  # Fallback detection: original messages (backwards compatibility)
  line =~ "SuperCollider 3 server ready" ->
    Waveform.OSC.setup()
    send(@me, :server_ready)

  line =~ "SuperDirt: listening to Tidal on port" ->
    send(@me, :superdirt_ready)
end
```

Maintains backwards compatibility while preferring our controlled markers.

### 8. Added Error Handling (lib/waveform/lang.ex:410-417)

```elixir
def handle_info({:quarks_installation_failed, reason}, state) do
  # Notify all waiting subscribers of the failure
  Enum.each(state.quarks_installation_subscribers, fn from ->
    GenServer.reply(from, {:error, reason})
  end)

  {:noreply, %{state | quarks_installation_subscribers: []}}
end
```

### 9. Cleaned Up Dead Code

Removed the `verify/0` function from SuperDirt module and all references:
- Removed function implementation (was broken - always returned `:ok`)
- Removed from moduledoc "Verification" section
- Updated `init` message to reference `Helpers.ensure_superdirt_ready()` instead

### 10. Code Review: start_superdirt/1 Refactor

User had extracted `start_superdirt(sample_path)` from Helpers to SuperDirt module. Conducted peer review and identified:

**Issues Found:**
- ❌ Missing `do` keyword (syntax error)
- ❌ Missing `alias` for `Lang` or fully qualified name
- ❌ Missing `@doc` documentation
- ❌ No explicit return value
- ⚠️ Suboptimal placement (between mute/unmute functions)

**Fixes Applied:**
- ✅ Added `do` keyword
- ✅ Used fully qualified `Waveform.Lang.send_command/1`
- ✅ Added comprehensive documentation with examples
- ✅ Added explicit `:ok` return
- ✅ Moved to better location (after control commands, before config functions)

## Performance Impact

### Before
- **Quarks installation:** Up to 600 seconds (300 attempts × 2s) of polling
- **Server boot:** Fragile version-dependent string matching
- **SuperDirt startup:** No explicit synchronization, relied on external message

### After
- **Quarks installation:** Instant completion detection (plus 2s SC wait)
- **Server boot:** Reliable marker-based detection
- **SuperDirt startup:** Explicit `s.sync` + immediate marker emission
- **Error detection:** Immediate failure reporting vs silent timeout

## Key Design Decisions

### 1. Marker Ownership

**Decision:** Keep all marker constants in `Lang` module

**Rationale:**
- Lang owns the stdout detection mechanism (protocol layer)
- Avoids circular dependencies (Lang doesn't depend on SuperDirt/tasks)
- Single source of truth for all wire protocol strings
- Follows protocol module pattern (like HTTP status codes)
- Can be extracted to `Waveform.Protocol` later if needed

### 2. Backwards Compatibility

**Decision:** Keep fallback detection for original SC messages

**Rationale:**
- Graceful degradation if markers aren't emitted
- Easier migration/testing
- No breaking changes for existing code
- Can remove fallbacks in future major version

### 3. Error Handling Strategy

**Decision:** Emit explicit failure markers, not just timeout

**Rationale:**
- Distinguish between "taking a long time" vs "actually failed"
- Better UX (immediate error vs 10-minute timeout)
- Enables retry logic in future
- Follows standard async pattern (ok/error/timeout)

## Files Modified

1. **lib/waveform/lang.ex**
   - Added marker constants and public accessor functions
   - Updated `start_server` to emit marker
   - Added `wait_for_quarks_installation` API
   - Updated stdout detection to handle all markers
   - Added failure handling

2. **lib/waveform/super_dirt.ex**
   - Added full documentation for `start_superdirt/1`
   - Updated to emit marker using `Lang.marker_superdirt_ready()`
   - Removed dead `verify/0` function
   - Cleaned up moduledoc and init message

3. **lib/waveform/helpers.ex**
   - Updated module reference from `SuperDirt` to `Waveform.SuperDirt`
   - Updated comments to reference marker strings

4. **lib/mix/tasks/waveform.install_samples.ex**
   - Replaced 2-second polling loop with event-driven approach
   - Added error handling with try/catch in SuperCollider
   - Uses `Lang.marker_quarks_install_*()` constants
   - Handles `:ok`, `{:error, :installation_error}`, and `{:timeout, _}` cases

5. **lib/mix/tasks/waveform.check.ex**
   - Removed unnecessary 1-second sleep after `app.start`

## Benefits

### Reliability
✅ **Version independence** - Won't break if SC changes message strings
✅ **Explicit synchronization** - `s.sync` ensures SuperDirt is truly ready
✅ **Error detection** - Failures caught immediately, not after 10-minute timeout

### Performance
✅ **No polling** - Eliminates 2-second sleep loop (up to 600s saved)
✅ **Instant detection** - Events trigger immediately upon completion
✅ **Reduced CPU** - No busy-waiting or filesystem polling

### Maintainability
✅ **Single source of truth** - All markers in one place
✅ **No string duplication** - Modules use `Lang.marker_*()` functions
✅ **Consistent pattern** - All events use same subscriber/notification model
✅ **Future-proof** - Easy to add new markers or change format

### Developer Experience
✅ **Better error messages** - Clear failure vs timeout distinction
✅ **Faster feedback** - Don't wait 10 minutes to know installation failed
✅ **Clean API** - `Lang.wait_for_quarks_installation()` mirrors other wait functions

## Testing Recommendations

1. **Normal Flow**
   - Start server → verify marker detection
   - Start SuperDirt → verify marker detection
   - Install Quarks → verify event-driven completion

2. **Error Cases**
   - Quarks installation failure → verify failure marker emitted
   - Network timeout → verify timeout handling
   - SC version without markers → verify fallback detection

3. **Edge Cases**
   - Multiple simultaneous `wait_for_quarks_installation` calls
   - Installation completes before `wait_for_quarks_installation` called
   - Server restart during installation

## Future Improvements

### Near-term
- [ ] Add progress reporting for Quarks installation (file count, download progress)
- [ ] Implement retry logic for failed installations
- [ ] Add `SuperDirt.start_superdirt/0` that auto-detects sample path

### Long-term
- [ ] Extract markers to `Waveform.Protocol` module if more subsystems added
- [ ] Remove fallback detection in next major version (breaking change)
- [ ] Add marker versioning for protocol evolution
- [ ] Consider structured markers (JSON) instead of plain strings

## Lessons Learned

### 1. Poll vs Event-Driven
Polling is a code smell. If you're sleeping in a loop, there's usually a better way:
- Monitor process output
- Use OS notifications (inotify)
- Leverage callbacks in the controlled system

### 2. Version Dependencies
Never rely on version-specific strings from external systems:
- They will change
- You have no control
- Emit your own markers when possible

### 3. Error Handling Isn't Optional
Timeouts are not errors - they're a last resort. Always try to detect actual failures:
- Better UX (immediate feedback)
- Enables recovery strategies
- Easier debugging

### 4. Constants Belong in Protocol Layers
When multiple modules need to agree on strings/values:
- Put them in the communication layer
- Not in domain modules (causes coupling)
- Not duplicated (causes drift)

## Related Sessions

- **SESSION_2025_11_22.md** - Initial event-driven SuperDirt implementation
- **SESSION_2025_11_23.md** - Demo refactoring and CI fixes (earlier on same day)

## Global Context for Future Development

### Architecture Patterns Established

1. **Event-Driven Communication**
   - Lang monitors SC stdout for markers
   - Subscriber pattern for async waiting
   - Three possible outcomes: success, error, timeout

2. **Marker Protocol**
   - All markers prefixed with `WAVEFORM_`
   - Defined in `Lang` module (protocol layer)
   - Emitted by SC after significant events
   - Detected via `handle_info({:stdout, ...})`

3. **Wait Functions**
   Pattern for async operations:
   ```elixir
   def wait_for_X(opts \\ []) do
     timeout = Keyword.get(opts, :timeout, DEFAULT)
     GenServer.call(@me, :wait_for_X, timeout)
   end
   ```

### When to Add New Markers

Follow this pattern when adding new SC-based subsystems:

1. **Define marker in Lang:**
   ```elixir
   @marker_new_feature "WAVEFORM_NEW_FEATURE_READY"
   def marker_new_feature, do: @marker_new_feature
   ```

2. **Add state tracking:**
   ```elixir
   defstruct(..., new_feature_ready: false, new_feature_subscribers: [])
   ```

3. **Add wait function:**
   ```elixir
   def wait_for_new_feature(opts \\ [])
   ```

4. **Update stdout handler:**
   ```elixir
   line =~ @marker_new_feature ->
     send(@me, :new_feature_ready)
   ```

5. **Add event handler:**
   ```elixir
   def handle_info(:new_feature_ready, state)
   ```

6. **Emit marker from SC:**
   ```elixir
   Lang.send_command("""
     doSomething();
     "#{Lang.marker_new_feature()}".postln;
   """)
   ```

### Critical Insight: s.sync is Your Friend

Always use `s.sync` in SuperCollider before emitting ready markers:
```supercollider
fork {
  ~something = Something.new();
  ~something.start();
  s.sync;  // ← CRITICAL: Wait for server to process
  "WAVEFORM_SOMETHING_READY".postln;
};
```

Without `s.sync`, the marker may emit before the server has actually started the component.

### Why Lang Owns Markers (For Future Reference)

This decision was debated and documented:

**Alternatives considered:**
- Each domain module owns its markers (creates circular dependencies)
- Dedicated `Waveform.Protocol` module (over-engineering for now)
- Mix tasks owning markers (tasks aren't really modules for constants)

**Why Lang won:**
- Lang parses stdout (owns detection mechanism)
- Acts as protocol/transport layer
- No circular dependencies
- Precedent: HTTP modules own status codes, not controllers
- Pragmatic: Works well, can refactor later if needed

This should be revisited if:
- More than 10 markers exist
- Markers need versioning/evolution
- Multiple transport layers added (not just stdout)

## Conclusion

This session successfully eliminated polling-based waiting, introduced version-independent event detection, and added proper error handling throughout the SuperCollider integration layer. The codebase is now more reliable, performant, and maintainable.

The marker constant pattern established here provides a blueprint for all future SC integrations and can serve as a model for other event-driven subsystems in the project.
