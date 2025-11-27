# Waveform

A lightweight OSC transport layer for communicating with SuperCollider from Elixir.

Waveform provides low-level OSC messaging, node/group management, and a simple API for triggering synths. Perfect for live coding, algorithmic composition, and building custom audio applications on top of SuperCollider.

## Prerequisites

**Requirements:**
- Elixir 1.17 or later
- Erlang/OTP 27 or later
- SuperCollider 3.x

**⚠️ SuperCollider must be installed on your system before using Waveform.**

### Installing SuperCollider

**macOS:**
```bash
brew install supercollider
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt-get install supercollider

# Arch
sudo pacman -S supercollider
```

**Windows:**
Download from [supercollider.github.io](https://supercollider.github.io/)

### Installing SuperDirt (Optional, for Pattern-Based Live Coding)

If you want to use Waveform's pattern scheduler with SuperDirt (TidalCycles-style live coding):

1. **Install the SuperDirt Quark** (one-time setup):

   Open SuperCollider IDE and run:
   ```supercollider
   Quarks.install("SuperDirt");
   thisProcess.recompile;
   ```

2. **Install Dirt-Samples** (optional but recommended):

   Dirt-Samples provides 217 sample banks (1800+ audio files) including drum machines,
   percussion, synths, and instruments. Waveform includes an automated installer:

   ```bash
   mix waveform.install_samples
   ```

   This will:
   - Download ~200MB of samples
   - Install them to the correct location for your OS
   - Verify the installation
   - Provide next steps

   **Note:** Waveform is pre-configured with optimal buffer settings (4096 buffers)
   to support all Dirt-Samples. No additional configuration needed!

3. **Start SuperDirt** (automatic):

   Waveform automatically starts SuperDirt with the correct configuration when you use
   `Helpers.ensure_superdirt_ready()`. The samples are loaded automatically from the
   installed Dirt-Samples directory.

   ```elixir
   alias Waveform.Helpers
   Helpers.ensure_superdirt_ready()
   ```

4. **Install sc3-plugins** (optional, for additional synths):

   The sc3-plugins provide additional synthesizers like `superpiano`, `supermandolin`,
   `supergong`, and more. These are physical modeling synths that extend SuperDirt's
   capabilities beyond sample playback.

   **Installation:**
   ```bash
   # macOS
   brew install sc3-plugins

   # Linux (Debian/Ubuntu)
   sudo apt-get install sc3-plugins

   # Arch Linux
   sudo pacman -S sc3-plugins

   # Windows
   # Download from https://supercollider.github.io/sc3-plugins/
   ```

   After installation, restart SuperCollider and Waveform to use these synths.

   **Note:** The demos in this repository use samples from Dirt-Samples by default
   and don't require sc3-plugins. If you want to experiment with synths like
   `superpiano`, install sc3-plugins and see `test_superpiano.exs` for an example.

### Custom Installation Path

If SuperCollider is installed in a non-standard location, set the `SCLANG_PATH` environment variable:

```bash
export SCLANG_PATH=/path/to/sclang
```

### Verify Installation

After installing SuperCollider (and optionally SuperDirt), run:

```bash
mix waveform.doctor
```

This will verify that your system is properly configured, including checking for SuperDirt if you plan to use pattern-based features.

## Features

- **OSC Transport**: Send and receive OSC messages to/from SuperCollider
- **Process Management**: Automatically manages the `sclang` process
- **Node & Group Management**: Track synth nodes and organize them into groups
- **Simple API**: Minimal, focused API for triggering synths
- **SuperDirt Integration**: TidalCycles-compatible sample playback and effects
- **Pattern Scheduler**: High-precision continuous pattern playback with cycle-based timing
- **Hot-Swappable Patterns**: Change patterns while they're playing without stopping
- **MIDI Output**: Send patterns to hardware synths, DAWs, or any MIDI device
- **MIDI Input**: Receive notes and CC from controllers, route to SuperDirt or custom handlers
- **MIDI Clock**: Sync with external gear as master or slave (24 PPQ)
- **Multi-Output**: Route patterns to SuperCollider, MIDI, or both simultaneously

## Installation

Add `waveform` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:waveform, "~> 0.2.0"}
  ]
