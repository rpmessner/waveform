%Waveform.Synth.Def{
  synthdefs: [
    %Waveform.Synth.Def.Synth{
      name: "waveform-beep",
      constants: [
        0.0,
        0.0,
        2.0,
        1.0,
        -1.0,
        1.0,
        4.0,
        -99.0
      ],
      param_values: [
        52.0,
        0.0,
        1.0,
        0.0,
        1.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        1.0,
        -1.0,
        1.0,
        1.0,
        0.0
      ],
      param_names: [
        "note",
        "note_slide",
        "note_slide_shape",
        "note_slide_curve",
        "amp",
        "amp_slide",
        "amp_slide_shape",
        "amp_slide_curve",
        "pan",
        "pan_slide",
        "pan_slide_shape",
        "pan_slide_curve",
        "attack",
        "decay",
        "sustain",
        "release",
        "attack_level",
        "decay_level",
        "sustain_level",
        "env_curve",
        "out_bus"
      ],
      ugens: [
        %Waveform.Synth.Def.Ugen{
          name: "Control",
          rate: 1,
          special: 0,
          inputs: [],
          outputs: [
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "HPZ1",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 4
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Impulse",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "HPZ1",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 5,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 3,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 4,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 2,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 5,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "HPZ1",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 9
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 5,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 7,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 8,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 6,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 9,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 10,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 8
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 9
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 10
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 11
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Impulse",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "HPZ1",
          rate: 1,
          special: 0,
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
          name: "UnaryOpUGen",
          rate: 1,
          special: 5,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 13,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 14,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 12,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 15,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 5,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 17,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "HPZ1",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 1
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 5,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 19,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Impulse",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 21,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 18,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "HPZ1",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 5
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 5,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 23,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 24,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 22,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 25,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 26,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 5
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 7
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 9,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 20,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 16,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 28,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 29,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
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
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 1
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 3
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "UnaryOpUGen",
          rate: 1,
          special: 17,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 30,
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
              src: 31,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 6,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 4
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 17
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Select",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 33,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 17
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 18
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "EnvGen",
          rate: 1,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 2
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 6
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 7
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 16
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 12
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 19
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 34,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 13
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 19
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 18
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 14
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 19
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 15
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 0,
              constant_index: 19
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 0
            }
          ],
          outputs: [
            1
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "BinaryOpUGen",
          rate: 1,
          special: 2,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: -1,
              constant_index: 3
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 35,
              constant_index: 0
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
              src: 36,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 32,
              constant_index: 0
            }
          ],
          outputs: [
            2
          ]
        },
        %Waveform.Synth.Def.Ugen{
          name: "Pan2",
          rate: 2,
          special: 0,
          inputs: [
            %Waveform.Synth.Def.Ugen.Input{
              src: 37,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 11,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 27,
              constant_index: 0
            }
          ],
          outputs: [
            2,
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
              constant_index: 20
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 38,
              constant_index: 0
            },
            %Waveform.Synth.Def.Ugen.Input{
              src: 38,
              constant_index: 1
            }
          ],
          outputs: []
        }
      ],
      variants: []
    }
  ]
}
