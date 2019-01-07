%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "apad-mh",
      constants: [
        # 0
        6.0,
        # 1
        -111.0,
        # 2
        888.0,
        # 3
        440.0,
        # 4
        0.0
      ],
      param_values: [],
      param_names: [],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Saw",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # -111 (hi - lo) * 0.5
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              # 888 lo + ((hi - lo) * 0.5)
              constant_index: 2
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "SinOsc",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "SinOsc",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 2,
          special: 42,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 2,
          special: 42,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 3,
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
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 4,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 5,
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