end
```

Then run:

```bash
mix deps.get
mix waveform.doctor  # Verify SuperCollider is installed
```

## Quick Start

```elixir
# Start your application (Waveform starts automatically)
# The sclang process and SuperCollider server will boot

# Trigger a synth (assumes you have a synth named "default" loaded)
alias Waveform.Synth

Synth.trigger("default", note: 60, amp: 0.5)
```

## Usage

### Defining Synths

Waveform does not include any built-in synth definitions. You need to define synths in SuperCollider first.

You can define synths in several ways:

**Option 1: Define in SuperCollider directly**

```elixir
alias Waveform.Lang

Lang.send_command("""
  SynthDef(\\saw, { |freq=440, amp=0.1, out=0|
    Out.ar(out, Saw.ar(freq, amp))
  }).add;
""")
```

**Option 2: Load from a file**

```elixir
# Place your .scsyndef files in a directory
OSC.load_synthdef_dir("/path/to/synthdefs")
```

**Option 3: Use SuperDirt**

For TidalCycles-style live coding, load SuperDirt which includes many synths and samples. See the [SuperDirt integration](#integrating-with-superdirt) section below.

### Triggering Synths

Once you have synths defined, trigger them with:

```elixir
alias Waveform.Synth

# Basic synth trigger with parameters
Synth.trigger("saw", note: 60, amp: 0.5, cutoff: 1000)

# Specify node and group IDs manually
Synth.trigger("kick", [amp: 0.8], node_id: 1001, group_id: 1)

# Use the convenience play/2 function
Synth.play(60, synth: "piano", amp: 0.6)
```

### Low-Level OSC API

For more control, use the OSC module directly:

```elixir
alias Waveform.OSC

# Send raw OSC commands
OSC.new_synth("my-synth", node_id, :head, group_id, [:freq, 440, :amp, 0.5])

# Create a new group
OSC.new_group(group_id, :tail, parent_group_id)

# Delete a group and all its nodes
OSC.delete_group(group_id)

# Load synth definitions from a directory (if you have custom synthdefs)
OSC.load_synthdef_dir("/path/to/your/synthdefs")
```

### Node and Group Management

```elixir
alias Waveform.OSC.Node
alias Waveform.OSC.Group

# Get the next available node ID
%{id: node_id} = Node.next_synth_node()

# Get a process-specific group
%{id: group_id} = Group.synth_group(self())

# Create a named group
group = Group.chord_group("my-chord")
```

### Sending Commands to SuperCollider

You can send arbitrary SuperCollider code to the `sclang` interpreter:

```elixir
alias Waveform.Lang

Lang.send_command("""
  SynthDef(\\simple, { |freq=440, amp=0.1|
    Out.ar(0, SinOsc.ar(freq, 0, amp))
  }).add;
""")
```

## Architecture

Waveform starts a supervision tree with these processes:

- **Waveform.Lang** - Manages the `sclang` process
- **Waveform.OSC** - Handles OSC message transport
- **Waveform.OSC.Node.ID** - Allocates unique node IDs (Agent)
- **Waveform.OSC.Node** - Tracks node lifecycle
- **Waveform.OSC.Group** - Manages groups

## Use Cases

### Live Coding in Livebook

```elixir
Mix.install([
  {:waveform, "~> 0.2.0"}
])

alias Waveform.Synth

# Define a pattern
notes = [60, 64, 67, 72]

# Play the pattern
Task.async(fn ->
  Stream.cycle(notes)
  |> Enum.each(fn note ->
    Synth.play(note, synth: "default", amp: 0.5)
    Process.sleep(250)
  end)
end)
```

### Building a Pattern Engine

Waveform is designed to be a foundation for higher-level pattern languages (like TidalCycles or Strudel):

```elixir
defmodule MyPatternEngine do
  alias Waveform.Synth

  def schedule_event(%Event{time: time, synth: synth, params: params}) do
    Process.send_after(self(), {:trigger, synth, params}, time)
  end

  def handle_info({:trigger, synth, params}, state) do
    Synth.trigger(synth, params)
    {:noreply, state}
  end
end
```

### Pattern-Based Live Coding with SuperDirt

Waveform includes built-in SuperDirt integration and a high-precision pattern scheduler for TidalCycles-style live coding.

**Prerequisites:** Make sure SuperDirt is installed and loaded (see [Prerequisites](#prerequisites)).

**Basic SuperDirt playback:**

```elixir
alias Waveform.SuperDirt

