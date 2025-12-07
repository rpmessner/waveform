# Suppress info logs to reduce test output noise
Logger.configure(level: :error)

# Start GenServers needed for tests
# These will call OSC.send_command which will fail silently since OSC isn't running
# but the state management will work correctly

defmodule Waveform.TestSupport do
  @moduledoc false

  def start_test_servers do
    # Start servers that tests depend on
    # Order matters - some depend on others
    servers = [
      {Waveform.Buffer, []},
      {Waveform.MIDI.Input, []},
      {Waveform.MIDI.Clock, []},
      {Waveform.MIDI.Port, []}
    ]

    for {mod, opts} <- servers do
      case mod.start_link(opts) do
        {:ok, pid} -> {:ok, pid}
        {:error, {:already_started, pid}} -> {:ok, pid}
        error -> error
      end
    end
  end
end

# Start test servers
Waveform.TestSupport.start_test_servers()

ExUnit.start()
ExUnit.configure(colors: [enabled: true])
