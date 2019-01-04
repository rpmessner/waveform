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

# /private/tmp/tmux-501/default
##

Waveform.Lang.send_command("s.freeAll")
OSC.send_command(['/d_free', 'space-pad'])

use_synth :space_pad

use_synth :prophet

play :c4

play :g4

play :e4

defsynth SpacePad, [ note: 69,
  amp: 0.5,
  attack: 0.4,
  decay: 0.5,
  sustain: 0.8,
  release: 1,
  gate: 1,
  out_bus: 0
] do

  freq = midicps(note)

  # (let [env  (env-gen (adsr attack decay sustain release) gate :action FREE)
  envelope = Envelope.adsr(
    attack_time: attack, decay_time: decay,
    sustain_level: sustain, release_time: release
  )
  env = EnvGen.kr(envelope: envelope, gate: gate, done_action: 2)

  #  mod1 (lin-lin:kr (sin-osc:kr 6) -1 1 (* freq 0.99) (* freq 1.01))
  # mod1 = LinLin.kr(
  #   in: SinOsc.kr(freq: 6),
  #   srclo: -1,
  #   srchi: 1,
  #   dstlo: freq * 0.99,
  #   dsthi: freq * 1.01
  # )
  #  mod2 (lin-lin:kr (lf-noise2:kr 1) -1 1 0.2 1)
  # mod2 = LinLin.kr(
  #   in: LFNoise2.kr(freq: 1),
  #   srclo: -1,
  #   srchi: 1,
  #   dstlo: 0.2,
  #   dsthi: 1
  # )
  #  mod3 (lin-lin:kr (sin-osc:kr (ranged-rand 4 6)) -1 1 0.5 1)
  mod3 = LinLin.kr(
    in: SinOsc.kr(freq: Rand.kr(lo: 4, hi: 6)),
    srclo: -1,
    srchi: 1,
    dstlo: 0.5,
    dsthi: 1
  )

  # sig (distort (* env (sin-osc [freq mod1])))

  sig = distort(SinOsc.ar(freq: freq) * env)  * amp
  # sig1 = distort(SinOsc.ar(freq: mod1) * env)

  # sig (* amp sig mod2 mod3)]

  # sig = amp * sig
  # sig = sig * mod2# * mod3
  # sig1 = amp * sig * mod2 * mod3

  Out.ar(bus: out_bus, channels: sig)
end

# (definst simple-flute [freq 880
#                        amp 0.5
#                        attack 0.4
#                        decay 0.5
#                        sustain 0.8
#                        release 1
#                        gate 1
#                        out 0]
#     sig))