# Start SuperDirt in SuperCollider
Waveform.Lang.send_command("SuperDirt.start;")

# Trigger individual samples
SuperDirt.play(s: "bd")                    # Bass drum
SuperDirt.play(s: "sn", n: 2, gain: 0.8)  # Snare variant 2
SuperDirt.play(s: "cp", room: 0.5, size: 0.8)  # Clap with reverb
```

**Continuous pattern playback:**

```elixir
alias Waveform.PatternScheduler

# Set tempo (0.5625 = 135 BPM)
PatternScheduler.set_cps(0.5625)

# Define a drum pattern (events at cycle positions 0.0 to 1.0)
drums = [
  {0.0, [s: "bd"]},      # Kick on the 1
  {0.25, [s: "cp"]},     # Clap on the 2
  {0.5, [s: "sn"]},      # Snare on the 3
  {0.75, [s: "cp"]}      # Clap on the 4
]

# Start the pattern looping
PatternScheduler.schedule_pattern(:drums, drums)

# Add a hi-hat pattern
hats = [
  {0.0, [s: "hh", n: 0]},
  {0.125, [s: "hh", n: 1]},
  {0.25, [s: "hh", n: 0]},
  {0.375, [s: "hh", n: 1]},
  {0.5, [s: "hh", n: 0]},
  {0.625, [s: "hh", n: 1]},
  {0.75, [s: "hh", n: 0]},
  {0.875, [s: "hh", n: 1]}
]

PatternScheduler.schedule_pattern(:hats, hats)

# Hot-swap the drum pattern while it's playing
new_drums = [
  {0.0, [s: "bd", n: 1]},
  {0.5, [s: "bd", n: 2]}
]
PatternScheduler.update_pattern(:drums, new_drums)

# Change tempo on the fly
PatternScheduler.set_cps(0.75)  # Speed up to 180 BPM

# Stop a specific pattern
PatternScheduler.stop_pattern(:hats)

# Emergency stop all patterns
PatternScheduler.hush()
```

**Cycle-aware patterns (dynamic patterns):**

For patterns that change based on cycle number, pass a query function instead of a static event list:

```elixir
# Alternates between two patterns every cycle
PatternScheduler.schedule_pattern(:alternating, fn cycle ->
  if rem(cycle, 2) == 0 do
    [{0.0, [s: "bd"]}, {0.5, [s: "sd"]}]
  else
    [{0.0, [s: "hh"]}, {0.5, [s: "cp"]}]
  end
end)

# Only play every 4th cycle
PatternScheduler.schedule_pattern(:sparse, fn cycle ->
  if rem(cycle, 4) == 0 do
    [{0.0, [s: "bd", gain: 1.2]}]
  else
    []
  end
end)

# Integration with UzuPattern for cycle-aware transformations
alias UzuPattern.Pattern

pattern = Pattern.new("bd sd hh cp")
  |> Pattern.fast(2)
  |> Pattern.every(4, &Pattern.rev/1)

PatternScheduler.schedule_pattern(:drums, fn cycle ->
  Pattern.query(pattern, cycle)
end)
```

**For more advanced pattern languages**, see [kino_harmony](https://github.com/rpmessner/kino_harmony) - a TidalCycles-inspired live coding environment for Livebook with advanced jazz harmony support.

### MIDI Output

Waveform supports MIDI output as a parallel audio destination to SuperCollider. Send patterns to hardware synths, DAWs, or any MIDI-capable software.

**Basic MIDI playback:**

```elixir
alias Waveform.MIDI

# List available MIDI ports
MIDI.Port.list_outputs()

# Send a single note
MIDI.play(note: 60, velocity: 80, channel: 1)

# With automatic note-off after 500ms
MIDI.play(note: 60, velocity: 80, duration_ms: 500)

# Control change and program change
MIDI.control_change(1, 64, 1)      # Modulation wheel to 64
MIDI.program_change(5, 1)          # Change to program 5

# Raw note on/off
MIDI.note_on(60, 100, 1)
MIDI.note_off(60, 1)

# Panic - all notes off
MIDI.all_notes_off()
```

**Pattern scheduling with MIDI output:**

```elixir
alias Waveform.PatternScheduler

