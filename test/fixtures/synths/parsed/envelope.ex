%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      constants: [
        0.0,
        1.0,
        4.0,
        -99.0,
        2.0#16,4
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
        # saw <- %SinOsc{phase: 0}
        %Waveform.Synth.Def.Ugen{
          name: "SinOsc",
          inputs: [
            # freq
            %Waveform.Synth.Def.Ugen.Input{src: 1, constant_index: 0},
            # phase
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0},
          ],
          rate: 2,
          special: 0,
          outputs: [2]
        },

        # 3
        # SinOsc{mul: 1, add: 0}
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{src: 2, constant_index: 0},
            # mul
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 1},
            # add
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0}
          ],
          rate: 2,
          special: 0,
          outputs: [2]
        },

        # 4
        # env_gen = %EnvGen.kr{}
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            # 1.0 gate
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            # 1.0 levelScale
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            # levelBias 0.0
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            # timeScale 1.0
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            # done: :free - 2.0
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            },

            # min
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
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
              constant_index: 1
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
              constant_index: 0
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
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
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
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },

        # 5
        # sin_osc * env
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 2,
          special: 2,
          outputs: [2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 3},
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 4}
          ]
        },

        # 6
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
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 5}
          ]
          # hfo
        }
      ],
      variants: []
    }
  ]
}
