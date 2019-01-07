%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      constants: [
        # phase
        0.0,
        # mul
        1.0,
        # add
        2.0
      ],
      name: "sin-osc-def",
      param_names: ["note", "out_bus"],
      param_values: [
        # A 440
        69.0,
        # out_bus
        0.0
      ],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          inputs: [],
          outputs: [
            1,
            1
          ],
          # lfo
          rate: 1,
          special: 0
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 17,
          inputs: [
            # midi
            %Waveform.Synth.Def.Ugen.Input{src: 0, constant_index: 0}
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "SinOsc",
          inputs: [
            # freq
            %Waveform.Synth.Def.Ugen.Input{src: 1, constant_index: 0},
            # phase
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0}
          ],
          rate: 2,
          special: 0,
          outputs: [2]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          outputs: [2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{src: 2, constant_index: 0},
            # mul
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 1},
            # add
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 2}
          ]
        },
        %Waveform.Synth.Def.Ugen{
          inputs: [
            # out_bus
            %Waveform.Synth.Def.Ugen.Input{constant_index: 1, src: 0},
            # sin_osc out0
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 3}
          ],
          name: "Out",
          # hfo
          rate: 2,
          special: 0
        }
      ]
    }
  ]
}
