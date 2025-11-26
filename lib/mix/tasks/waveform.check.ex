defmodule Mix.Tasks.Waveform.Check do
  @moduledoc """
  Tests SuperDirt functionality by playing sample sounds.

  This task verifies that:
  - SuperDirt is installed and running
  - Buffer configuration is correct (4096 buffers)
  - Dirt-Samples are loaded properly
  - Sample playback works

  ## Usage

      mix waveform.check

  You should hear four sounds in sequence: kick, snare, hi-hat, and clap.
  If you don't hear all sounds, the task will provide troubleshooting guidance.

  ## Prerequisites

  Before running this task:
  1. SuperCollider must be installed
  2. SuperDirt Quark must be installed
  3. Dirt-Samples should be installed (run `mix waveform.install_samples`)

  """
  @shortdoc "Tests SuperDirt by playing sample sounds"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("""
    🔊 SuperDirt Verification
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Testing SuperDirt with multiple samples to verify:
      ✓ SuperDirt is installed
      ✓ Buffer configuration is correct (4096 buffers)
      ✓ Dirt-Samples are loaded
      ✓ Sample playback works

    """)

    # Start the application
    Mix.shell().info("Starting Waveform application...")
    Mix.Task.run("app.start")

    # Ensure SuperDirt is ready
    Mix.shell().info("Starting SuperDirt with Dirt-Samples...")

    case ensure_superdirt_ready() do
      :ok ->
        Mix.shell().info("✓ SuperDirt ready!\n")
        run_sample_tests()

      {:error, reason} ->
        Mix.shell().error("✗ Failed to start SuperDirt: #{reason}")
        Mix.shell().info("\nTroubleshooting:")
        Mix.shell().info("  1. Run: mix waveform.doctor")
        Mix.shell().info("  2. Ensure SuperDirt is installed in SuperCollider")
        Mix.shell().info("  3. Check for errors in the output above")
    end
  end

  defp ensure_superdirt_ready do
    Waveform.Helpers.ensure_superdirt_ready()
    :ok
  rescue
    e ->
      {:error, Exception.message(e)}
  end

  defp run_sample_tests do
    Mix.shell().info("Testing sample playback...")
    Mix.shell().info("You should hear: kick, snare, hi-hat, clap\n")

    samples = [
      {"bd", "Kick drum"},
      {"sn", "Snare"},
      {"hh", "Hi-hat"},
      {"cp", "Clap"}
    ]

    for {sample, name} <- samples do
      Mix.shell().info("  Playing #{name}...")

      try do
        Waveform.SuperDirt.play(s: sample, n: 0, gain: 0.8)
        Process.sleep(700)
      rescue
        e ->
          Mix.shell().error("    ✗ Failed to play #{name}: #{Exception.message(e)}")
      end
    end

    print_results()
  end

  defp print_results do
    Mix.shell().info("""

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✓ Test complete!

    Did you hear all four sounds?
      YES: ✓ SuperDirt is working perfectly!
           - Buffer configuration is correct
           - All Dirt-Samples are loaded
           - Ready to run demos and create music

      NO:  ✗ There may be an issue:
           - If you only heard kick: Buffer limit might be too low
             → Check lib/waveform/lang.ex has numBuffers = 4096
             → Restart your application: :init.restart()

           - If you heard nothing: SuperDirt might not be running
             → Run: mix waveform.doctor
             → Check for errors in the output above

           - If you heard some but not all:
             → Run: mix waveform.install_samples
             → Verify samples installed correctly

    For more help: https://github.com/rpmessner/waveform#troubleshooting
    """)
  end
end
