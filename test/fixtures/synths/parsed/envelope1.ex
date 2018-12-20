%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "env1",
      constants: [
        550.0, #0
        7.0,#1
        24.0,#2
        25.0,#3
        26.0,#4
        27.0,#5
        8.0,#6
        0.0,#7
        3.0,#8
        2.0,#9
        -99.0,#10
        1.0,#11
        0.01,#12
        5.0,#13
        -4.0,#14
        0.03,#15
        0.02,#16
        0.04,#17
        999.0#18
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
              constant_index: 7 #0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 8 #3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 9 # 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 10 # -99
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 11 #1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 12 #0.01
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 14#-4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 15#0.03
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 16#0.02
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 14#-4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7#0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 17#0.04
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 13#5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 14#-4
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
          outputs: [

          ]
        }
      ],
      variants: [

      ]
    }
  ]
}
