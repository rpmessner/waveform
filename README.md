# Waveform

Supercollider live coding with Elixir

## Installation

Install supercollider:

`brew install supercollider`

Install portmidi:

`brew install portmidi`

or point to the `sclang` executable with the `SCLANG_PATH` environment variable

Download repo and: 

`iex -S mix`

```elixir
play chord(:d4, :minor)

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

Process.exit(pid, :kill)
```


