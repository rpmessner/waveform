%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "env1",
      constants: [
        # 0
        550.0,
        # 1
        7.0,
        # 2
        24.0,
        # 3
        25.0,
        # 4
        26.0,
        # 5
        27.0,
        # 6
        8.0,
        # 7
        0.0,
        # 8
        3.0,
        # 9
        2.0,
        # 10
        -99.0,
        # 11
        1.0,
        # 12
        0.01,
        # 13
        5.0,
        # 14
        -4.0,
        # 15
        0.03,
        # 16
        0.02,
        # 17
        0.04,
        # 18
        999.0
      ],
      param_values: [],
      param_names: [],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "SinOsc",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 24
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 25
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 26
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 27
              constant_index: 5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 8
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 0
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 3
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 2
              constant_index: 9
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # -99
              constant_index: 10
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 1
              constant_index: 11
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 0.01
              constant_index: 12
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 5
              constant_index: 13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # -4
              constant_index: 14
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 0.03
              constant_index: 15
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 0.02
              constant_index: 16
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 5
              constant_index: 13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # -4
              constant_index: 14
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 0
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 0.04
              constant_index: 17
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 5
              constant_index: 13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # -4
              constant_index: 14
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 2,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 1,
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Out",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 18
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 0
            }
          ],
          outputs: []
        }
      ],
      variants: []
    }
  ]
}
