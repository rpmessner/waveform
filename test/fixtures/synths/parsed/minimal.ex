%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "minimal-synth",
      constants: [
        0.0,
        1.0,
        0.0
      ],
      param_values: [
        69.0,
        0.0
      ],
      param_names: ["note", "out_bus"],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          rate: 1,
          special: 0,
          inputs: [],
          outputs: [
            1,
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 17,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
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
              src: 1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0},
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 1},
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 2}
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
              src: 0,
              constant_index: 1
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
