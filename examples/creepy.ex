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

# SynthDef(\space-pad, {
# arg freq=880, amp=0.5, attack=0.4, decay=0.5,
# sustain=0.8, release=1.0, gate=1.0, out=0;
defsynth SpacePad, [
  note: 69,
  amp: 0.5,
  attack: 0.4,
  decay: 0.5,
  sustain: 0.8,
  release: 1.0,
  gate: 1.0,
  out: 0
] do
  freq = midicps(note)

  # envelope = Env.adsr(attack,decay,sustain,release)
  envelope = Envelope.adsr(
    attack_time: attack, decay_time: decay,
    sustain_level: sustain, release_time: release
  )
  # env = EnvGen.kr(envelope,gate,levelScale: amp, doneAction:2);
  env = EnvGen.kr(envelope: envelope, level_scale: amp, gate: gate, done_action: 2)
  # mod1 = SinOsc.kr(6).range(freq*0.99,freq*1.01);
  mod1 = SinOsc.kr(freq: 6).range(freq * 0.99, freq * 1.01)
  # mod2 = LFNoise2.kr(1).range(0.2,1);
  mod2 = LFNoise2.kr(freq: 1).range(0.2, 1)
  # mod3 = SinOsc.kr(rrand(4.0,6.0)).range(0.5, 1);
  mod3 = SinOsc.kr(freq: rrand(4.0, 6.0)).range(0.5, 1);
  # sig = SinOsc.ar([freq,mod1],0, env).distort;
  sig = SinOsc.ar(freq: [freq, mod1], phase: 0, mul: env).distort()
  # sig = sig * mod2 * mod3;
  sig = sig * mod2 * mod3;
  # Out.ar(out, sig);
  Out.ar(bus: out, channels: sig)
end
