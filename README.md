# Waveform

Supercollider live coding with Elixir

## Installation

Install supercollider:

`brew cask install supercollider`

or point to the `sclang` executable with the `SCLANG_PATH` environment variable
visible to your livebook instance.

In livebook in the setup block:

```elixir
Mix.install([{:waveform, git: "https://github.com/rpmessner/waveform"}])
```

The Synth.play function will send messages to supercollider.

To play a note add a new section to your livebook with the following code:

```elixir

alias Waveform.Synth

Synth.synth("d4")
```


```elixir
alias Harmony.Chord
ii_V_I = [
  {Chord.get("min7", "d4"), 2},
  {Chord.get("7", "g5"), 2},
  {Chord.get("maj7", "c5"), 4}
]

progression = fn -> Enum.map(Stream.cycle(ii_V_I), fn {chord, beats} ->
    Synth.play chord, duration: beats, attack: 0.2, decay: 1
    Process.sleep beats
  end)
end

pid = spawn progression

```

You should be hearing a repeating ii V I chord progression!

To stop the progression from playing, evaluate the following:

```elixir
Process.exit(pid, :kill)
```
