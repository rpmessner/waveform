%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      constants: [
        2.0,
        0.5,
        1.0,
      ],
      name: "saw-def",
      param_names: ["note", "out_bus", "foo", "bar"],
      param_values: [
        # A 440
        69.0,
        # out_bus
        0.0,
        # foo
        0.0,
        # bar
        0.0
      ],
      ugens: [
        # 0
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          inputs: [],
          outputs: [
            1,
            1,
            1,
            1
          ],
          # lfo
          rate: 1,
          special: 0
        },

        # 1
        # midicps(note)
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 17,
          inputs: [
            # midi
            %Waveform.Synth.Def.Ugen.Input{src: 0, constant_index: 0}
          ],
          outputs: [1]
        },

        # 2
        # freq * 2.0
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{src: 1, constant_index: 0},
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0}
          ],
          outputs: [1]
        },

        # 3
        # foo > 0.5
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{src: 0, constant_index: 2},
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 1}
          ],
          outputs: [1]
        },

        # 4
        # if foo > 0.5, do: freq, else: freq2
        %Waveform.Synth.Def.Ugen{
          name: "Select",
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{src: 3, constant_index: 0},
            %Waveform.Synth.Def.Ugen.Input{src: 1, constant_index: 0},
            %Waveform.Synth.Def.Ugen.Input{src: 2, constant_index: 0}
          ],
          rate: 1,
          special: 0,
          outputs: [1]
        },

        # 5
        # saw <- %Saw{}
        %Waveform.Synth.Def.Ugen{
          name: "Saw",
          inputs: [
            # freq
            %Waveform.Synth.Def.Ugen.Input{src: 1, constant_index: 0},
          ],
          rate: 2,
          special: 0,
          outputs: [2]
        },

        # 6
        # saw mul & add params
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          outputs: [2],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{src: 5, constant_index: 0},
            # mul
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 2},
            # add
            %Waveform.Synth.Def.Ugen.Input{src: -1, constant_index: 0}
          ]
        },

        # 7
        # out <- %Out{}
        %Waveform.Synth.Def.Ugen{
          name: "Out",
          rate: 2,
          special: 0,
          outputs: [],
          inputs: [
            # out_bus
            %Waveform.Synth.Def.Ugen.Input{constant_index: 1, src: 0},
            # sin_osc out0
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 6}
          ]
          # hfo
        }
      ],
      variants: []
    }
  ]
}