# Set tempo
PatternScheduler.set_cps(0.5)  # 120 BPM

# Define a melody pattern
melody = [
  {0.0, [note: 60, velocity: 80]},
  {0.25, [note: 64, velocity: 70]},
  {0.5, [note: 67, velocity: 90]},
  {0.75, [note: 72, velocity: 85]}
]

# Schedule with MIDI output
PatternScheduler.schedule_pattern(:melody, melody,
  output: :midi,
  midi_channel: 1
)

# Send to BOTH SuperCollider and MIDI simultaneously
PatternScheduler.schedule_pattern(:hybrid, melody,
  output: [:superdirt, :midi],
  midi_channel: 1
)
```

**Multi-port routing:**

Configure port aliases for easy routing to multiple MIDI destinations:

```elixir
# config/config.exs
config :waveform,
  midi_ports: %{
    drums: "IAC Driver Bus 1",
    synth: "USB MIDI Device",
    hardware: "MIDI Out 1"
  }
```

```elixir
# Use aliases in patterns
PatternScheduler.schedule_pattern(:bass, bass_events,
  output: :midi,
  midi_port: :synth,
  midi_channel: 2
)

# Per-event port routing
events = [
  {0.0, [note: 36, port: :drums, channel: 10]},   # Kick to drums port
  {0.5, [note: 60, port: :synth, channel: 1]}     # Note to synth port
]

PatternScheduler.schedule_pattern(:multi, events, output: :midi)
```

### MIDI Input

Receive MIDI input from controllers, keyboards, or other MIDI devices. Route notes directly to SuperDirt for live playing, or register custom handlers for advanced control.

**Basic MIDI input:**

```elixir
alias Waveform.MIDI.Input

# List available input ports
Input.list_ports()

# Start listening to a port
Input.listen("USB MIDI Keyboard")

# Or listen to all available ports
Input.listen_all()

# Register a handler for note events
Input.on_note(fn event ->
  IO.inspect(event)
  # %{type: :note_on, note: 60, velocity: 100, channel: 1}
end)

# Register a handler for CC (control change) events
Input.on_cc(fn %{cc: cc, value: v} ->
  IO.puts("CC #{cc} = #{v}")
end)

# Stop listening
Input.stop()
```

**Route MIDI to SuperDirt for live playing:**

```elixir
# Play piano samples with incoming notes
# Velocity is automatically mapped to gain
Input.route_to_superdirt(s: "piano")

# Use a different sample with reduced volume
Input.route_to_superdirt(s: "superpiano", gain_scale: 0.5)

# Add effects
Input.route_to_superdirt(s: "piano", room: 0.5, size: 0.8)

# Stop routing
Input.stop_superdirt_routing()
```

**Channel filtering:**

```elixir
# Only receive events from channel 1
Input.set_channel_filter(1)

# Receive from all channels (default)
Input.set_channel_filter(nil)
```

**All event types:**

```elixir
# Handle all MIDI events (for debugging or custom routing)
Input.on_all(fn event ->
  case event.type do
    :note_on -> "Note #{event.note} on"
    :note_off -> "Note #{event.note} off"
    :cc -> "CC #{event.cc} = #{event.value}"
    :program_change -> "Program #{event.program}"
    :pitch_bend -> "Pitch bend #{event.value}"
    :aftertouch -> "Aftertouch on note #{event.note}"
    _ -> "Unknown"
  end
end)

# Clear specific handlers
Input.clear_handlers(:note)
Input.clear_handlers(:cc)

# Clear all handlers
Input.clear_handlers()
```

**Velocity curves:**

Convert gain values (0.0-1.0) to MIDI velocity using different curves:

```elixir
# config/config.exs
config :waveform,
  midi_velocity_curve: :linear       # Default: 0.5 gain → ~64 velocity
  # midi_velocity_curve: :exponential  # Quieter: 0.5 gain → ~32 velocity
  # midi_velocity_curve: :logarithmic  # Louder: 0.5 gain → ~90 velocity
```

**Virtual MIDI ports:**

Create virtual MIDI outputs that appear as MIDI devices to other applications (macOS/Linux only):

```elixir
# Create a virtual output named "Waveform"
{:ok, conn} = MIDI.Port.create_virtual_output("Waveform")

