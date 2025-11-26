defmodule Mix.Tasks.Waveform.InstallSamples do
  @moduledoc """
  Install Dirt-Samples library for SuperDirt.

  ## Usage

      mix waveform.install_samples

  This task will:
  1. Check if Dirt-Samples is already installed
  2. Install Dirt-Samples via SuperCollider's Quarks system
  3. Verify the installation succeeded
  4. Provide next steps for configuration

  ## What are Dirt-Samples?

  Dirt-Samples is a large library of 217 sample banks (1800+ audio files) used by
  SuperDirt and TidalCycles. It includes drum machines (808, 909), percussion,
  synthesizers, and various musical instruments.

  ## Requirements

  - SuperCollider must be installed and running
  - Waveform application must be started
  - ~200MB of disk space
  - Internet connection for download

  ## After Installation

  **IMPORTANT:** Waveform is already configured to load Dirt-Samples automatically
  with the correct buffer settings (numBuffers = 4096). The samples will be
  available after installation completes.

  You may need to restart your application to ensure the samples load properly.

  ## Troubleshooting

  If samples don't load or you see "ERROR: No more buffer numbers":
  1. Check that numBuffers is set to at least 4096 (already configured in Waveform)
  2. Verify samples are installed at the correct path (this task will show it)
  3. Restart your Elixir application completely

  Run `mix waveform.doctor` to verify your SuperDirt setup.
  """
  use Mix.Task

  @shortdoc "Install Dirt-Samples library for SuperDirt"

  alias Waveform.Lang

  def run(_args) do
    # Start the application
    Mix.Task.run("app.start")

    IO.puts("""

    ╔═══════════════════════════════════════════════════════════╗
    ║          Dirt-Samples Installation for Waveform          ║
    ╚═══════════════════════════════════════════════════════════╝

    This will install 217 sample banks (1800+ audio files) for SuperDirt.
    Download size: ~200MB

    """)

    # Wait for server to be ready
    IO.puts("Waiting for SuperCollider server...")

    case wait_for_server_with_timeout(10_000) do
      :ok ->
        IO.puts("✓ SuperCollider server ready\n")
        proceed_with_installation()

      :timeout ->
        IO.puts("""
        ✗ SuperCollider server did not start in time.

        Make sure:
        1. SuperCollider is installed: mix waveform.doctor
        2. Your application is running
        3. No errors in the console

        Try running this command again.
        """)

        exit({:shutdown, 1})
    end
  end

  defp wait_for_server_with_timeout(timeout) do
    task =
      Task.async(fn ->
        Lang.wait_for_server()
      end)

    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, _} -> :ok
      nil -> :timeout
    end
  end

  defp proceed_with_installation do
    # Determine sample path
    sample_path = get_sample_path()

    # Check if already installed
    IO.puts("Checking installation status...")

    if samples_installed?(sample_path) do
      handle_already_installed(sample_path)
    else
      perform_installation(sample_path)
    end
  end

  defp get_sample_path do
    case :os.type() do
      {:unix, :darwin} ->
        Path.expand("~/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples")

      {:unix, _} ->
        Path.expand("~/.local/share/SuperCollider/downloaded-quarks/Dirt-Samples")

      {:win32, _} ->
        Path.expand("~/AppData/Local/SuperCollider/downloaded-quarks/Dirt-Samples")
    end
  end

  defp samples_installed?(sample_path) do
    File.dir?(sample_path) && count_wav_files(sample_path) > 1000
  end

  defp count_wav_files(path) do
    case File.ls(path) do
      {:ok, files} ->
        Enum.count(files, fn file ->
          dir_path = Path.join(path, file)
          File.dir?(dir_path) && has_wav_files?(dir_path)
        end)

      {:error, _} ->
        0
    end
  end

  defp has_wav_files?(dir) do
    case File.ls(dir) do
      {:ok, files} -> Enum.any?(files, &String.ends_with?(&1, ".wav"))
      {:error, _} -> false
    end
  end

  defp handle_already_installed(sample_path) do
    wav_count =
      Path.wildcard(Path.join([sample_path, "**", "*.wav"]))
      |> length()

    IO.puts("""

    ✓ Dirt-Samples is already installed!

    Location: #{sample_path}
    Files: #{wav_count} .wav files

    Your Waveform installation is configured to use these samples automatically.
    Buffer size is set to 4096 to accommodate all samples.

    Test your installation:
      mix waveform.check

    Run sample demos (ordered by complexity):
      mix run demos/01_basic_patterns.exs
      mix run demos/02_modular_composition.exs
      mix run demos/03_syncopated_rhythm.exs
      mix run demos/04_complex_harmony.exs
    """)
  end

  defp perform_installation(sample_path) do
    IO.puts("""

    Installing Dirt-Samples via SuperCollider's Quarks system...

    This will:
    1. Download ~200MB of audio samples
    2. Install to: #{sample_path}
    3. Make samples available to SuperDirt

    """)

    IO.write("Do you want to continue? [y/N]: ")
    response = IO.gets("") |> String.trim() |> String.downcase()

    if response == "y" do
      install_samples(sample_path)
    else
      IO.puts("\nInstallation cancelled.")
      exit({:shutdown, 0})
    end
  end

  defp install_samples(sample_path) do
    IO.puts("\nStarting installation...")
    IO.puts("(This may take several minutes depending on your connection)\n")

    # Install via Quarks with completion marker
    # We use a Routine to detect when the installation completes or fails
    Lang.send_command("""
    Routine({
      var success = false;
      try {
        Quarks.install("Dirt-Samples");
        // Wait a moment for files to finish writing
        2.wait;
        // Check if installation succeeded
        if(Quarks.isInstalled("Dirt-Samples"), {
          success = true;
          "#{Lang.marker_quarks_install_complete()}".postln;
        }, {
          "#{Lang.marker_quarks_install_failed()}".postln;
        });
      } {
        |err|
        "#{Lang.marker_quarks_install_failed()}".postln;
        err.postln;
      };
    }).play;
    """)

    IO.puts("Installation started. Waiting for download to complete...")

    # Wait for event-driven completion instead of polling
    case Lang.wait_for_quarks_installation(timeout: 600_000) do
      :ok ->
        count = count_wav_files(sample_path)
        installation_complete(count, sample_path)

      {:error, :installation_error} ->
        IO.puts("\n✗ Installation failed! SuperCollider reported an error.")
        IO.puts("Check the SuperCollider output above for details.")
        count = count_wav_files(sample_path)
        installation_timeout(count, sample_path)

      {:timeout, _} ->
        count = count_wav_files(sample_path)
        installation_timeout(count, sample_path)
    end
  end

  defp installation_complete(count, sample_path) do
    IO.puts("\n✓ Installation complete! Found #{count}+ sample files.")
    show_post_install_instructions(sample_path)
  end

  defp installation_timeout(count, sample_path) do
    IO.puts("""


    ⚠ Installation timeout or incomplete.

    Expected: 1800+ .wav files
    Found: #{count} files

    The installation may still be in progress. Check:
    1. SuperCollider console for download progress
    2. #{sample_path}
    3. Your internet connection

    You can run this command again to retry.
    """)

    {:halt, count}
  end

  defp show_post_install_instructions(sample_path) do
    IO.puts("""


    ╔═══════════════════════════════════════════════════════════╗
    ║              Installation Successful!                     ║
    ╚═══════════════════════════════════════════════════════════╝

    Dirt-Samples installed to:
      #{sample_path}

    ✓ Waveform is already configured to use these samples
    ✓ Buffer size set to 4096 (required for all samples)
    ✓ Sample path configured automatically

    Next steps:

    1. Restart your application (if running in IEx):
       iex> :init.restart()

    2. Test your installation:
       mix waveform.check

    3. Try the music demos (ordered by complexity):
       mix run demos/01_basic_patterns.exs
       mix run demos/02_modular_composition.exs
       mix run demos/03_syncopated_rhythm.exs
       mix run demos/04_complex_harmony.exs

    4. Verify everything works:
       mix waveform.doctor

    Troubleshooting:
    - If you see "ERROR: No more buffer numbers", restart your application
    - If samples don't play, check the path above exists
    - For more help: https://github.com/rpmessner/waveform#troubleshooting

    """)
  end
end
