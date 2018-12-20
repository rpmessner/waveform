%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "env2",
      constants: [
        550.0,#0
        7.0,#1
        24.0,#2
        25.0,#3
        26.0,#4
        27.0,#5
        8.0,#6
        11.0,#7
        3.0,#8
        40.0,#9
        41.0,#10
        12.0,#11
        21.0,#12
        5.0,#13
        -1.0,#14
        13.0,#15
        22.0,#16
        -2.0,#17
        14.0,#18
        23.0,#19
        -3.0,#20
        999.0#21
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
              constant_index: 2 #24
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3 #25
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4 #26
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 5 #27
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 6 #8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7 #11
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 8 #3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 9 #40
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 10#41
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 11#12
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 12#21
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 14#-1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 15#13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 16#22
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 17#-2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 18#14
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 19#23
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 20#-3
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
              constant_index: 21
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
