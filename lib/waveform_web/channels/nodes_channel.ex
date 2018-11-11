defmodule WaveformWeb.NodeChannel do
  use Phoenix.Channel

  require Logger

  defimpl Jason.Encoder, for: [Waveform.OSC.Node] do
    def encode(struct, opts) do
      Map.from_struct(struct)
    end
  end

  def active_nodes(nodes) do
    Phoenix.PubSub.broadcast(Waveform.PubSub, "nodes:active", %{type: "active", nodes: Enum.map(nodes, &Map.from_struct/1)})
  end

  def join("nodes:active", message, socket) do
    Process.flag(:trap_exit, true)
    {:ok, socket}
  end

  def handle_info(%{type: "active"}=info, socket) do
    IO.inspect({"heres", info})
    push socket, "active", info

    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end
end
