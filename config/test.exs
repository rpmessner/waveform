import Config

# Use NoOp transport in tests - no actual OSC messages sent
config :waveform,
  osc_transport: Waveform.OSC.NoOp,
  superdirt_transport: Waveform.SuperDirt.NoOp
