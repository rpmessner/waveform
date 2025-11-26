defmodule Waveform.OSC do
  @moduledoc """
  OSC (Open Sound Control) transport layer for SuperCollider communication.

  This module manages the UDP socket for sending OSC messages to and receiving
  messages from SuperCollider. It provides functions for creating synths, groups,
  loading synth definitions, and handling server notifications.

  The OSC module starts automatically as part of the Waveform supervision tree
  and initializes communication with SuperCollider via the sclang process.

  ## Synth Definitions

  Waveform does not include any built-in synth definitions. Users should define
  synths directly in SuperCollider, or use a synth engine like SuperDirt.

  To load synth definitions from a directory:

      OSC.load_synthdef_dir("/path/to/synthdefs")

  Or send a compiled synthdef directly:

      bytes = File.read!("my_synth.scsyndef")
      OSC.send_synthdef(bytes)

  ## OSC Message Types

  - `/s_new` - Create a new synth node
  - `/g_new` - Create a new group
  - `/g_deepFree` - Delete a group and all its nodes
  - `/g_freeAll` - Free all nodes in a group
  - `/d_recv` - Receive a synth definition
  - `/d_loadDir` - Load synth definitions from a directory
  - `/notify` - Request server notifications
  - `/status` - Request server status information

  ## Examples

      # Create a new synth (assumes synth is defined in SuperCollider)
      OSC.new_synth("saw", 1001, :head, 1, [:freq, 440, :amp, 0.5])

      # Create a new group
      OSC.new_group(100, :tail, 0)

      # Delete a group
      OSC.delete_group(100)

      # Load synthdefs from a directory
      OSC.load_synthdef_dir("/path/to/synthdefs")
  """
  use GenServer

  alias Waveform.OSC.Group
  alias Waveform.OSC.Node
  alias Waveform.ServerInfo

  alias __MODULE__
  @me __MODULE__

  # Transport layer - configurable for testing
  @transport Application.compile_env(:waveform, :osc_transport, Waveform.OSC.UDP)

  @s_new ~c"/s_new"
  @g_new ~c"/g_new"
  @g_deep_free ~c"/g_deepFree"
  @g_free_all ~c"/g_freeAll"
  @notify ~c"/notify"
  # @d_load '/d_load'
  @d_recv ~c"/d_recv"
  @d_load_dir ~c"/d_loadDir"
  @n_go ~c"/n_go"
  @n_end ~c"/n_end"
  @status ~c"/status"
  @status_reply ~c"/status.reply"
  @b_info ~c"/b_info"

  @yes 1

  @add_actions %{
    # add the new group to the the head of the group specified by the add target ID.
    head: 0,
    # add the new group to the the tail of the group specified by the add target ID.
    tail: 1,
    # add the new group just before the node specified by the add target ID.
    before: 2,
    # add the new group just after the node specified by the add target ID.
    after: 3,
    # the new node replaces the node specified by the add target ID.
    # The target node is freed.
    replace: 4
  }

  defmodule State do
    @moduledoc false
    defstruct(
      socket: nil,
      pid: nil,
      host: ~c"127.0.0.1",
      host_port: 57_110,
      udp_port: 57_111
    )
  end

  def setup do
    request_notifications()
  end

  def send_synthdef(bytes) do
    send_command([@d_recv, bytes])
  end

  def load_synthdef_dir(path) do
    send_command([@d_load_dir, to_charlist(path)])
  end

  def new_synth(name, id, action, group_id, args) do
    send_command([@s_new, name, id, @add_actions[action], group_id | args])
  end

  def delete_group(id) when is_number(id), do: delete_group([id])

  def delete_group(ids) do
    send_command([@g_deep_free | ids])
  end

  def clear_group(id) do
    send_command([@g_free_all, id])
  end

  def new_group(id, action, parent) do
    send_command([@g_new, id, @add_actions[action], parent])
  end

  def request_notifications do
    send_command([@notify, @yes])
  end

  def request_server_status do
    send_command([@status])
  end

  def send_command(command) do
    GenServer.cast(@me, {:command, command})
  end

  def start_link(_opts) do
    GenServer.start_link(@me, %State{}, name: @me)
  end

  def init(state) do
    {:ok, socket} = :gen_udp.open(state.udp_port, [:binary, {:active, false}])

    # Start UDP receiver as a linked task so it's supervised
    {:ok, pid} = Task.start_link(fn -> udp_receive(socket) end)

    state = %State{
      socket: socket,
      pid: pid
    }

    # Defer server startup to avoid blocking init
    send(self(), :start_server)

    {:ok, state}
  end

  def terminate(_reason, state) do
    :gen_udp.close(state.socket)
    # No need to kill pid - it will die when socket closes or when this process dies (linked)
  end

  def handle_info(:start_server, state) do
    Waveform.Lang.start_server()
    {:noreply, state}
  end

  def handle_cast({:command, command}, state) do
    osc(state, command)
    {:noreply, state}
  end

  defp udp_receive(socket) do
    case :gen_udp.recv(socket, 0, 1000) do
      {:ok, {_ip, _port, the_message}} ->
        handle_udp_message(socket, the_message)

      {:error, :timeout} ->
        udp_receive(socket)

      {:error, :closed} ->
        handle_socket_closed()

      {:error, reason} ->
        handle_udp_error(socket, reason)
    end
  end

  defp handle_udp_message(socket, the_message) do
    message = :osc.decode(the_message)
    process_osc_message(message)
    udp_receive(socket)
  rescue
    error ->
      require Logger
      Logger.warning("Error decoding OSC message: #{inspect(error)}")
      udp_receive(socket)
  end

  defp process_osc_message({:cmd, [@status_reply, _ | response]}) do
    ServerInfo.set_from_status_reply(response)
  end

  defp process_osc_message({:cmd, [@n_go, 1 | _]}) do
    Group.setup()
    OSC.request_server_status()
  end

  defp process_osc_message({:cmd, [@n_go, node_id | _]}) do
    Node.activate_node(node_id)
  end

  defp process_osc_message({:cmd, [@n_end, node_id | _]}) do
    Node.deactivate_node(node_id)
  end

  defp process_osc_message({:cmd, [@b_info, buffer_num, num_frames, num_channels, sample_rate]}) do
    # Forward buffer info to Buffer module
    if Process.whereis(Waveform.Buffer) do
      send(Waveform.Buffer, {:buffer_info, buffer_num, num_frames, num_channels, sample_rate})
    end
  end

  defp process_osc_message(_), do: nil

  defp handle_socket_closed do
    require Logger
    Logger.info("UDP socket closed, stopping receiver")
    :ok
  end

  defp handle_udp_error(socket, reason) do
    require Logger
    Logger.error("UDP receive error: #{inspect(reason)}")
    Process.sleep(100)
    udp_receive(socket)
  end

  defp osc(state, [address | args]) do
    # IO.inspect({"osc send:", [address | args]})
    @transport.send_osc_message(state, address, args)
  end
end
