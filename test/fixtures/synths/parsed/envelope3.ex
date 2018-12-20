%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "env3",
      constants: [
        550.0,#0
        7.0,#1
        1.0,#2
        0.0,#3
        8.0,#4
        11.0,#5
        3.0,#6
        -99.0,#7
        12.0,#8
        21.0,#9
        4.0,#10
        13.0,#11
        22.0,#12
        14.0,#13
        23.0,#14
        999.0#15
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
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2#1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2#1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3#0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2#1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4#8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 5#11
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 6#3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7#-99
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7#-99
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 8#12
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 9#21
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 10#4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3#0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 11#13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 12#22
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 10#4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3#0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#14
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 14#23
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 10#4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3#0
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
              constant_index: 15
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
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
