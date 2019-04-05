# Waveform

Supercollider live coding with Elixir

## Installation

Install supercollider:

`brew install supercollider`

or point to the `sclang` executable with the `SCLANG_PATH` environment variable

Download repo and: 

``` sh
mix deps.get
iex -S mix
```

Copy and paste the following into your IEX prompt:

```elixir
play chord(:d4, :minor)
```

You should hear a d-minor chord play! 🎶 

Copy and paste the following into the IEX prompt:

```elixir

ii_V_I = [
  {chord(:d4, :minor7),    2},
  {chord(:g5, :dominant7), 2},
  {chord(:c5, :major7),    4}
]

progression = fn -> Enum.map(Stream.cycle(ii_V_I), fn {chord, beats} ->
    play chord, duration: beats, attack: 0.2, decay: 1
    Process.sleep beats
  end)
end

pid = spawn progression

```

You should be hearing a repeating ii V I chord progression!

To stop the progression from playing, copy and paste the following into the IEX prompt:

```
Process.exit(pid, :kill)
```
