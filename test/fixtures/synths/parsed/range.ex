%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "range",
      constants: [
        0.0,
        0.99,
        1.01,
        0.5
      ],
      param_values: [
        440.0
      ],
      param_names: [
        "freq"
      ],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          rate: 1,
          special: 0,
          inputs: [],
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
              # freq
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # 0
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          # freq * 0.99
          name: "BinaryOpUGen",
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              # freq
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # 0.99
              src: -1,
              constant_index: 1
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          # freq * 1.01
          name: "BinaryOpUGen",
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              # freq
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # 1.01
              src: -1,
              constant_index: 2
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          # (freq * 1.01) - (freq * 0.99)
          name: "BinaryOpUGen",
          rate: 1,
          special: 1,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              # freq * 1.01
              src: 3,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # freq * 0.99
              src: 2,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          # ((freq * 1.01) - (freq * 0.99)) * 0.5
          name: "BinaryOpUGen",
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              # (freq * 1.01) - (freq * 0.99)
              src: 4,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # 0.5
              src: -1,
              constant_index: 3
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          # (((freq * 1.01) - (freq * 0.99)) * 0.5) + (freq * 0.99)
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              # ((freq * 1.01) - (freq * 0.99)) * 0.5
              src: 5,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # freq * 0.99
              src: 2,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              # SinOsc.ar(freq)
              src: 1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # ((freq * 1.01) - (freq * 0.99)) * 0.5
              src: 5,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # (((freq * 1.01) - (freq * 0.99)) * 0.5) + (freq * 0.99)
              src: 6,
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
              # 0
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              # MulAdd
              src: 7,
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
