defmodule Waveform.Buffer do
  @moduledoc """
  Buffer management for loading and managing audio samples in SuperCollider.

  Buffers are server-side memory allocations that hold audio data. They can be
  loaded from sound files and used with synths for sample playback.

  ## Usage Patterns

  There are two main ways to work with samples in Waveform:

  1. **SuperDirt** (recommended for pattern-based music):
     SuperDirt manages its own buffers via `loadSoundFiles`. Use `SuperDirt.play(s: "bd")`
     to trigger samples. This is the TidalCycles-compatible approach.

  2. **Direct Buffer Loading** (for custom synths):
     Use this module to load samples and play them with your own synth definitions.
     This gives you more control but requires writing SuperCollider synth code.

  ## Examples

      alias Waveform.Buffer

      # Load a sample file
      {:ok, buf_num} = Buffer.read("/path/to/kick.wav")

      # Load with options
      {:ok, buf_num} = Buffer.read("/path/to/long_sample.wav",
        start_frame: 44100,   # Start 1 second in (at 44.1kHz)
        num_frames: 88200     # Load 2 seconds
      )

      # Query buffer info
      {:ok, info} = Buffer.query(buf_num)
      # => %{num_frames: 88200, num_channels: 2, sample_rate: 44100.0}

      # Free a buffer when done
      Buffer.free(buf_num)

      # Free all buffers
      Buffer.free_all()

  ## Playing Buffers with Synths

  To play a loaded buffer, you need a synth definition that uses `PlayBuf` or similar.
  Define in SuperCollider:

      SynthDef(\\playbuf, { |out=0, bufnum, rate=1, amp=0.5|
        var sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate, doneAction: 2);
        Out.ar(out, sig * amp);
      }).add;

  Then in Elixir:

      {:ok, buf} = Buffer.read("/path/to/sample.wav")
      Waveform.Synth.new("playbuf", bufnum: buf, rate: 1.0, amp: 0.8)

  ## Buffer Numbers

  Buffer numbers are managed automatically. The module tracks allocated buffers
  and assigns sequential numbers starting from a configurable offset (default: 1000)
  to avoid conflicts with SuperDirt's buffers.

  ## Configuration

      config :waveform,
        buffer_start_index: 1000  # Starting buffer number (default: 1000)

  """

  use GenServer
  require Logger

  alias Waveform.OSC

  @me __MODULE__

  # OSC commands for buffer operations
  @b_alloc_read ~c"/b_allocRead"
  @b_alloc_read_channel ~c"/b_allocReadChannel"
  @b_alloc ~c"/b_alloc"
  @b_free ~c"/b_free"
  @b_query ~c"/b_query"
  @b_zero ~c"/b_zero"

  defmodule State do
    @moduledoc false
    defstruct [
      :next_buffer_num,
      # Map of buffer_num -> %{path: ..., loaded_at: ...}
      buffers: %{},
      # Map of buffer_num -> from (for pending queries)
      pending_queries: %{}
    ]
  end

  # Client API

  @doc """
  Starts the Buffer manager.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(@me, opts, name: @me)
  end

  @doc """
  Load a sound file into a new buffer.

  Allocates a buffer and reads the entire sound file into it.
  Returns the buffer number which can be used with synths.

  ## Options

  - `:start_frame` - Starting frame to read from (default: 0)
  - `:num_frames` - Number of frames to read (default: 0 = entire file)
  - `:channels` - List of channel indices to read (default: all channels)

  ## Examples

      # Load entire file
      {:ok, buf_num} = Buffer.read("/path/to/sample.wav")

      # Load portion of file
      {:ok, buf_num} = Buffer.read("/path/to/sample.wav",
        start_frame: 44100,
        num_frames: 88200
      )

      # Load only left channel
      {:ok, buf_num} = Buffer.read("/path/to/stereo.wav", channels: [0])

  """
  def read(path, opts \\ []) do
    GenServer.call(@me, {:read, path, opts})
  end

  @doc """
  Allocate an empty buffer.

  Creates a zero-filled buffer with the specified number of frames and channels.
  Useful for recording or generating audio programmatically.

  ## Examples

      # Allocate 2 seconds of stereo audio at 44.1kHz
      {:ok, buf_num} = Buffer.allocate(88200, 2)

  """
  def allocate(num_frames, num_channels \\ 1) do
    GenServer.call(@me, {:allocate, num_frames, num_channels})
  end

  @doc """
  Free a buffer, releasing its memory on the server.

  ## Examples

      Buffer.free(buf_num)

  """
  def free(buffer_num) do
    GenServer.call(@me, {:free, buffer_num})
  end

  @doc """
  Free all buffers managed by this module.

  Does not affect buffers allocated by SuperDirt or other sources.

  ## Examples

      Buffer.free_all()

  """
  def free_all do
    GenServer.call(@me, :free_all)
  end

  @doc """
  Zero out a buffer's contents without deallocating it.

  ## Examples

      Buffer.zero(buf_num)

  """
  def zero(buffer_num) do
    GenServer.call(@me, {:zero, buffer_num})
  end

  @doc """
  List all buffer numbers currently managed by this module.

  ## Examples

      Buffer.list()
      #=> [1000, 1001, 1002]

  """
  def list do
    GenServer.call(@me, :list)
  end

  @doc """
  Get information about a buffer.

  Note: This is a synchronous query that waits for the server response.
  The timeout is 5 seconds.

  ## Examples

      {:ok, info} = Buffer.query(buf_num)
      # => %{buffer_num: 1000, num_frames: 88200, num_channels: 2, sample_rate: 44100.0}

  """
  def query(buffer_num) do
    GenServer.call(@me, {:query, buffer_num}, 5000)
  end

  # Server Implementation

  @impl true
  def init(opts) do
    start_index = Keyword.get(opts, :start_index) ||
                  Application.get_env(:waveform, :buffer_start_index, 1000)

    state = %State{
      next_buffer_num: start_index,
      buffers: %{},
      pending_queries: %{}
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:read, path, opts}, _from, state) do
    buffer_num = state.next_buffer_num
    start_frame = Keyword.get(opts, :start_frame, 0)
    num_frames = Keyword.get(opts, :num_frames, 0)
    channels = Keyword.get(opts, :channels)

    # Send appropriate OSC command
    if channels do
      # Read specific channels
      args = [buffer_num, to_charlist(path), start_frame, num_frames | channels]
      OSC.send_command([@b_alloc_read_channel | args])
    else
      # Read all channels
      OSC.send_command([@b_alloc_read, buffer_num, to_charlist(path), start_frame, num_frames])
    end

    # Track the buffer
    buffer_info = %{
      path: path,
      loaded_at: System.system_time(:second)
    }

    new_state = %{state |
      next_buffer_num: buffer_num + 1,
      buffers: Map.put(state.buffers, buffer_num, buffer_info)
    }

    {:reply, {:ok, buffer_num}, new_state}
  end

  @impl true
  def handle_call({:allocate, num_frames, num_channels}, _from, state) do
    buffer_num = state.next_buffer_num

    OSC.send_command([@b_alloc, buffer_num, num_frames, num_channels])

    buffer_info = %{
      allocated: true,
      num_frames: num_frames,
      num_channels: num_channels,
      loaded_at: System.system_time(:second)
    }

    new_state = %{state |
      next_buffer_num: buffer_num + 1,
      buffers: Map.put(state.buffers, buffer_num, buffer_info)
    }

    {:reply, {:ok, buffer_num}, new_state}
  end

  @impl true
  def handle_call({:free, buffer_num}, _from, state) do
    if Map.has_key?(state.buffers, buffer_num) do
      OSC.send_command([@b_free, buffer_num])
      new_state = %{state | buffers: Map.delete(state.buffers, buffer_num)}
      {:reply, :ok, new_state}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_call(:free_all, _from, state) do
    # Free all tracked buffers
    Enum.each(state.buffers, fn {buffer_num, _info} ->
      OSC.send_command([@b_free, buffer_num])
    end)

    new_state = %{state | buffers: %{}}
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:zero, buffer_num}, _from, state) do
    if Map.has_key?(state.buffers, buffer_num) do
      OSC.send_command([@b_zero, buffer_num])
      {:reply, :ok, state}
    else
      {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_call(:list, _from, state) do
    buffer_nums = Map.keys(state.buffers) |> Enum.sort()
    {:reply, buffer_nums, state}
  end

  @impl true
  def handle_call({:query, buffer_num}, from, state) do
    OSC.send_command([@b_query, buffer_num])

    # Store the caller so we can reply when we get the response
    new_state = %{state | pending_queries: Map.put(state.pending_queries, buffer_num, from)}
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:buffer_info, buffer_num, num_frames, num_channels, sample_rate}, state) do
    # Handle buffer query response
    case Map.pop(state.pending_queries, buffer_num) do
      {nil, _} ->
        # No pending query for this buffer
        {:noreply, state}

      {from, new_pending} ->
        info = %{
          buffer_num: buffer_num,
          num_frames: num_frames,
          num_channels: num_channels,
          sample_rate: sample_rate
        }

        GenServer.reply(from, {:ok, info})
        {:noreply, %{state | pending_queries: new_pending}}
    end
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
