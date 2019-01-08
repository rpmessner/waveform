defmodule Waveform.Music.Form do
  alias Waveform.Music.Chord
  alias Waveform.Music.Transpose
  alias __MODULE__

  import Waveform.Music.Util

  defmodule Measure do
    defstruct(
      quality: nil,
      alteration: nil,
      transpose: nil,
      roman: nil
    )
  end

  default_bpm = 4
  default_key = :c
  default_octave = 4
  default_inversion = 0

  @default_inversion default_inversion
  # @default_octave default_octave

  defstruct(
    bpm: default_bpm,
    key: default_key,
    octave: default_octave,
    inversion: default_inversion,
    measures: []
  )

  major_qualities = %{
    :"" => :maj,
    :"7" => :dom7,
    :maj7 => :maj7,
    :M7 => :maj7
  }

  minor_qualities = %{
    :"" => :min,
    :"7" => :min7,
    :m7 => :min7,
    :"7b5" => :halfdim
  }

  @qualities %{
    :I => major_qualities,
    :II => major_qualities,
    :III => major_qualities,
    :IV => major_qualities,
    :V => major_qualities,
    :VI => major_qualities,
    :VII => major_qualities,
    :i => minor_qualities,
    :ii => minor_qualities,
    :iii => minor_qualities,
    :iv => minor_qualities,
    :v => minor_qualities,
    :vi => minor_qualities,
    :vii => minor_qualities
  }

  @roman_scanner ~r/(iii|ii|i|iv|vii|vi|v|III|II|IV|I|VII|VI|V){1}(b|#)?(.*)/

  defmacro defform(module_name, do: {:__block__, _meta, lines}) do
    form =
      Enum.reduce(lines, %Form{}, fn line, form ->
        case line do
          {:beats_per_measure, _, [value]} ->
            %{form | bpm: value}

          {:key, _, [value]} ->
            %{form | key: value}

          {:octave, _, [value]} ->
            %{form | octave: value}

          {:measures, _, romans} ->
            measures =
              Enum.map(romans, fn roman ->
                case roman do
                  # {a, options} when is_list(options) ->
                  #   measure(a)

                  {:{}, _, [a, b, c]} when is_atom(a) and is_atom(b) and is_list(c) ->
                    {measure(a, roman_interval(c[:of])), measure(b, roman_interval(c[:of]))}

                  {a, b} when is_atom(a) and is_atom(b) ->
                    {measure(a), measure(b)}

                  {a, _} when is_atom(a) ->
                    measure(a)

                  _ ->
                    measure(roman)
                end
              end)

            %{form | measures: form.measures ++ measures}

          _ ->
            form
        end
      end)

    quote do
      defmodule unquote(module_name) do
        @form unquote(Macro.escape(form))

        def chord_at(options \\ []) do
          Waveform.Music.Form.chord_at(@form, options)
        end
      end
    end
  end

  def chord_at(%Form{} = form, options) do
    %Form{bpm: bpm, measures: measures, key: key, octave: octave} = form

    # total_beats = bpm * Enum.count(List.flatten(measures))

    beat = options[:beat] || 0
    measure_beat = if beat == bpm, do: beat, else: rem(beat, bpm)
    measure = (options[:measure] || 1) - 1
    inversion = options[:inversion] || @default_inversion
    octave = options[:octave] || octave

    opts = %{
      beat: measure_beat,
      measure: if(beat == bpm, do: 0, else: Kernel.trunc(beat / bpm)) + measure,
      inversion: inversion,
      octave: octave
    }

    measure = Enum.at(measures, opts.measure)

    %Measure{quality: quality, roman: roman, transpose: transpose} =
      case measure do
        %Measure{} = m ->
          m

        t when is_tuple(t) ->
          list = t |> Tuple.to_list()

          num_measures = list |> Enum.count()

          index =
            [Float.round(measure_beat / bpm * num_measures) - 1, 0]
            |> Enum.max()
            |> Kernel.trunc()

          list |> Enum.at(index)
      end

    note = Transpose.transpose_roman(key, roman)

    note = Transpose.transpose_note(note, transpose)

    %Chord{
      tonic: :"#{note}#{opts.octave}",
      quality: quality,
      inversion: opts.inversion
    }
  end

  defp measure(roman, transpose \\ :"1P") do
    [[_, roman, alteration, quality]] = Regex.scan(@roman_scanner, to_string(roman))
    degree = :"#{roman}"

    %Measure{
      roman: degree,
      transpose: transpose,
      alteration: alteration,
      quality: @qualities[degree][:"#{quality}"]
    }
  end
end
