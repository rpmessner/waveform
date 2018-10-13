defsynth Beep, [
    note: 52,
    note_slide: 0,
    note_slide_shape: 1,
    note_slide_curve: 0,
    amp: 1,
    amp_slide: 0,
    amp_slide_shape: 1,
    amp_slide_curve: 0,
    pan: 0,
    pan_slide: 0,
    pan_slide_shape: 1,
    pan_slide_curve: 0,
    attack: 0,
    decay: 0,
    sustain: 0,
    release: 1,
    attack_level: 1,
    decay_level: -1,
    sustain_level: 1,
    env_curve: 1,
    out_bus: 0,
  ], do

  decay_level = %Select.kr{
    which: (decay_level == -1),
    from: [decay_level, sustain_level]
  }

  note = %Varlag{
    value: note,
    slide: note_slide,
    slide_curve: note_slide_curve,
    slide_shape: note_slide_shape
  }

  amp = %Varlag{
    value: amp,
    slide: amp_slide,
    slide_curve: amp_slide_curve,
    slide_shape: amp_slide_shape
  }

  amp_fudge = 1

  pan = %Varlag{
    value: pan,
    slide: pan_slide,
    slide_curve: pan_slide_curve,
    slide_shape: pan_slide_shape
  }

  freq = midicps(note)

  snd = %SinOsc{freq: freq, phase: 0, mul: 1, add: 0}

  envelope = shaped_adsr(
    attack, decay, sustain, release,
    attack_level, decay_level, sustain_level, env_curve
  )

  env = %EnvGen.kr{envelope: envelope, action: :free}

  channels = %Pan2{in: amp_fudge * env * snd, pos: pan, level: amp}

  out <- %Out{out_bus: out_bus, channels: channels}
end
