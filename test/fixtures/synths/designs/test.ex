defsynth MyBeep,
  note: 52,
  out_bus: 0 do
  #

  freq = midicps(note)

  snd = %SinOsc.ar(){freq: freq}
  snd = %Decay2.ar(){in: freq, attack_time: 0.01, decay_time: 1, mul: 1, add: 0}

  %Out{bus: out_bus, channels: snd}
end
