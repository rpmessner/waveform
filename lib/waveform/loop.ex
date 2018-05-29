defmodule Waveform.Loop do
  alias Waveform.Loop.Manager, as: Manager

  defmacro loop(name, do: body) do
    quote do
      loop_func = fn ->
        Enum.take_while(
          Stream.repeatedly(fn ->
            unquote(body)
          end),
          fn _ -> true end
        )
      end

      pid = spawn(loop_func)

      Manager.store(
        unquote(name),
        loop_func,
        pid
      )
    end
  end

  def pause(name) do
    Manager.pause(name)
  end

  def resume(name) do
    Manager.resume(name)
  end

  def kill(name) do
    Manager.kill(name)
  end

  def kill_all() do
    Manager.kill_all()
  end
end
