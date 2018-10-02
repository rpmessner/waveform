defmodule MidiConversion do
  @conversions [
    {21, "A0", 27.5},
    {22, "A#0/Bb0", 29.1},
    {23, "B0", 30.9},
    {24, "C1", 32.7},
    {25, "C#1/Db1", 34.6},
    {26, "D1", 36.7},
    {27, "D#1/Eb1", 38.9},
    {28, "E1", 41.2},
    {29, "F1", 43.7},
    {30, "F#1/Gb1", 46.2},
    {31, "G1", 49.0},
    {32, "G#1/Ab1", 51.9},
    {33, "A1", 55.0},
    {34, "A#1/Bb1", 58.3},
    {35, "B1", 61.7},
    {36, "C2", 65.4},
    {37, "C#2/Db2", 69.3},
    {38, "D2", 73.4},
    {39, "D#2/Eb2", 77.8},
    {40, "E2", 82.4},
    {41, "F2", 87.3},
    {42, "F#2/Gb2", 92.5},
    {43, "G2", 98.0},
    {44, "G#2/Ab2", 103.8},
    {45, "A2", 110.0},
    {46, "A#2/Bb2", 116.5},
    {47, "B2", 123.5},
    {48, "C3", 130.8},
    {49, "C#3/Db3", 138.6},
    {50, "D3", 146.8},
    {51, "D#3/Eb3", 155.6},
    {52, "E3", 164.8},
    {53, "F3", 174.6},
    {54, "F#3/Gb3", 185.0},
    {55, "G3", 196.0},
    {56, "G#3/Ab3", 207.7},
    {57, "A3", 220.0},
    {58, "A#3/Bb3", 233.1},
    {59, "B3", 246.9},
    {60, "C4", 261.6},
    {61, "C#4/Db4", 277.2},
    {62, "D4", 293.7},
    {63, "D#4/Eb4", 311.1},
    {64, "E4", 329.6},
    {65, "F4", 349.2},
    {66, "F#4/Gb4", 370.0},
    {67, "G4", 392.0},
    {68, "G#4/Ab4", 415.3},
    {69, "A4", 440.0},
    {70, "A#4/Bb4", 466.2},
    {71, "B4", 493.9},
    {72, "C5", 523.3},
    {73, "C#5/Db5", 554.4},
    {74, "D5", 587.3},
    {75, "D#5/Eb5", 622.3},
    {76, "E5", 659.3},
    {77, "F5", 698.5},
    {78, "F#5/Gb5", 740.0},
    {79, "G5", 784.0},
    {80, "G#5/Ab5", 830.6},
    {81, "A5", 880.0},
    {82, "A#5/Bb5", 932.3},
    {83, "B5", 987.8},
    {84, "C6", 1046.5},
    {85, "C#6/Db6", 1108.7},
    {86, "D6", 1174.7},
    {87, "D#6/Eb6", 1244.5},
    {88, "E6", 1318.5},
    {89, "F6", 1396.9},
    {90, "F#6/Gb6", 1480.0},
    {91, "G6", 1568.0},
    {92, "G#6/Ab6", 1661.2},
    {93, "A6", 1760.0},
    {94, "A#6/Bb6", 1864.7},
    {95, "B6", 1975.5},
    {96, "C7", 2093.0},
    {97, "C#7/Db7", 2217.5},
    {98, "D7", 2349.3},
    {99, "D#7/Eb7", 2489.0},
    {100, "E7", 2637.0},
    {101, "F7", 2793.8},
    {102, "F#7/Gb7", 2960.0},
    {103, "G7", 3136.0},
    {104, "G#7/Ab7", 3322.4},
    {105, "A7", 3520.0},
    {106, "A#7/Bb7", 3729.3},
    {107, "B7", 3951.1},
    {108, "C8", 4186.0},
    {109, "C#8/Db8", 4434.9},
    {110, "D8", 4698.6},
    {111, "D#8/Eb8", 4978.0},
    {112, "E8", 5274.0},
    {113, "F8", 5587.7},
    {114, "F#8/Gb8", 5919.9},
    {115, "G8", 6271.9},
    {116, "G#8/Ab8", 6644.9},
    {117, "A8", 7040.0},
    {118, "A#8/Bb8", 7458.6},
    {119, "B8", 7902.1},
    {120, "C9", 8372.0},
    {121, "C#9/Db9", 8869.8},
    {122, "D9", 9397.3},
    {123, "D#9/Eb9", 9956.1},
    {124, "E9", 10548.1},
    {125, "F9", 11175.3},
    {126, "F#9/Gb9", 11839.8},
    {127, "G9", 12543.9}
  ]

  defmacro define_midi_conversions() do
    @conversions
    |> Enum.with_index()
    |> Enum.map(fn {{midi, notes, freq}, _midi_idx} ->
      toks = String.split(notes, "/")
      no_sharp = Enum.count(toks) == 1

      per_midi =
        quote do
          def to_hz(unquote(midi)), do: unquote(freq)
        end

      per_note =
        toks
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(fn {note, note_idx} ->
          is_first = note_idx == 0
          quality = if is_first, do: :flat, else: :sharp

          quote location: :keep do
            unquote do
              if is_first do
                quote do
                  unquote do
                    if no_sharp do
                      quote do
                        def to_atom(unquote(midi), :sharp), do: to_atom(unquote(midi))
                      end
                    end
                  end

                  def to_atom(unquote(midi)), do: to_atom(unquote(midi), :flat)
                end
              end
            end

            def to_atom(unquote(midi), unquote(quality)), do: unquote(String.to_atom(note))
            def to_midi(unquote(note |> String.to_atom())), do: unquote(midi)
            def to_midi(unquote(note |> String.downcase() |> String.to_atom())), do: unquote(midi)
            def to_hz(unquote(note |> String.to_atom())), do: unquote(freq)
            def to_hz(unquote(note |> String.downcase() |> String.to_atom())), do: unquote(freq)
          end
        end)

      [per_note, per_midi]
    end)
  end
end

defmodule Waveform.Music.Note do
  require MidiConversion

  MidiConversion.define_midi_conversions()
end
