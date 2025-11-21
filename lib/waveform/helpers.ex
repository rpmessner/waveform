defmodule Waveform.Helpers do
  @moduledoc """
  Helper functions for working with Waveform and SuperDirt.
  """

  alias Waveform.Lang

  @doc """
  Ensure SuperDirt is started and ready.

  If SuperDirt is already running, this returns immediately.
  Otherwise, it starts SuperDirt and waits for it to load all samples.

  This function blocks until SuperDirt is fully initialized by monitoring
  stdout from the SuperCollider process, eliminating the need for arbitrary
  sleep times.

  ## Options

  - `:timeout` - Maximum time to wait in milliseconds (default: 60000)

  ## Examples

      Helpers.ensure_superdirt_ready()
      Helpers.ensure_superdirt_ready(timeout: 30000)
  """
  def ensure_superdirt_ready(opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 60_000)

    # Wait for server first
    Lang.wait_for_server()

    # Check if SuperDirt is already running
    Lang.send_command(~S"""
    if(~dirt.notNil, { "SUPERDIRT_READY".postln; });
    """)

    # Give it a moment to respond if it's already running
    Process.sleep(100)

    # Try to wait for SuperDirt (will return immediately if already ready)
    case Lang.wait_for_superdirt(timeout: 500) do
      :ok ->
        # Already running
        :ok

      {:timeout, _} ->
        # Not running yet, start it
        start_superdirt(timeout)
    end
  end

  defp start_superdirt(timeout) do
    # Determine sample path based on platform
    sample_path =
      case :os.type() do
        {:unix, :darwin} ->
          "/Users/#{System.get_env("USER")}/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples"

        {:unix, _} ->
          "#{System.get_env("HOME")}/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples"

        {:win32, _} ->
          # Windows path - adjust as needed
          "C:/Users/#{System.get_env("USERNAME")}/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples"
      end

    # Start SuperDirt - it will print "SuperDirt: listening to Tidal on port 57120"
    # when ready, which we monitor in handle_info to detect readiness
    Lang.send_command("""
    fork {
      ~dirt = SuperDirt(2, s);
      ~dirt.loadSoundFiles("#{sample_path}/*");
      ~dirt.start(57120, [0, 0]);
    };
    """)

    # Wait for SuperDirt to finish loading
    # This monitors stdout for "SuperDirt: listening to Tidal on port" message
    Lang.wait_for_superdirt(timeout: timeout)
  end
end
