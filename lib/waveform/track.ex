defmodule Waveform.Track do
  alias Waveform.Beat, as: Beat
  alias Waveform.Synth.FX, as: FX
  alias Waveform.OSC.Group, as: Group

  alias __MODULE__
  @me __MODULE__

  @default_over 4
  @default_beats 4
  @default_fx []

  defmacro deftrack(name, options \\ [], do: body) do
    make_track(
      name,
      %{
        beats: options[:beats] || @default_beats,
        over: options[:over] || @default_over,
        fx: options[:fx] || @default_fx
      },
      body
    )
  end

  defp make_track(name, %{over: over, beats: beats, fx: fx}, body) do
    function_definition =
      case body do
        [{:->, _, _} | _] ->
          quote do
            track_func = fn s ->
              case s do
                unquote(body)
              end
            end
          end

        _ ->
          quote do
            track_func = fn s ->
              unquote(body)
            end
          end
      end

    quote do
      container_group = Group.track_container_group(unquote(name))

      container_group =
        Enum.reduce unquote(fx), container_group, fn ({name, options}, acc) ->
          container_group |> FX.add_fx(name, options)
        end

      IO.inspect({'after fx', container_group})
      unquote(function_definition)

      case container_group do
        %Group{children: []} = g ->
          Beat.on_beat(unquote(name), unquote(beats), unquote(over), track_func, g)
        %Group{children: [%Group{type: :fx_synth_group} = g|_]} ->
          IO.inspect("HI")
          Beat.on_beat(unquote(name), unquote(beats), unquote(over), track_func, g)
      end
    end
  end
end
