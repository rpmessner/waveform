deftrack :quarters, beats: 5, over: 4, synth: do #, effects: [{:reverb, amp: 1}] do
  %{measure_beat: mb, beat: b} when mb in [1,2,3,4] ->
    play Creepy.chord_at(b)
  _ -> nil
end

defform Creepy do
  beats_per_measure(8)
  key(:g)
  octave(5)
  measures(:I, :III, :IV, :iv)
end

# (definst simple-flute [freq 880
#                        amp 0.5
#                        attack 0.4
#                        decay 0.5
#                        sustain 0.8
#                        release 1
#                        gate 1
#                        out 0]
#   (let [env  (env-gen (adsr attack decay sustain release) gate :action FREE)
#         mod1 (lin-lin:kr (sin-osc:kr 6) -1 1 (* freq 0.99) (* freq 1.01))
#         mod2 (lin-lin:kr (lf-noise2:kr 1) -1 1 0.2 1)
#         mod3 (lin-lin:kr (sin-osc:kr (ranged-rand 4 6)) -1 1 0.5 1)
#         sig (distort (* env (sin-osc [freq mod1])))
#         sig (* amp sig mod2 mod3)]
#     sig))

defsynth SpacePad, note: 69, attack: 0.4, decay: 0.5, sustain: 0.8, release: 1, gate: 1, out_bus: 0 do
  #
  envelope = Envelope.adsr(
    attack: attack, decay: decay, sustain: sustain, release: release
  )

  env = EnvGen.kr(envelope: envelope, gate: gate, done_action: 2)

  # mod1 = LinLin.kr(rate: SinOsc.kr(rate: 6), special: -1, outputs: [1, freq * 0.99, freq * 1.01])
  # mod2 = LinLin.kr(rate: LFNoise2.kr(rate: 1), special: -1, outputs: [1, 0.2, 1])
  # mod2 = LinLin.kr(rate: SinOsc.kr(rate: 1), special: -1, outputs: [1, 0.2, 1])

  freq = midicps(note)

  sig = SinOsc.ar(freq: freq)# * env

  Out.ar(channels: sig, out: out_bus)
end
