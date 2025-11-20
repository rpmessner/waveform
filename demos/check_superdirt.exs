#!/usr/bin/env elixir

# Check if SuperDirt is working with multiple samples
# This verifies that the buffer configuration is correct and all samples load

alias Waveform.Helpers

IO.puts """
🔊 SuperDirt Verification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Testing SuperDirt with multiple samples to verify:
  ✓ SuperDirt is installed
  ✓ Buffer configuration is correct (4096 buffers)
  ✓ Dirt-Samples are loaded
  ✓ Sample playback works

"""

Process.sleep(1000)

# Use the helper to ensure SuperDirt is ready
IO.puts("Starting SuperDirt with Dirt-Samples...")
Helpers.ensure_superdirt_ready()
IO.puts("✓ SuperDirt ready!\n")

# Test multiple samples to verify buffer fix
IO.puts("Testing sample playback...")
IO.puts("You should hear: kick, snare, hi-hat, clap\n")

samples = [
  {"bd", "Kick drum"},
  {"sn", "Snare"},
  {"hh", "Hi-hat"},
  {"cp", "Clap"}
]

for {sample, name} <- samples do
  IO.puts("  Playing #{name}...")
  Waveform.SuperDirt.play(s: sample, n: 0, gain: 0.8)
  Process.sleep(700)
end

IO.puts """

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
"""
