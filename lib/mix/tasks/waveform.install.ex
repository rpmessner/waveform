defmodule Mix.Tasks.Waveform.Install do
  @moduledoc """
  Automatically installs SuperCollider and SuperDirt for your platform.

  This task will:
  1. Detect your operating system and package manager
  2. Install SuperCollider (if not already installed)
  3. Install the SuperDirt Quark
  4. Verify the installation

  ## Usage

      mix waveform.install

  ## Options

      --skip-sc          Skip SuperCollider installation (only install SuperDirt)
      --skip-superdirt   Skip SuperDirt installation (only install SuperCollider)
      --force            Reinstall even if already installed

  ## Supported Platforms

  - **macOS**: Uses Homebrew
  - **Linux**: Supports apt (Debian/Ubuntu), pacman (Arch), dnf (Fedora), zypper (openSUSE)
  - **Windows**: Provides download instructions (manual installation required)

  """
  @shortdoc "Install SuperCollider and SuperDirt"

  use Mix.Task
  require Logger

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [skip_sc: :boolean, skip_superdirt: :boolean, force: :boolean],
        aliases: []
      )

    Mix.shell().info("""

    ╔═══════════════════════════════════════════════════════════╗
    ║  Waveform Installation Wizard                             ║
    ╚═══════════════════════════════════════════════════════════╝

    This will install:
      #{if opts[:skip_sc], do: "⊘", else: "✓"} SuperCollider (audio synthesis platform)
      #{if opts[:skip_superdirt], do: "⊘", else: "✓"} SuperDirt (TidalCycles-compatible sampler)

    """)

    # Step 1: Install SuperCollider
    sc_result =
      if opts[:skip_sc] do
        Mix.shell().info("Skipping SuperCollider installation...\n")
        :ok
      else
        install_supercollider(opts[:force])
      end

    # Step 2: Install SuperDirt
    sd_result =
      if opts[:skip_superdirt] || sc_result == :error do
        if sc_result == :error do
          Mix.shell().error("Skipping SuperDirt installation due to SuperCollider error\n")
        else
          Mix.shell().info("Skipping SuperDirt installation...\n")
        end

        :ok
      else
        install_superdirt(opts[:force])
      end

    # Final summary
    print_summary(sc_result, sd_result, opts)
  end

  # --- SuperCollider Installation ---

  defp install_supercollider(force) do
    Mix.shell().info("━━━ Installing SuperCollider ━━━\n")

    if !force && supercollider_installed?() do
      Mix.shell().info([:green, "✓ SuperCollider is already installed", :reset])
      Mix.shell().info("  Use --force to reinstall\n")
      :ok
    else
      platform = detect_platform()
      install_sc_for_platform(platform)
    end
  end

  defp supercollider_installed? do
    sclang_path = get_sclang_path()

    cond do
      File.exists?(sclang_path) -> true
      System.find_executable("sclang") -> true
      true -> false
    end
  end

  defp install_sc_for_platform({:macos, :homebrew}) do
    Mix.shell().info("Platform: macOS (using Homebrew)\n")

    case run_command("brew", ["install", "supercollider"]) do
      {_, 0} ->
        Mix.shell().info([:green, "\n✓ SuperCollider installed successfully", :reset])
        :ok

      {output, code} ->
        Mix.shell().error("\n✗ Installation failed (exit code: #{code})")
        Mix.shell().info("Output: #{output}")
        :error
    end
  end

  defp install_sc_for_platform({:linux, :apt}) do
    Mix.shell().info("Platform: Linux (using apt)\n")

    Mix.shell().info("Running: sudo apt-get update && sudo apt-get install -y supercollider")

    case run_command("sudo", ["apt-get", "update"]) do
      {_, 0} ->
        case run_command("sudo", ["apt-get", "install", "-y", "supercollider"]) do
          {_, 0} ->
            Mix.shell().info([:green, "\n✓ SuperCollider installed successfully", :reset])
            :ok

          {output, code} ->
            Mix.shell().error("\n✗ Installation failed (exit code: #{code})")
            Mix.shell().info("Output: #{output}")
            :error
        end

      {output, code} ->
        Mix.shell().error("\n✗ apt-get update failed (exit code: #{code})")
        Mix.shell().info("Output: #{output}")
        :error
    end
  end

  defp install_sc_for_platform({:linux, :pacman}) do
    Mix.shell().info("Platform: Linux (using pacman)\n")

    Mix.shell().info("Running: sudo pacman -Sy --noconfirm supercollider")

    case run_command("sudo", ["pacman", "-Sy", "--noconfirm", "supercollider"]) do
      {_, 0} ->
        Mix.shell().info([:green, "\n✓ SuperCollider installed successfully", :reset])
        :ok

      {output, code} ->
        Mix.shell().error("\n✗ Installation failed (exit code: #{code})")
        Mix.shell().info("Output: #{output}")
        :error
    end
  end

  defp install_sc_for_platform({:linux, :dnf}) do
    Mix.shell().info("Platform: Linux (using dnf)\n")

    Mix.shell().info("Running: sudo dnf install -y supercollider")

    case run_command("sudo", ["dnf", "install", "-y", "supercollider"]) do
      {_, 0} ->
        Mix.shell().info([:green, "\n✓ SuperCollider installed successfully", :reset])
        :ok

      {output, code} ->
        Mix.shell().error("\n✗ Installation failed (exit code: #{code})")
        Mix.shell().info("Output: #{output}")
        :error
    end
  end

  defp install_sc_for_platform({:linux, :zypper}) do
    Mix.shell().info("Platform: Linux (using zypper)\n")

    Mix.shell().info("Running: sudo zypper install -y supercollider")

    case run_command("sudo", ["zypper", "install", "-y", "supercollider"]) do
      {_, 0} ->
        Mix.shell().info([:green, "\n✓ SuperCollider installed successfully", :reset])
        :ok

      {output, code} ->
        Mix.shell().error("\n✗ Installation failed (exit code: #{code})")
        Mix.shell().info("Output: #{output}")
        :error
    end
  end

  defp install_sc_for_platform({:windows, _}) do
    Mix.shell().info("Platform: Windows\n")

    Mix.shell().info("""
    ⚠ Automatic installation is not available for Windows.

    Please install SuperCollider manually:

    1. Download from: https://supercollider.github.io/download
    2. Run the installer
    3. Run: mix waveform.install --skip-sc

    """)

    :manual
  end

  defp install_sc_for_platform({:macos, :no_homebrew}) do
    Mix.shell().error("""
    ✗ Homebrew not found on macOS.

    Please install Homebrew first:
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    Then run: mix waveform.install

    Alternatively, download SuperCollider manually:
      https://supercollider.github.io/download

    """)

    :error
  end

  defp install_sc_for_platform(:unknown) do
    Mix.shell().error("""
    ✗ Could not detect your platform or package manager.

    Please install SuperCollider manually:
      https://supercollider.github.io/download

    Then run: mix waveform.install --skip-sc

    """)

    :error
  end

  # --- SuperDirt Installation ---

  defp install_superdirt(force) do
    Mix.shell().info("\n━━━ Installing SuperDirt ━━━\n")

    if !force && superdirt_installed?() do
      Mix.shell().info([:green, "✓ SuperDirt is already installed", :reset])
      Mix.shell().info("  Use --force to reinstall\n")
      :ok
    else
      sclang_path = get_sclang_path()
      path = if File.exists?(sclang_path), do: sclang_path, else: System.find_executable("sclang")

      if is_nil(path) || !File.exists?(path) do
        Mix.shell().error("""
        ✗ Could not find sclang executable.

        SuperCollider must be installed first.
        Run: mix waveform.install (without --skip-sc)

        """)

        :error
      else
        install_superdirt_via_sclang(path)
      end
    end
  end

  defp superdirt_installed? do
    sclang_path = get_sclang_path()
    path = if File.exists?(sclang_path), do: sclang_path, else: System.find_executable("sclang")

    if is_nil(path) || !File.exists?(path) do
      false
    else
      command =
        "SuperDirt.class.notNil.if({ \"SUPERDIRT_INSTALLED\".postln }, { \"SUPERDIRT_NOT_INSTALLED\".postln }); 0.exit;"

      case run_sclang_code(path, command) do
        {output, _} ->
          String.contains?(output, "SUPERDIRT_INSTALLED")
      end
    end
  rescue
    _ -> false
  end

  # Helper to run SuperCollider code via a temp file
  defp run_sclang_code(sclang_path, code) do
    # Create a temporary file
    temp_file =
      Path.join(System.tmp_dir!(), "waveform_install_#{:erlang.unique_integer([:positive])}.scd")

    try do
      # Write code to temp file
      File.write!(temp_file, code)

      # Execute sclang with the temp file
      # Note: SuperDirt installation can take a while, so we use a long timeout
      System.cmd(sclang_path, [temp_file], stderr_to_stdout: true)
    after
      # Clean up temp file
      File.rm(temp_file)
    end
  rescue
    error ->
      {"Error executing sclang code: #{inspect(error)}", 1}
  end

  defp install_superdirt_via_sclang(sclang_path) do
    Mix.shell().info("Installing SuperDirt Quark via sclang...")
    Mix.shell().info("This may take a few minutes as it downloads samples...\n")

    install_command = """
    Quarks.install("SuperDirt");
    "SUPERDIRT_QUARK_INSTALLED".postln;
    0.exit;
    """

    case run_sclang_code(sclang_path, install_command) do
      {output, _} -> handle_superdirt_quark_install(output, sclang_path)
    end
  rescue
    error ->
      Mix.shell().error("\n✗ Exception during SuperDirt installation: #{inspect(error)}")
      :error
  end

  defp handle_superdirt_quark_install(output, sclang_path) do
    if String.contains?(output, "SUPERDIRT_QUARK_INSTALLED") ||
         String.contains?(output, "already installed") do
      Mix.shell().info([:green, "✓ SuperDirt Quark installed", :reset])
      recompile_and_verify(sclang_path)
    else
      Mix.shell().error("\n✗ SuperDirt Quark installation failed")
      Mix.shell().info("Output: #{output}")
      :error
    end
  end

  defp recompile_and_verify(sclang_path) do
    Mix.shell().info("\nRecompiling SuperCollider class library...")

    recompile_command = """
    thisProcess.recompile;
    "RECOMPILE_COMPLETE".postln;
    2.wait;
    0.exit;
    """

    case run_sclang_code(sclang_path, recompile_command) do
      {recompile_output, _} -> verify_recompile_and_installation(recompile_output)
    end
  end

  defp verify_recompile_and_installation(recompile_output) do
    if String.contains?(recompile_output, "RECOMPILE_COMPLETE") ||
         String.contains?(recompile_output, "compile done") do
      Mix.shell().info([:green, "✓ Class library recompiled", :reset])

      if superdirt_installed?() do
        Mix.shell().info([:green, "\n✓ SuperDirt installed successfully!", :reset])
        :ok
      else
        Mix.shell().error("\n✗ SuperDirt installation could not be verified")
        Mix.shell().info("Try running: mix waveform.doctor")
        :error
      end
    else
      Mix.shell().error("\n✗ Class library recompilation failed")
      Mix.shell().info("Output: #{recompile_output}")
      :error
    end
  end

  # --- Platform Detection ---

  defp detect_platform do
    case :os.type() do
      {:unix, :darwin} ->
        if System.find_executable("brew") do
          {:macos, :homebrew}
        else
          {:macos, :no_homebrew}
        end

      {:unix, _} ->
        detect_linux_package_manager()

      {:win32, _} ->
        {:windows, nil}
    end
  end

  defp detect_linux_package_manager do
    cond do
      System.find_executable("apt-get") -> {:linux, :apt}
      System.find_executable("pacman") -> {:linux, :pacman}
      System.find_executable("dnf") -> {:linux, :dnf}
      System.find_executable("zypper") -> {:linux, :zypper}
      true -> :unknown
    end
  end

  # --- Helpers ---

  defp get_sclang_path do
    System.get_env("SCLANG_PATH") || default_sclang_path()
  end

  defp default_sclang_path do
    case :os.type() do
      {:unix, :darwin} ->
        "/Applications/SuperCollider.app/Contents/MacOS/sclang"

      {:unix, _} ->
        Enum.find(["/usr/bin/sclang", "/usr/local/bin/sclang"], &File.exists?/1) ||
          "/usr/bin/sclang"

      {:win32, _} ->
        Enum.find(
          [
            "C:\\Program Files\\SuperCollider\\sclang.exe",
            "C:\\Program Files (x86)\\SuperCollider\\sclang.exe"
          ],
          &File.exists?/1
        ) || "C:\\Program Files\\SuperCollider\\sclang.exe"
    end
  end

  defp run_command(cmd, args) do
    Mix.shell().info("$ #{cmd} #{Enum.join(args, " ")}")

    System.cmd(cmd, args, stderr_to_stdout: true, into: IO.stream(:stdio, :line))
  rescue
    error ->
      {"Command failed: #{inspect(error)}", 1}
  end

  defp print_summary(sc_result, sd_result, opts) do
    print_summary_header()
    print_sc_result(sc_result, opts)
    print_sd_result(sd_result, opts)
    print_summary_footer(sc_result, sd_result)
  end

  defp print_summary_header do
    Mix.shell().info("\n")
    Mix.shell().info(String.duplicate("═", 60))
    Mix.shell().info("Installation Summary")
    Mix.shell().info(String.duplicate("═", 60))
  end

  defp print_sc_result(result, opts) do
    unless opts[:skip_sc] do
      case result do
        :ok ->
          Mix.shell().info([:green, "✓ SuperCollider: Installed", :reset])

        :manual ->
          Mix.shell().info([:yellow, "⊘ SuperCollider: Manual installation required", :reset])

        :error ->
          Mix.shell().error("✗ SuperCollider: Installation failed")
      end
    end
  end

  defp print_sd_result(result, opts) do
    unless opts[:skip_superdirt] do
      case result do
        :ok -> Mix.shell().info([:green, "✓ SuperDirt: Installed", :reset])
        :error -> Mix.shell().error("✗ SuperDirt: Installation failed")
      end
    end
  end

  defp print_summary_footer(sc_result, sd_result) do
    Mix.shell().info(String.duplicate("═", 60))

    if sc_result == :ok && sd_result == :ok do
      Mix.shell().info([:green, "\n🎉 Installation complete!", :reset])

      Mix.shell().info("""

      Next steps:
        1. Verify installation: mix waveform.doctor
        2. Try a demo: mix run demos/01_basic_patterns.exs
        3. Start coding! See README.md for examples

      """)
    else
      Mix.shell().info("\n⚠ Some installations failed. Please review the errors above.")
      Mix.shell().info("Run 'mix waveform.doctor' to check your installation.\n")
    end
  end
end
