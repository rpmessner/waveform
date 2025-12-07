defmodule Waveform.MIDI.Input do
  @moduledoc """
  MIDI input handling for receiving messages from MIDI devices.

  Listens to MIDI input ports and dispatches parsed events to registered handlers.
  Can be used to play along with patterns, modulate parameters via CC, or record
  MIDI input into pattern format.

  ## Usage

      alias Waveform.MIDI.Input

      # List available input ports
      Input.list_ports()

      # Start listening to a port
      Input.listen("USB MIDI Keyboard")

      # Register a handler for note events
      Input.on_note(fn event ->
        IO.inspect(event)
        # %{type: :note_on, note: 60, velocity: 100, channel: 1}
      end)

      # Register a handler for CC events
      Input.on_cc(fn event ->
        IO.inspect(event)
        # %{type: :cc, cc: 1, value: 64, channel: 1}
      end)

      # Route MIDI input directly to SuperDirt
      Input.route_to_superdirt(sample: "piano")

      # Stop listening
      Input.stop()

  ## Event Types

  Events are maps with a `:type` key:

  - `%{type: :note_on, note: 0-127, velocity: 1-127, channel: 1-16}`
  - `%{type: :note_off, note: 0-127, velocity: 0, channel: 1-16}`
  - `%{type: :cc, cc: 0-127, value: 0-127, channel: 1-16}`
  - `%{type: :program_change, program: 0-127, channel: 1-16}`
  - `%{type: :pitch_bend, value: 0-16383, channel: 1-16}`
  - `%{type: :aftertouch, pressure: 0-127, channel: 1-16}`

  ## Configuration

      config :waveform,
        midi_input_port: "USB MIDI Keyboard",  # Default input port
        midi_input_channel: nil                 # nil = all channels, or 1-16

  """

  use GenServer
  require Logger
  import Bitwise

  @me __MODULE__

  # MIDI status byte ranges
  @note_off_min 0x80
  @note_off_max 0x8F
  @note_on_min 0x90
  @note_on_max 0x9F
  @aftertouch_min 0xA0
  @aftertouch_max 0xAF
  @cc_min 0xB0
  @cc_max 0xBF
  @program_change_min 0xC0
  @program_change_max 0xCF
  @channel_pressure_min 0xD0
  @channel_pressure_max 0xDF
  @pitch_bend_min 0xE0
  @pitch_bend_max 0xEF

  defmodule State do
    @moduledoc false
    defstruct [
      :listener_pid,
      :subscribed_ports,
      handlers: %{
        note: [],
        cc: [],
        program_change: [],
        pitch_bend: [],
        aftertouch: [],
        all: []
      },
      superdirt_routing: nil,
      channel_filter: nil
    ]
  end

  # Client API

  @doc """
  Starts the MIDI input handler.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(@me, opts, name: @me)
  end

  @doc """
  Lists available MIDI input ports.
  """
  def list_ports do
    Midiex.ports(:input)
  end

  @doc """
  Start listening to a MIDI input port.

  ## Parameters

  - `port_name` - Name of the port (string) or port struct from `list_ports/0`

  ## Examples

      Input.listen("USB MIDI Keyboard")
      Input.listen(hd(Input.list_ports()))

  """
  def listen(port_name) when is_binary(port_name) do
    GenServer.call(@me, {:listen, port_name})
  end

  def listen(%Midiex.MidiPort{} = port) do
    GenServer.call(@me, {:listen_port, port})
  end

  @doc """
  Start listening to all available MIDI input ports.
  """
  def listen_all do
    GenServer.call(@me, :listen_all)
  end

  @doc """
  Stop listening to MIDI input.
  """
  def stop do
    GenServer.call(@me, :stop)
  end

  @doc """
  Register a handler for note events (note_on and note_off).

  The handler receives a map with `:type`, `:note`, `:velocity`, and `:channel`.

  ## Examples

      Input.on_note(fn %{type: type, note: n, velocity: v} ->
        if type == :note_on do
          IO.puts("Note \#{n} on with velocity \#{v}")
        end
      end)

  """
  def on_note(handler) when is_function(handler, 1) do
    GenServer.call(@me, {:add_handler, :note, handler})
  end

  @doc """
  Register a handler for control change (CC) events.

  The handler receives a map with `:type`, `:cc`, `:value`, and `:channel`.

  ## Examples

      Input.on_cc(fn %{cc: cc, value: v} ->
        IO.puts("CC \#{cc} = \#{v}")
      end)

  """
  def on_cc(handler) when is_function(handler, 1) do
    GenServer.call(@me, {:add_handler, :cc, handler})
  end

  @doc """
  Register a handler for program change events.
  """
  def on_program_change(handler) when is_function(handler, 1) do
    GenServer.call(@me, {:add_handler, :program_change, handler})
  end

  @doc """
  Register a handler for pitch bend events.
  """
  def on_pitch_bend(handler) when is_function(handler, 1) do
    GenServer.call(@me, {:add_handler, :pitch_bend, handler})
  end

  @doc """
  Register a handler for all MIDI events.

  Useful for debugging or custom routing.
  """
  def on_all(handler) when is_function(handler, 1) do
    GenServer.call(@me, {:add_handler, :all, handler})
  end

  @doc """
  Clear all handlers of a specific type, or all handlers.

  ## Examples

      Input.clear_handlers(:note)   # Clear note handlers
      Input.clear_handlers(:all)    # Clear handlers registered with on_all
      Input.clear_handlers()        # Clear ALL handlers

  """
  def clear_handlers(type) when is_atom(type) do
    GenServer.call(@me, {:clear_handlers, type})
  end

  def clear_handlers do
    GenServer.call(@me, :clear_all_handlers)
  end

  @doc """
  Route MIDI note input directly to SuperDirt for playback.

  ## Options

  - `:sample` or `:s` - Sample name to trigger (default: "piano")
  - `:gain_scale` - Multiply velocity/127 by this (default: 1.0)
  - Any other SuperDirt parameters

  ## Examples

      # Play piano samples with incoming notes
      Input.route_to_superdirt(s: "piano")

      # Play with reduced volume
      Input.route_to_superdirt(s: "superpiano", gain_scale: 0.5)

      # Stop routing
      Input.stop_superdirt_routing()

  """
  def route_to_superdirt(opts \\ []) do
    GenServer.call(@me, {:route_to_superdirt, opts})
  end

  @doc """
  Stop routing MIDI input to SuperDirt.
  """
  def stop_superdirt_routing do
    GenServer.call(@me, :stop_superdirt_routing)
  end

  @doc """
  Set channel filter. Only events from this channel will be processed.

  ## Examples

      Input.set_channel_filter(1)   # Only channel 1
      Input.set_channel_filter(nil) # All channels (default)

  """
  def set_channel_filter(channel) when is_nil(channel) or (channel >= 1 and channel <= 16) do
    GenServer.call(@me, {:set_channel_filter, channel})
  end

  @doc """
  Check if currently listening to any ports.
  """
  def listening? do
    GenServer.call(@me, :listening?)
  end

  @doc """
  Get list of currently subscribed ports.
  """
  def subscribed_ports do
    GenServer.call(@me, :subscribed_ports)
  end

  # Server Implementation

  @impl true
  def init(_opts) do
    {:ok, %State{}}
  end

  @impl true
  def handle_call({:listen, port_name}, _from, state) do
    case find_input_port(port_name) do
      nil ->
        available = Enum.map(list_ports(), & &1.name)
        {:reply, {:error, {:port_not_found, port_name, available}}, state}

      port ->
        do_listen([port], state)
    end
  end

  @impl true
  def handle_call({:listen_port, port}, _from, state) do
    do_listen([port], state)
  end

  @impl true
  def handle_call(:listen_all, _from, state) do
    ports = list_ports()

    if Enum.empty?(ports) do
      {:reply, {:error, :no_input_ports}, state}
    else
      do_listen(ports, state)
    end
  end

  @impl true
  def handle_call(:stop, _from, state) do
    new_state = stop_listening(state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:add_handler, type, handler}, _from, state) do
    handlers = Map.update!(state.handlers, type, &[handler | &1])
    {:reply, :ok, %{state | handlers: handlers}}
  end

  @impl true
  def handle_call({:clear_handlers, type}, _from, state) do
    handlers = Map.put(state.handlers, type, [])
    {:reply, :ok, %{state | handlers: handlers}}
  end

  @impl true
  def handle_call(:clear_all_handlers, _from, state) do
    handlers = %{note: [], cc: [], program_change: [], pitch_bend: [], aftertouch: [], all: []}
    {:reply, :ok, %{state | handlers: handlers}}
  end

  @impl true
  def handle_call({:route_to_superdirt, opts}, _from, state) do
    {:reply, :ok, %{state | superdirt_routing: opts}}
  end

  @impl true
  def handle_call(:stop_superdirt_routing, _from, state) do
    {:reply, :ok, %{state | superdirt_routing: nil}}
  end

  @impl true
  def handle_call({:set_channel_filter, channel}, _from, state) do
    {:reply, :ok, %{state | channel_filter: channel}}
  end

  @impl true
  def handle_call(:listening?, _from, state) do
    {:reply, state.listener_pid != nil, state}
  end

  @impl true
  def handle_call(:subscribed_ports, _from, state) do
    {:reply, state.subscribed_ports || [], state}
  end

  # Handle MIDI messages from Midiex subscription
  @impl true
  def handle_info({:midi, _port, data, _timestamp}, state) do
    handle_midi_data(data, state)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, %{listener_pid: pid} = state) do
    Logger.warning("MIDI input listener process died, stopping")
    {:noreply, %{state | listener_pid: nil, subscribed_ports: nil}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Private helpers

  defp do_listen(ports, state) do
    # Stop existing listener if any
    state = stop_listening(state)

    try do
      # Subscribe this process to receive MIDI messages
      Midiex.subscribe(ports)

      port_names = Enum.map(ports, & &1.name)
      Logger.info("MIDI Input listening on: #{inspect(port_names)}")

      {:reply, :ok, %{state | subscribed_ports: ports}}
    rescue
      e ->
        {:reply, {:error, {:subscription_failed, e}}, state}
    end
  end

  defp stop_listening(state) do
    if state.subscribed_ports do
      try do
        Midiex.unsubscribe(state.subscribed_ports)
      rescue
        _ -> :ok
      end
    end

    %{state | listener_pid: nil, subscribed_ports: nil}
  end

  defp find_input_port(name) do
    Enum.find(list_ports(), fn port -> port.name == name end)
  end

  defp handle_midi_data(data, state) when is_list(data) do
    case parse_midi(data) do
      nil ->
        :ok

      event ->
        # Apply channel filter
        if passes_channel_filter?(event, state.channel_filter) do
          dispatch_event(event, state)
        end
    end
  end

  defp passes_channel_filter?(_event, nil), do: true
  defp passes_channel_filter?(%{channel: channel}, filter), do: channel == filter
  defp passes_channel_filter?(_event, _filter), do: true

  defp dispatch_event(event, state) do
    event
    |> handlers_for_event(state.handlers)
    |> Enum.concat(state.handlers.all)
    |> Enum.each(&safe_call_handler(&1, event))

    maybe_route_to_superdirt(event, state.superdirt_routing)
  end

  defp handlers_for_event(%{type: t}, handlers) when t in [:note_on, :note_off], do: handlers.note
  defp handlers_for_event(%{type: :cc}, handlers), do: handlers.cc
  defp handlers_for_event(%{type: :program_change}, handlers), do: handlers.program_change
  defp handlers_for_event(%{type: :pitch_bend}, handlers), do: handlers.pitch_bend
  defp handlers_for_event(%{type: :aftertouch}, handlers), do: handlers.aftertouch
  defp handlers_for_event(_event, _handlers), do: []

  defp safe_call_handler(handler, event) do
    handler.(event)
  rescue
    e -> Logger.error("MIDI handler error: #{inspect(e)}")
  end

  defp maybe_route_to_superdirt(%{type: :note_on} = event, opts) when not is_nil(opts) do
    route_note_to_superdirt(event, opts)
  end

  defp maybe_route_to_superdirt(_event, _opts), do: :ok

  defp route_note_to_superdirt(event, opts) do
    sample = opts[:s] || opts[:sample] || "piano"
    gain_scale = opts[:gain_scale] || 1.0
    gain = event.velocity / 127.0 * gain_scale

    # Merge user options with event data
    params =
      opts
      |> Keyword.drop([:sample, :gain_scale])
      |> Keyword.put(:s, sample)
      |> Keyword.put(:n, event.note)
      |> Keyword.put(:gain, gain)

    Waveform.SuperDirt.play(params)
  end

  # MIDI parsing

  defp parse_midi([status, data1, data2]) when status >= @note_off_min and status <= @note_off_max do
    %{
      type: :note_off,
      note: data1,
      velocity: data2,
      channel: (status - @note_off_min) + 1
    }
  end

  defp parse_midi([status, data1, data2]) when status >= @note_on_min and status <= @note_on_max do
    channel = (status - @note_on_min) + 1

    # Note on with velocity 0 is treated as note off
    if data2 == 0 do
      %{type: :note_off, note: data1, velocity: 0, channel: channel}
    else
      %{type: :note_on, note: data1, velocity: data2, channel: channel}
    end
  end

  defp parse_midi([status, data1, data2])
       when status >= @aftertouch_min and status <= @aftertouch_max do
    %{
      type: :aftertouch,
      note: data1,
      pressure: data2,
      channel: (status - @aftertouch_min) + 1
    }
  end

  defp parse_midi([status, data1, data2]) when status >= @cc_min and status <= @cc_max do
    %{
      type: :cc,
      cc: data1,
      value: data2,
      channel: (status - @cc_min) + 1
    }
  end

  defp parse_midi([status, data1])
       when status >= @program_change_min and status <= @program_change_max do
    %{
      type: :program_change,
      program: data1,
      channel: (status - @program_change_min) + 1
    }
  end

  defp parse_midi([status, data1])
       when status >= @channel_pressure_min and status <= @channel_pressure_max do
    %{
      type: :channel_pressure,
      pressure: data1,
      channel: (status - @channel_pressure_min) + 1
    }
  end

  defp parse_midi([status, lsb, msb]) when status >= @pitch_bend_min and status <= @pitch_bend_max do
    # Pitch bend is 14-bit value (0-16383, center at 8192)
    value = (msb <<< 7) ||| lsb

    %{
      type: :pitch_bend,
      value: value,
      channel: (status - @pitch_bend_min) + 1
    }
  end

  # System Real-Time Messages (single byte, no data)
  # These are used for MIDI clock synchronization
  defp parse_midi([0xF8]), do: %{type: :clock_tick}
  defp parse_midi([0xFA]), do: %{type: :start}
  defp parse_midi([0xFB]), do: %{type: :continue}
  defp parse_midi([0xFC]), do: %{type: :stop}
  defp parse_midi([0xFE]), do: %{type: :active_sensing}
  defp parse_midi([0xFF]), do: %{type: :reset}

  # Song Position Pointer (0xF2 + LSB + MSB)
  defp parse_midi([0xF2, lsb, msb]) do
    position = (msb <<< 7) ||| lsb
    %{type: :song_position, position: position}
  end

  # Song Select (0xF3 + song number)
  defp parse_midi([0xF3, song]), do: %{type: :song_select, song: song}

  # Unknown or other system messages
  defp parse_midi(_data), do: nil
end
