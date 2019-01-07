%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "multi-channel",
      param_names: [],
      param_values: [],
      constants: [440.0, 1.0, 0.0],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Saw",
          rate: 2,
          special: 0,
          outputs: [2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          outputs: [2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            }
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Pan2",
          rate: 2,
          special: 0,
          outputs: [2, 2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 1
            }
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Out",
          rate: 2,
          outputs: [],
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 1
            }
          ]
        }
      ]
    }
  ]
}
