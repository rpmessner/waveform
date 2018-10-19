%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "multi-channel",
      param_names: [],
      param_values: [],
      constants: [440, 1, 0, 0, 1, 0],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Saw",
          rate: 2,
          outputs: [2],
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
            }
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Pan2",
          rate: 2,
          outputs: [2, 2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            }
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Out",
          rate: 2,
          outputs: [],
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
              src: 1,
              constant_index: 1
            }
          ]
        }
      ]
    }
  ]
}