# Other apps (DAWs, etc.) can now connect to "Waveform" as a MIDI input
```

### MIDI Clock Sync

Synchronize with external MIDI devices using MIDI clock. Waveform can act as a clock master (sending clock) or slave (receiving clock).

**Master mode - send clock to external gear:**

```elixir
alias Waveform.MIDI.Clock

# Start sending clock at 120 BPM
Clock.start_master(120)

# Change tempo on the fly
Clock.set_bpm(140)

# Transport controls
Clock.send_start()     # Tell receivers to start playback
Clock.send_stop()      # Tell receivers to stop
Clock.send_continue()  # Resume from current position

# Stop sending clock
Clock.stop_master()
```

**Slave mode - sync to external clock:**

```elixir
# Start listening for clock from a MIDI device
Clock.start_slave("USB MIDI Keyboard")

# PatternScheduler tempo automatically syncs to incoming clock
# When external device sends Stop, patterns will hush

# Check if clock is running (received Start without Stop)
Clock.running?()

# Get calculated BPM from incoming clock
Clock.get_bpm()

# Stop listening
Clock.stop_slave()
```

**Configuration:**

```elixir
# config/config.exs
config :waveform,
  midi_clock_port: "IAC Driver Bus 1",  # Default clock output port
  midi_clock_smoothing: 8               # Ticks to average for BPM calculation
```

### Buffer Management

Load custom samples into SuperCollider for use with your own synth definitions. This is separate from SuperDirt's sample loading.

```elixir
alias Waveform.Buffer

# Load a sample file
{:ok, buf_num} = Buffer.read("/path/to/kick.wav")

# Load portion of a file
{:ok, buf_num} = Buffer.read("/path/to/long_sample.wav",
  start_frame: 44100,   # Start 1 second in (at 44.1kHz)
  num_frames: 88200     # Load 2 seconds
)

# Allocate empty buffer (for recording)
{:ok, buf_num} = Buffer.allocate(88200, 2)  # 2 seconds stereo

# List all managed buffers
Buffer.list()

# Free a buffer
Buffer.free(buf_num)

# Free all buffers
Buffer.free_all()
```

**Playing buffers with synths:**

First, define a synth in SuperCollider:

```supercollider
SynthDef(\playbuf, { |out=0, bufnum, rate=1, amp=0.5|
  var sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, doneAction: 2);
  Out.ar(out, sig * amp);
}).add;
```

Then play it from Elixir:

```elixir
{:ok, buf} = Buffer.read("/path/to/sample.wav")
Waveform.Synth.new("playbuf", bufnum: buf, rate: 1.0, amp: 0.8)
```

## Development

```bash
# Clone the repository
git clone https://github.com/rpmessner/waveform.git
cd waveform

# Install dependencies
mix deps.get

# Compile
mix compile

# Run tests
mix test

# Check code coverage
MIX_ENV=test mix coveralls

