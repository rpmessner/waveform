defmodule Waveform.Loop do
  alias Waveform.Loop.Manager, as: Manager

  defmacro loop(name, do: body) do
    quote do
      loop_func = fn ->
        Enum.map(Stream.repeatedly(fn ->
          unquote(body)
        end), fn _ -> end)
      end

      pid = spawn loop_func

      Manager.store(
        unquote(name),
        pid
      )
    end
  end

  def kill(name) do
    Manager.kill(name)
  end

  def kill_all() do
    Manager.kill_all()
  end

end

