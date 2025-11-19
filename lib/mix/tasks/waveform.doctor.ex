defmodule Mix.Tasks.Waveform.Doctor do
  @moduledoc """
  Verifies that your system is properly configured to use Waveform.

  This task checks for:
  - SuperCollider installation (sclang executable)
  - SuperCollider server executable (scsynth)
  - Environment variable configuration

  ## Usage

      mix waveform.doctor

  """
  @shortdoc "Verifies system requirements for Waveform"

  use Mix.Task

  @sclang_path System.get_env("SCLANG_PATH") || "/Applications/SuperCollider.app/Contents/MacOS/sclang"

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Checking Waveform system requirements...\n")

    checks = [
      check_sclang(),
      check_sclang_executable(),
      check_scsynth(),
      check_env_vars()
    ]

    failed = Enum.count(checks, &(&1 == :error))
    passed = Enum.count(checks, &(&1 == :ok))

    Mix.shell().info("\n" <> String.duplicate("=", 60))

    if failed == 0 do
      Mix.shell().info(
        [:green, "✓ All checks passed (#{passed}/#{passed})", :reset]
      )

      Mix.shell().info("\nYour system is ready to use Waveform!")
    else
      Mix.shell().error(
        "✗ #{failed} check(s) failed, #{passed} passed"
      )

      Mix.shell().info("\nPlease address the issues above before using Waveform.")
      Mix.shell().info("See: https://github.com/rpmessner/waveform#prerequisites")
    end
  end

  defp check_sclang do
    Mix.shell().info("Checking for sclang...")

    cond do
      File.exists?(@sclang_path) ->
        Mix.shell().info([:green, "  ✓ Found sclang at: #{@sclang_path}", :reset])
        :ok

      sclang_in_path?() ->
        path = System.find_executable("sclang")
        Mix.shell().info([:green, "  ✓ Found sclang in PATH at: #{path}", :reset])
        :ok

      true ->
        Mix.shell().error("  ✗ sclang not found at: #{@sclang_path}")
        print_installation_instructions()
        :error
    end
  end

  defp check_sclang_executable do
    Mix.shell().info("Checking if sclang is executable...")

    path = if File.exists?(@sclang_path), do: @sclang_path, else: System.find_executable("sclang")

    if path && File.exists?(path) do
      stat = File.stat!(path)

      case stat.access do
        access when access in [:read_write, :read] ->
          # Try to get version
          case System.cmd(path, ["-v"], stderr_to_stdout: true) do
            {output, 0} ->
              version = extract_version(output)
              Mix.shell().info([:green, "  ✓ sclang is executable (version: #{version})", :reset])
              :ok

            {output, _} ->
              # Some versions of sclang return non-zero with -v
              if String.contains?(output, "SuperCollider") do
                version = extract_version(output)
                Mix.shell().info([:green, "  ✓ sclang is executable (version: #{version})", :reset])
                :ok
              else
                Mix.shell().error("  ✗ sclang exists but failed to execute")
                Mix.shell().info("    Output: #{String.trim(output)}")
                :error
              end
          end

        _ ->
          Mix.shell().error("  ✗ sclang is not executable")
          Mix.shell().info("    Run: chmod +x #{path}")
          :error
      end
    else
      Mix.shell().info([:yellow, "  ⊘ Skipping (sclang not found)", :reset])
      :ok
    end
  end

  defp check_scsynth do
    Mix.shell().info("Checking for scsynth (SuperCollider server)...")

    # Try to find scsynth in common locations
    scsynth_paths = [
      "/Applications/SuperCollider.app/Contents/Resources/scsynth",
      System.find_executable("scsynth")
    ]

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
end
