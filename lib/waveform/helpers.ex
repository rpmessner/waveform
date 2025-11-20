defmodule Waveform.Helpers do
  @moduledoc """
  Helper functions for working with Waveform and SuperDirt.
  """

  alias Waveform.Lang

  @doc """
  Ensure SuperDirt is started and ready.

  If SuperDirt is already running, this returns immediately.
  Otherwise, it starts SuperDirt and waits for it to load.
  """
  def ensure_superdirt_ready do
    # Wait for server first
    Lang.wait_for_server()

    # Pre-checks - these give SuperDirt more time to initialize
    Lang.send_command(~S"""
    if(SuperDirt.class.notNil, { "SUPERDIRT_CLASS_EXISTS".postln; }, { "SUPERDIRT_CLASS_NOT_FOUND".postln; });
    """)

    Process.sleep(1000)

    Lang.send_command(~S"""
    if(~dirt.notNil, { "DIRT_IS_RUNNING".postln; }, { "DIRT_NOT_RUNNING".postln; });
    """)

    Process.sleep(1000)

    # Determine sample path based on platform
    sample_path =
      case :os.type() do
        {:unix, :darwin} ->
          "/Users/#{System.get_env("USER")}/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples"

        {:unix, _} ->
          "/Users/#{System.get_env("USER")}/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples"

        {:win32, _} ->
          # Windows path - adjust as needed
          "C:/Users/#{System.get_env("USERNAME")}/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples"
      end

    # Start SuperDirt with explicit sample path
    # Use the same pattern that works for BD, but with explicit path
    Lang.send_command("""
    ~dirt = SuperDirt(2, s); ~dirt.loadSoundFiles("#{sample_path}/*"); ~dirt.start(57120, [0, 0]); "SUPERDIRT_STARTED".postln;
    """)

    # Wait for samples to load (1800+ files takes time)
    Process.sleep(15_000)

    # Verify SuperDirt is running
    Lang.send_command(~S"""
    if(~dirt.notNil, { "DIRT_NOW_RUNNING".postln; }, { "DIRT_STILL_NOT_RUNNING".postln; });
    """)

    Process.sleep(1000)

    :ok
  end
end
