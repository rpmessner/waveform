defmodule Waveform.Track do
  alias Waveform.Beat, as: Beat
  alias Waveform.OSC.Group, as: Group

  alias __MODULE__
  @me __MODULE__

  @default_over 4
  @default_beats 4

  defmacro deftrack(name, options \\ [], do: body) do
    make_track(name, %{
      beats: (options[:beats] || @default_beats),
      over: (options[:over] || @default_over)
    }, body)
  end

  defp make_track(name, %{over: over, beats: beats}, body) do
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
      unquote(function_definition)
      Beat.on_beat(unquote(name), unquote(beats), unquote(over), track_func, container_group)
    end
  end
end
