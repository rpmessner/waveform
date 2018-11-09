%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "enum-inputs",
      constants: [
        600.0, #0
        1.0, #1
        4.0, #6, 2
        3.0, #7, 3
        440.0, #2, 4
        0.0, #3, 5
        5.0, #8, 6
        2.0, #9, 7
        500.0, #4, 8
        6.0, #10, 9
        200.0, #5, 10
        7.0 #11, 11
      ],
      param_values: [

      ],
      param_names: [

      ],
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
          name: "MulAdd",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
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
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 5
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
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
              constant_index: 8
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
          name: "MulAdd",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 4,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 9
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
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
              constant_index: 10
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 5
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 6,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 11
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
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
              constant_index: 5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 3,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 5,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 7,
              constant_index: 0
            }
          ],
          outputs: [

          ]
        }
      ],
      variants: [

      ]
    }
  ]
}
