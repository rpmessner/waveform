%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "range",
      constants: [
        0.0,
        0.99,
        1.01,
        0.5
      ],
      param_values: [
        440.0
      ],
      param_names: [
        "freq"
      ],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          rate: 1,
          special: 0,
          inputs: [

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
              src: 0, # freq
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1, #0
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen", #freq * 0.99
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0, #freq
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1, #0.99
              constant_index: 1
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen", #freq * 1.01
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0, #freq
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1, #1.01
              constant_index: 2
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",#(freq * 1.01) - (freq * 0.99)
          rate: 1,
          special: 1,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 3, #freq * 1.01
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 2, #freq * 0.99
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",#((freq * 1.01) - (freq * 0.99)) * 0.5
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 4, #(freq * 1.01) - (freq * 0.99)
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1, #0.5
              constant_index: 3
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",#(((freq * 1.01) - (freq * 0.99)) * 0.5) + (freq * 0.99)
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 5,#((freq * 1.01) - (freq * 0.99)) * 0.5
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,#freq * 0.99
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "MulAdd",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 1, #SinOsc.ar(freq)
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 5,#((freq * 1.01) - (freq * 0.99)) * 0.5
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 6,#(((freq * 1.01) - (freq * 0.99)) * 0.5) + (freq * 0.99)
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
              src: -1,#0
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 7,#MulAdd
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