# Generate documentation
mix docs
```

### Development Session Documentation

Development sessions are documented in `docs/sessions/` to maintain context across sessions and help contributors understand recent changes:

- **Session history**: See [docs/sessions/README.md](docs/sessions/README.md)
- **Latest session**: Check the most recent file in `docs/sessions/`
- **Project changelog**: See [CHANGELOG.md](CHANGELOG.md)

When working on Waveform (especially with AI assistants), consult the session documentation for context on recent architectural decisions and ongoing work.

## Roadmap

- [x] SuperDirt integration (✅ Complete - v0.3.0)
- [x] Pattern scheduling utilities (✅ Complete - v0.3.0)
- [x] MIDI output support (✅ Complete - v0.4.0)
- [x] MIDI input support (✅ Complete - v0.4.0)
- [x] MIDI clock sync (✅ Complete - v0.4.0)
- [x] Buffer management for custom samples (✅ Complete - v0.4.0)
- [ ] More examples and guides

## Troubleshooting

### SuperDirt / Dirt-Samples Issues

#### Only hearing kick drum / Some samples don't play

**Cause:** SuperCollider's buffer limit is too low for Dirt-Samples (1817 audio files).

**Solution:** Waveform is pre-configured with `numBuffers = 4096` to support all samples.
If you're still experiencing issues:

1. Verify Dirt-Samples is installed:
   ```bash
   mix waveform.install_samples
   ```

2. Restart your application completely (not just reload):
   ```elixir
   # In IEx
   :init.restart()
   ```

3. Check the installation:
   ```bash
   ls ~/Library/Application\ Support/SuperCollider/downloaded-quarks/Dirt-Samples/
   # Should show 217+ directories (bd, sn, hh, cp, etc.)
   ```

#### ERROR: No more buffer numbers

**Cause:** The buffer limit has been exceeded.

**Solution:** This is handled automatically by Waveform's server configuration. If you see this error:

1. Make sure you're using the latest version of Waveform
2. Restart your application
3. If the issue persists, you may have custom server options overriding Waveform's settings

#### Samples installed but not loading

**Cause:** Sample path not configured correctly.

**Solution:** Waveform automatically detects the correct sample path for your OS. If samples
still don't load:

1. Verify the path exists:
   - **macOS**: `~/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples`
   - **Linux**: `~/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples`
   - **Windows**: `~/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples`

2. Check the sample count:
   ```bash
   find ~/Library/Application\ Support/SuperCollider/downloaded-quarks/Dirt-Samples/ -name "*.wav" | wc -l
   # Should show ~1800 files
   ```

3. If files are missing, reinstall:
   ```bash
   mix waveform.install_samples
   ```

### General SuperCollider Issues

#### SuperCollider not found

Run `mix waveform.doctor` to diagnose installation issues.

If SuperCollider is installed in a custom location:
```bash
export SCLANG_PATH=/path/to/sclang
```

#### Server won't start

1. Check if another SuperCollider instance is running
2. Verify audio device permissions (macOS/Linux)
3. Check SuperCollider logs for errors
4. Try running SuperCollider IDE directly to diagnose

### Getting Help

1. Run diagnostics: `mix waveform.doctor`
2. Test SuperDirt: `mix waveform.check`
3. Report issues: https://github.com/rpmessner/waveform/issues

## Ecosystem Role

Waveform is the **audio layer** of the Elixir music ecosystem:

```
  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
  │  UzuParser   │──▶│  UzuPattern  │   │   harmony    │
  │  (parsing)   │   │ (transforms) │   │   (theory)   │
  │              │   │              │   │              │
  │ • parse/1    │   │ • fast/slow  │   │ • chords     │
  │ • mini-      │   │ • rev/early  │   │ • scales     │
  │   notation   │   │ • stack/cat  │   │ • voicings   │
  │ • [%Event{}] │   │ • every/when │   │ • intervals  │
  └──────────────┘   └──────────────┘   └──────────────┘
                           │
                           ▼
                 ┌──────────────────┐
                 │    waveform      │ ◀── YOU ARE HERE
                 │    (audio)       │
                 │                  │
                 │ • OSC            │
                 │ • SuperDirt      │
                 │ • MIDI           │
                 │ • scheduling     │
                 └──────────────────┘
```

**Waveform handles:**
- OSC communication with SuperCollider
- SuperDirt sample playback and effects
- Pattern scheduling with cycle-based timing
- MIDI output to hardware synths, DAWs, and virtual instruments

**Waveform does NOT handle:**
- Pattern parsing (→ UzuParser)
- Pattern transformations (→ UzuPattern)
- Music theory (→ harmony)
- API gateway / RPC (→ HarmonyServer)

## Related Projects

- [UzuParser](https://github.com/rpmessner/uzu_parser) - Pattern parsing (mini-notation to events)
- [UzuPattern](https://github.com/rpmessner/uzu_pattern) - Pattern transformations (fast, slow, rev, stack, cat, every, jux)
- [Harmony](https://github.com/rpmessner/harmony) - Music theory library for Elixir
- [SuperCollider](https://supercollider.github.io/) - The audio synthesis platform

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

When contributing significant changes:

1. Run `mix test` to ensure all tests pass
2. Check `MIX_ENV=test mix coveralls` to verify coverage
3. Update or create session documentation in `docs/sessions/` for major features
4. Update [CHANGELOG.md](CHANGELOG.md) with your changes

See [docs/sessions/README.md](docs/sessions/README.md) for context on recent development work.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built for live coding music in Elixir and Livebook. Inspired by TidalCycles and the SuperCollider community.
