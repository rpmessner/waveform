%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "array-env",
      constants: [
        0.8,
        1.0,
        0.0,
        2.0,
        3.0,
        -99.0,
        0.4,
        5.0,
        -4.0,
        0.6,
        0.5,
        0.7,
        440.0,
        880.0
      ],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
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
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 11
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 8
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
              constant_index: 12
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
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
              src: -1,
              constant_index: 13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 2,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 2,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
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
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 3,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 4,
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
