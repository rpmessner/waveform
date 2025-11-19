# Waveform

A lightweight OSC transport layer for communicating with SuperCollider from Elixir.

Waveform provides low-level OSC messaging, node/group management, and a simple API for triggering synths. Perfect for live coding, algorithmic composition, and building custom audio applications on top of SuperCollider.

## Prerequisites

**⚠️ SuperCollider must be installed on your system before using Waveform.**

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

### Custom Installation Path

If SuperCollider is installed in a non-standard location, set the `SCLANG_PATH` environment variable:

```bash
export SCLANG_PATH=/path/to/sclang
```

### Verify Installation

After installing SuperCollider and adding Waveform to your project, run:

```bash
mix waveform.doctor
```

This will verify that your system is properly configured.

## Features

- **OSC Transport**: Send and receive OSC messages to/from SuperCollider
- **Process Management**: Automatically manages the `sclang` process
- **Node & Group Management**: Track synth nodes and organize them into groups
- **Audio Bus Allocation**: Automatic audio bus allocation for routing
- **Simple API**: Minimal, focused API for triggering synths

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

### Triggering Synths

The simplest way to trigger a synth:

```elixir
alias Waveform.Synth

# Basic synth trigger with parameters
Synth.trigger("saw", note: 60, amp: 0.5, cutoff: 1000)

# Specify node and group IDs manually
Synth.trigger("kick", [amp: 0.8], node_id: 1001, group_id: 1)

# Use the convenience play/2 function
Synth.play(60, synth: "piano", amp: 0.6)
```

### Using Note Names (Optional)

If you add the [Harmony](https://github.com/rpmessner/harmony) library to your deps, you can use note names:

```elixir
# In mix.exs
{:harmony, git: "https://github.com/rpmessner/harmony"}

# In your code
Synth.play("c4", synth: "saw", amp: 0.5)
Synth.play("a#5", synth: "piano")
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

# Load synth definitions from a directory
OSC.load_synthdefs()
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
- **Waveform.OSC.Node** - Allocates and tracks node IDs
- **Waveform.OSC.Group** - Manages groups
- **Waveform.AudioBus** - Allocates audio buses
- **Waveform.ServerInfo** - Tracks server capabilities

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

### Integrating with SuperDirt

Waveform is a perfect foundation for building TidalCycles-style live coding environments. SuperDirt should be loaded and configured separately in SuperCollider, then you can send it OSC messages directly.

For more advanced SuperDirt integration and pattern languages, see [KinoSpaetzle](https://github.com/rpmessner/kino_spaetzle) - a TidalCycles-inspired live coding environment for Livebook that uses Waveform as its transport layer.

Example of triggering SuperDirt samples:

```elixir
alias Waveform.OSC

# SuperDirt listens on port 57120 by default
# You'll need to configure a separate OSC connection to SuperDirt
# or load SuperDirt into the same scsynth instance

# Trigger a sample (after setting up SuperDirt routing)
Synth.trigger("dirt", [
  s: "bd",      # sample name
  n: 0,         # sample number
  gain: 1.0,
  orbit: 0
])
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

# Generate documentation
mix docs
```

## Roadmap

- [ ] Better SuperDirt integration
- [ ] MIDI support
- [ ] Pattern scheduling utilities
- [ ] More examples and guides

## Related Projects

- [KinoSpaetzle](https://github.com/rpmessner/kino_spaetzle) - TidalCycles-like live coding for Livebook (uses Waveform)
- [Harmony](https://github.com/rpmessner/harmony) - Music theory library for Elixir
- [SuperCollider](https://supercollider.github.io/) - The audio synthesis platform

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built for live coding music in Elixir and Livebook. Inspired by TidalCycles and the SuperCollider community.
