defmodule Mix.Tasks.Waveform.Doctor do
  @moduledoc """
  Verifies that your system is properly configured to use Waveform.

  This task checks for:
  - SuperCollider installation (sclang executable)
  - SuperCollider server executable (scsynth)
  - SuperDirt Quark installation (for pattern-based live coding)
  - Environment variable configuration

  ## Usage

      mix waveform.doctor

  """
  @shortdoc "Verifies system requirements for Waveform"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Checking Waveform system requirements...\n")

    checks = [
      check_sclang(),
      check_sclang_executable(),
      check_scsynth(),
      check_superdirt(),
      check_env_vars()
    ]

    failed = Enum.count(checks, &(&1 == :error))
    passed = Enum.count(checks, &(&1 == :ok))

    Mix.shell().info("\n" <> String.duplicate("=", 60))

    if failed == 0 do
      Mix.shell().info([:green, "✓ All checks passed (#{passed}/#{passed})", :reset])

      Mix.shell().info("\nYour system is ready to use Waveform!")
    else
      Mix.shell().error("✗ #{failed} check(s) failed, #{passed} passed")

      Mix.shell().info("\nPlease address the issues above before using Waveform.")
      Mix.shell().info("See: https://github.com/rpmessner/waveform#prerequisites")
    end
  end

  defp check_sclang do
    Mix.shell().info("Checking for sclang...")

    sclang_path = get_sclang_path()

    cond do
      File.exists?(sclang_path) ->
        Mix.shell().info([:green, "  ✓ Found sclang at: #{sclang_path}", :reset])
        :ok

      sclang_in_path?() ->
        path = System.find_executable("sclang")
        Mix.shell().info([:green, "  ✓ Found sclang in PATH at: #{path}", :reset])
        :ok

      true ->
        Mix.shell().error("  ✗ sclang not found at: #{sclang_path}")
        print_installation_instructions()
        :error
    end
  end

  defp check_sclang_executable do
    Mix.shell().info("Checking if sclang is executable...")

    sclang_path = get_sclang_path()
    path = if File.exists?(sclang_path), do: sclang_path, else: System.find_executable("sclang")

    cond do
      is_nil(path) or not File.exists?(path) ->
        Mix.shell().info([:yellow, "  ⊘ Skipping (sclang not found)", :reset])
        :ok

      not readable?(path) ->
        Mix.shell().error("  ✗ sclang is not executable")
        Mix.shell().info("    Run: chmod +x #{path}")
        :error

      true ->
        check_sclang_version(path)
    end
  end

  defp readable?(path) do
    stat = File.stat!(path)
    stat.access in [:read_write, :read]
  end

  defp check_sclang_version(path) do
    case System.cmd(path, ["-v"], stderr_to_stdout: true) do
      {output, 0} ->
        report_version(output)

      {output, _} ->
        # Some versions of sclang return non-zero with -v
        if String.contains?(output, "SuperCollider") do
          report_version(output)
        else
          Mix.shell().error("  ✗ sclang exists but failed to execute")
          Mix.shell().info("    Output: #{String.trim(output)}")
          :error
        end
    end
  end

  defp report_version(output) do
    version = extract_version(output)

    Mix.shell().info([
      :green,
      "  ✓ sclang is executable (version: #{version})",
      :reset
    ])

    :ok
  end

  defp check_scsynth do
    Mix.shell().info("Checking for scsynth (SuperCollider server)...")

    # Try to find scsynth in common locations
    scsynth_paths = default_scsynth_paths() ++ [System.find_executable("scsynth")]

    scsynth_path = Enum.find(scsynth_paths, &(&1 && File.exists?(&1)))

    if scsynth_path do
      Mix.shell().info([:green, "  ✓ Found scsynth at: #{scsynth_path}", :reset])
      :ok
    else
      Mix.shell().error("  ✗ scsynth not found")
      Mix.shell().info("    This is usually installed with SuperCollider")
      :error
    end
  end

  defp check_superdirt do
    Mix.shell().info("Checking for SuperDirt Quark...")

    sclang_path = get_sclang_path()
    path = if File.exists?(sclang_path), do: sclang_path, else: System.find_executable("sclang")

    if is_nil(path) or not File.exists?(path) do
      Mix.shell().info([:yellow, "  ⊘ Skipping (sclang not found)", :reset])
      :ok
    else
      check_superdirt_installed(path)
    end
  end

  defp check_superdirt_installed(sclang_path) do
    # Run sclang with a command to check if SuperDirt class exists
    # We use -e to evaluate code and quit immediately
    command =
      "SuperDirt.class.notNil.if({ \"SUPERDIRT_INSTALLED\".postln }, { \"SUPERDIRT_NOT_INSTALLED\".postln }); 0.exit;"

    case System.cmd(sclang_path, ["-e", command], stderr_to_stdout: true) do
      {output, _} ->
        cond do
          String.contains?(output, "SUPERDIRT_INSTALLED") ->
            Mix.shell().info([:green, "  ✓ SuperDirt Quark is installed", :reset])
            :ok

          String.contains?(output, "SUPERDIRT_NOT_INSTALLED") ->
            Mix.shell().error("  ✗ SuperDirt Quark is not installed")
            print_superdirt_installation_instructions()
            :error

          true ->
            # Couldn't determine - maybe old SC version or other issue
            Mix.shell().info([
              :yellow,
              "  ⊘ Could not verify SuperDirt (SC may be too old or not responding)",
              :reset
            ])

            :ok
        end
    end
  rescue
    _ ->
      Mix.shell().info([:yellow, "  ⊘ Could not verify SuperDirt installation", :reset])
      :ok
  end

  defp check_env_vars do
    Mix.shell().info("Checking environment variables...")

    if System.get_env("SCLANG_PATH") do
      custom_path = System.get_env("SCLANG_PATH")
      Mix.shell().info([:green, "  ✓ SCLANG_PATH is set to: #{custom_path}", :reset])
      :ok
    else
      Mix.shell().info([:yellow, "  ⊘ SCLANG_PATH not set (using default location)", :reset])
      :ok
    end
  end

  defp get_sclang_path do
    System.get_env("SCLANG_PATH") || default_sclang_path()
  end

  defp default_sclang_path do
    case :os.type() do
      {:unix, :darwin} ->
        "/Applications/SuperCollider.app/Contents/MacOS/sclang"

      {:unix, _} ->
        # Linux: try common installation paths
        Enum.find(
          ["/usr/bin/sclang", "/usr/local/bin/sclang"],
          &File.exists?/1
        ) || "/usr/bin/sclang"

      {:win32, _} ->
        # Windows: try common installation paths
        Enum.find(
          [
            "C:\\Program Files\\SuperCollider\\sclang.exe",
            "C:\\Program Files (x86)\\SuperCollider\\sclang.exe"
          ],
          &File.exists?/1
        ) || "C:\\Program Files\\SuperCollider\\sclang.exe"
    end
  end

  defp default_scsynth_paths do
    case :os.type() do
      {:unix, :darwin} ->
        ["/Applications/SuperCollider.app/Contents/Resources/scsynth"]

      {:unix, _} ->
        # Linux: try common installation paths
        ["/usr/bin/scsynth", "/usr/local/bin/scsynth"]

      {:win32, _} ->
        # Windows: try common installation paths
        [
          "C:\\Program Files\\SuperCollider\\scsynth.exe",
          "C:\\Program Files (x86)\\SuperCollider\\scsynth.exe"
        ]
    end
  end

  defp sclang_in_path? do
    System.find_executable("sclang") != nil
  end

  defp extract_version(output) do
    case Regex.run(~r/Version (\d+\.\d+\.\d+[^\s]*)/, output) do
      [_, version] -> version
      _ -> "unknown"
    end
  end

  defp print_installation_instructions do
    Mix.shell().info("\n  Installation instructions:\n")

    Mix.shell().info("  macOS:")
    Mix.shell().info("    brew install supercollider\n")

    Mix.shell().info("  Linux (Debian/Ubuntu):")
    Mix.shell().info("    sudo apt-get install supercollider\n")

    Mix.shell().info("  Linux (Arch):")
    Mix.shell().info("    sudo pacman -S supercollider\n")

    Mix.shell().info("  Windows:")
    Mix.shell().info("    Download from https://supercollider.github.io/\n")

    Mix.shell().info("  Custom location:")
    Mix.shell().info("    export SCLANG_PATH=/path/to/sclang")
  end

  defp print_superdirt_installation_instructions do
    Mix.shell().info("\n  SuperDirt installation instructions:\n")

    Mix.shell().info("  1. Open SuperCollider IDE (or run sclang)")
    Mix.shell().info("  2. Install SuperDirt Quark:")
    Mix.shell().info("     Quarks.install(\"SuperDirt\");\n")

    Mix.shell().info("  3. Recompile the class library:")
    Mix.shell().info("     thisProcess.recompile;\n")

    Mix.shell().info("  4. (Optional) Add to startup file for automatic loading:")
    Mix.shell().info("     SuperDirt.start;\n")

    Mix.shell().info("  For more info:")
    Mix.shell().info("    https://github.com/musikinformatik/SuperDirt")
  end
end
