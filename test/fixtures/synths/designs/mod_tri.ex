defsynth ModTri,
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
  cutoff: 100,
  cutoff_slide: 0,
  cutoff_slide_shape: 1,
  cutoff_slide_curve: 0,
  mod_phase: 0.25,
  mod_phase_slide: 0,
  mod_phase_slide_shape: 1,
  mod_phase_slide_curve: 0,
  mod_range: 5,
  mod_range_slide: 0,
  mod_range_slide_shape: 1,
  mod_range_slide_curve: 0,
  mod_pulse_width: 0.5,
  mod_pulse_width_slide: 0,
  mod_pulse_width_slide_shape: 1,
  mod_pulse_width_slide_curve: 0,
  mod_phase_offset: 0,
  mod_wave: 1,
  mod_invert_wave: 0,
  out_bus: 0 do
  #
  decay_level = %Select.kr(){
    which: decay_level == -1,
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

  amp_fudge = 1.5

  pan = %Varlag{
    value: pan,
    slide: pan_slide,
    slide_curve: pan_slide_curve,
    slide_shape: pan_slide_shape
  }

  cutoff = %Varlag{
    value: cutoff,
    slide: cutoff_slide,
    slide_curve: cutoff_slide_curve,
    slide_shape: cutoff_slide_shape
  }

  mod_phase = %Varlag{
    value: mod_phase,
    slide: mod_phase_slide,
    slide_curve: mod_phase_slide_curve,
    slide_shape: mod_phase_slide_shape
  }

  mod_rate = 1 / mod_phase

  mod_range = %Varlag{
    value: mod_range,
    slide: mod_range_slide,
    slide_curve: mod_range_slide_curve,
    slide_shape: mod_range_slide_shape
  }

  mod_pulse_width = %Varlag{
    value: mod_pulse_width,
    slide: mod_pulse_width_slide,
    slide_curve: mod_pulse_width_slide_curve,
    slide_shape: mod_pulse_width_slide_shape
  }

  min_note = note
  max_note = mod_range + note

  mod_double_phase_offset = mod_phase_offset * 2

  ctl_wave = %Select.kr(){
    which: mod_wave,
    from: [
      %LFSaw.kr(){
        freq: mod_rate,
        iphase: mod_double_phase_offset + 1,
        mul: -1
      },
      %LFPulse.kr(){
        freq: mod_rate,
        iphase: mod_phase_offset,
        width: mod_pulse_width,
        mul: 2,
        add: -1
      },
      %LFTri.kr(){freq: mod_rate, iphase: mod_double_phase_offset + 1},
      %SinOsc.kr(){freq: mod_rate, mul: (mod_phase_offset + 0.25) * (PI * 2)}
    ]
  }

  ctl_wave_mul = (mod_invert_wave > 0) * 2 - 1
  ctl_wave = ctl_wave * ctl_wave_mul * -1

  mod_note = %LinLin{
    in: ctl_wave,
    srclo: -1,
    srchi: 1,
    dstlo: min_note,
    dsthi: max_note
  }

  freq(midicps(mod_note))
  cutoff_freq(midicps(cutoff))

  snd = %LFTri{freq: freq}
  snd = %LPF{in: snd, freq: cutoff_freq}
  snd = %Normalizer{in: snd}

  env =
    shaped_adsr(
      attack,
      decay,
      sustain,
      release,
      attack_level,
      decay_level,
      sustain_level,
      env_curve
    )

  env = %EnvGen{
    envelope: env,
    action: :free
  }

  out <- %Out{
    bus: out_bus,
    channels: %Pan2{
      in: amp_fudge * env * snd,
      pos: pan,
      level: amp
    }
  }
end
