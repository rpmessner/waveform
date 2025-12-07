defmodule Waveform.MIDI.Port do
  @moduledoc """
  MIDI port discovery and connection management.

  Wraps Midiex to provide port caching and convenient access patterns.
  Connections are cached to avoid repeatedly opening/closing ports.

  ## Port Aliases

  Configure port aliases for easy routing in your config:

      config :waveform,
        midi_ports: %{
          drums: "IAC Driver Bus 1",
          synth: "USB MIDI Device",
          hardware: "MIDI Out 1"
        }

  Then use aliases instead of full port names:

      Waveform.MIDI.Port.get_output(:drums)
      Waveform.MIDI.play(note: 60, port: :synth)

  ## Usage

      # List available output ports
      Waveform.MIDI.Port.list_outputs()

      # Get or create a connection by name
      {:ok, conn} = Waveform.MIDI.Port.get_output("IAC Driver Bus 1")

      # Get connection by alias
      {:ok, conn} = Waveform.MIDI.Port.get_output(:drums)

      # Create a virtual output (appears as MIDI device to other apps)
      {:ok, conn} = Waveform.MIDI.Port.create_virtual_output("Waveform")

      # List configured port aliases
      Waveform.MIDI.Port.list_aliases()

  """

  use GenServer

  @me __MODULE__

  # Client API

  @doc """
  Starts the port manager.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(@me, opts, name: @me)
  end

  @doc """
  Lists all available MIDI ports (inputs and outputs).
  """
  def list_ports do
    Midiex.ports()
  end

  @doc """
  Lists available MIDI output ports.
  """
  def list_outputs do
    Midiex.ports(:output)
  end

  @doc """
  Lists available MIDI input ports.
  """
  def list_inputs do
    Midiex.ports(:input)
  end

  @doc """
  Lists configured port aliases.

  Returns a map of alias atoms to port name strings.

  ## Examples

      Waveform.MIDI.Port.list_aliases()
      #=> %{drums: "IAC Driver Bus 1", synth: "USB MIDI Device"}

  """
  def list_aliases do
    Application.get_env(:waveform, :midi_ports, %{})
  end

  @doc """
  Resolves a port alias to its full port name.

  If the input is already a string, returns it unchanged.
  If the input is an atom, looks up the alias in configuration.

  ## Examples

      Waveform.MIDI.Port.resolve_alias(:drums)
      #=> "IAC Driver Bus 1"

      Waveform.MIDI.Port.resolve_alias("IAC Driver Bus 1")
      #=> "IAC Driver Bus 1"

  """
  def resolve_alias(port_name) when is_binary(port_name), do: port_name

  def resolve_alias(alias_atom) when is_atom(alias_atom) do
    aliases = list_aliases()

    case Map.get(aliases, alias_atom) do
      nil -> {:error, {:unknown_alias, alias_atom, Map.keys(aliases)}}
      port_name -> port_name
    end
  end

  @doc """
  Gets or opens a connection to a named output port.

  Accepts either a port name string or a configured alias atom.
  Connections are cached, so subsequent calls with the same port
  return the existing connection.

  ## Examples

      # By full name
      {:ok, conn} = Waveform.MIDI.Port.get_output("IAC Driver Bus 1")

      # By alias (requires midi_ports config)
      {:ok, conn} = Waveform.MIDI.Port.get_output(:drums)

  """
  def get_output(port_name_or_alias) do
    case resolve_port_name(port_name_or_alias) do
      {:ok, port_name} ->
        GenServer.call(@me, {:get_output, port_name})

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Creates a virtual MIDI output port.

  This makes the Elixir application appear as a MIDI device that other
  applications can connect to. Not supported on Windows.

  ## Examples

      {:ok, conn} = Waveform.MIDI.Port.create_virtual_output("Waveform")

  """
  def create_virtual_output(name) do
    GenServer.call(@me, {:create_virtual_output, name})
  end

  @doc """
  Gets the default output connection.

  Uses the configured default port, or creates a virtual output named "Waveform"
  if no default is configured.
  """
  def get_default_output do
    GenServer.call(@me, :get_default_output)
  end

  @doc """
  Closes a connection by port name.
  """
  def close(port_name) do
    GenServer.call(@me, {:close, port_name})
  end

  @doc """
  Closes all open connections.
  """
  def close_all do
    GenServer.call(@me, :close_all)
  end

  # Server Implementation

  @impl true
  def init(_opts) do
    {:ok, %{connections: %{}}}
  end

  @impl true
  def handle_call({:get_output, port_name}, _from, state) do
    case Map.get(state.connections, port_name) do
      nil ->
        case open_output_port(port_name) do
          {:ok, conn} ->
            new_state = put_in(state.connections[port_name], conn)
            {:reply, {:ok, conn}, new_state}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end

      conn ->
        {:reply, {:ok, conn}, state}
    end
  end

  @impl true
  def handle_call({:create_virtual_output, name}, _from, state) do
    case Map.get(state.connections, {:virtual, name}) do
      nil ->
        case create_virtual(name) do
          {:ok, conn} ->
            new_state = put_in(state.connections[{:virtual, name}], conn)
            {:reply, {:ok, conn}, new_state}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end

      conn ->
        {:reply, {:ok, conn}, state}
    end
  end

  @impl true
  def handle_call(:get_default_output, _from, state) do
    default_port = Application.get_env(:waveform, :midi_port)
    {key, open_fn} = default_output_config(default_port)
    get_or_open_connection(state, key, open_fn)
  end

  @impl true
  def handle_call({:close, port_name}, _from, state) do
    case Map.pop(state.connections, port_name) do
      {nil, _} ->
        {:reply, :ok, state}

      {_conn, new_connections} ->
        # Midiex connections are cleaned up by the GC/NIF
        {:reply, :ok, %{state | connections: new_connections}}
    end
  end

  @impl true
  def handle_call(:close_all, _from, _state) do
    {:reply, :ok, %{connections: %{}}}
  end

  # Private helpers

  defp open_output_port(port_name) do
    outputs = Midiex.ports(:output)

    case Enum.find(outputs, fn port -> port.name == port_name end) do
      nil ->
        {:error, {:port_not_found, port_name, Enum.map(outputs, & &1.name)}}

      port ->
        conn = Midiex.open(port)
        {:ok, conn}
    end
  end

  defp create_virtual(name) do
    conn = Midiex.create_virtual_output(name)
    {:ok, conn}
  rescue
    e -> {:error, {:virtual_port_failed, e}}
  end

  defp default_output_config(nil),
    do: {{:virtual, "Waveform"}, fn -> create_virtual("Waveform") end}

  defp default_output_config(port_name), do: {port_name, fn -> open_output_port(port_name) end}

  defp get_or_open_connection(state, key, open_fn) do
    case Map.get(state.connections, key) do
      nil ->
        case open_fn.() do
          {:ok, conn} ->
            new_state = put_in(state.connections[key], conn)
            {:reply, {:ok, conn}, new_state}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end

      conn ->
        {:reply, {:ok, conn}, state}
    end
  end

  # Resolves port name or alias to a port name string
  defp resolve_port_name(port_name) when is_binary(port_name), do: {:ok, port_name}
  defp resolve_port_name(nil), do: {:ok, nil}

  defp resolve_port_name(alias_atom) when is_atom(alias_atom) do
    case resolve_alias(alias_atom) do
      {:error, _} = error -> error
      port_name -> {:ok, port_name}
    end
  end
end
