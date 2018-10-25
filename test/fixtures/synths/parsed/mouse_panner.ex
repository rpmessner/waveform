%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      constants: [0.0, 0.1, 1.0, 0.2],
      name: "mouse-panner",
      param_names: [],
      param_values: [],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          arguments: [],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{constant_index: 1, src: -1}
          ],
          name: "WhiteNoise",
          outputs: [2],
          rate: 2,
          special: 0
        },
        %Waveform.Synth.Def.Ugen{
          arguments: [],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{constant_index: 2, src: -1}
          ],
          name: "UnaryOpUGen",
          outputs: [1],
          rate: 1,
          special: 0
        },
        %Waveform.Synth.Def.Ugen{
          arguments: [],
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 1},
            %Waveform.Synth.Def.Ugen.Input{constant_index: 2, src: -1},
            %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: -1},
            %Waveform.Synth.Def.Ugen.Input{constant_index: 3, src: -1}
          ],
          name: "MouseX",
          outputs: [1],
          rate: 1,
          special: 0
        },
        %Waveform.Synth.Def.Ugen{
           arguments: [],
           inputs: [
             %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 0},
             %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 2},
             %Waveform.Synth.Def.Ugen.Input{constant_index: 2, src: -1}
           ],
           name: "Pan2",
           outputs: [2, 2],
           rate: 2,
           special: 0
         },
         %Waveform.Synth.Def.Ugen{
           arguments: [],
           inputs: [
             %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: -1},
             %Waveform.Synth.Def.Ugen.Input{constant_index: 0, src: 3},
             %Waveform.Synth.Def.Ugen.Input{constant_index: 1, src: 3}
           ],
           name: "Out",
           outputs: [],
           rate: 2,
           special: 0
         }

      ]
    }
  ]
}
