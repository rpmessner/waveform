%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      constants: [
        # phase
        0.0,
        # mul
        1.0,
        # add
        0.0,

        # envelope
        # min
        0.0,
        4.0,
        -99.0,
        -99.0,
        1.0,
        0.0,
        0.0,
        # min
        0.0,
        0.0,

        # gate
        1.0,
        # level_scale,
        1.0,
        # level_bias,
        0.0,
        # time_scale
        1.0,
        # done_action
        2.0
      ],
      name: "envelope-def",
      param_names: [
        "note",
        "attack",
        "decay",
        "sustain",
        "release",
        "attack_level",
        "decay_level",
        "sustain_level",
        "env_curve",
        "out_bus"
      ],
      param_values: [
        # A 440
        69.0,
        # attack
        0.0,
        # decay
        0.0,
        # sustain
        0.0,
        # release
        1.0,
        # attack_level
        1.0,
        # decay_level
        -1.0,
        # sustain_level
        1.0,
        # env_curve
        1.0,
        # out_bus
        0.0
      ],
      ugens: [
        # 0
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          inputs: [],
          outputs: [
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1
          ],
          # lfo
          rate: 1,
          special: 0
        },

        # 1
        # midicps(note)
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 17,
          inputs: [
            # midi
            %Waveform.Synth.Def.Ugen.Input{src: 0, constant_index: 0}
          ],
          outputs: [1]
        },

        # 2
        # saw <- %SinOsc{}
        %Waveform.Synth.Def.Ugen{
          name: "SinOsc",
          inputs: [
            # freq
            %Waveform.Synth.Def.Ugen.Input{src: 1, constant_index: 0},
            # phase
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0},
            # mul
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 1},
            # add
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 2}
          ],
          rate: 2,
          special: 0,
          outputs: [2]
        },

        # 3
        # env_gen = %EnvGen.kr{}
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            # 1.0 gate
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 12
            },
            # 1.0 levelScale
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13
            },
            # levelBias 0.0
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 14
            },
            # timeScale 1.0
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 15
            },
            # done: :free - 2.0
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 16
            },

            # min
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 9
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 10
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 11
            }
          ],
          outputs: [
            1
          ]
        },

        # 4
        # sin_osc * env
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 2,
          special: 2,
          outputs: [2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 2},
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 3}
          ]
        },

        # 5
        # out <- %Out{}
        %Waveform.Synth.Def.Ugen{
          name: "Out",
          rate: 2,
          special: 0,
          outputs: [],
          inputs: [
            # out_bus
            %Waveform.Synth.Def.Ugen.Input{constant_index: 9, src: 0},
            # sin_osc out0
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 4}
          ]
          # hfo
        }
      ],
      variants: []
    }
  ]
}
