{
  "file_type_id": "SCgf",
  "file_version": 2,
  "no_of_synthdefs": 1,
  "synthdefs": [
    {
      "name": "tutorial-SinOsc",
      "no_of_constants": 4,
      "constants": [
        440.0,
        0.0,
        1.0,
        0.20000000298023224
      ],
      "no_of_params": 0,
      "params": [

      ],
      "no_of_param_names": 0,
      "param_names": [

      ],
      "no_of_ugens": 5,
      "ugens": [
        {
          "ugen_name": "SinOsc",
          "rate": 2,
          "no_of_inputs": 2,
          "no_of_outputs": 1,
          "special": 0,
          "inputs": [
            {
              "src": -1,
              "input_constant_index": 0
            },
            {
              "src": -1,
              "input_constant_index": 1
            }
          ],
          "outputs": [
            2
          ]
        },
        {
          "ugen_name": "BinaryOpUGen",
          "rate": 2,
          "no_of_inputs": 2,
          "no_of_outputs": 1,
          "special": 2,
          "inputs": [
            {
              "src": 0,
              "input_constant_index": 0
            },
            {
              "src": -1,
              "input_constant_index": 3
            }
          ],
          "outputs": [
            2
          ]
        },
        {
          "ugen_name": "SinOsc",
          "rate": 2,
          "no_of_inputs": 2,
          "no_of_outputs": 1,
          "special": 0,
          "inputs": [
            {
              "src": -1,
              "input_constant_index": 0
            },
            {
              "src": -1,
              "input_constant_index": 2
            }
          ],
          "outputs": [
            2
          ]
        },
        {
          "ugen_name": "BinaryOpUGen",
          "rate": 2,
          "no_of_inputs": 2,
          "no_of_outputs": 1,
          "special": 2,
          "inputs": [
            {
              "src": 2,
              "input_constant_index": 0
            },
            {
              "src": -1,
              "input_constant_index": 3
            }
          ],
          "outputs": [
            2
          ]
        },
        {
          "ugen_name": "Out",
          "rate": 2,
          "no_of_inputs": 3,
          "no_of_outputs": 0,
          "special": 0,
          "inputs": [
            {
              "src": -1,
              "input_constant_index": 1
            },
            {
              "src": 1,
              "input_constant_index": 0
            },
            {
              "src": 3,
              "input_constant_index": 0
            }
          ],
          "outputs": [

          ]
        }
      ],
      "no_of_variants": 0,
      "variants": [

      ]
    }
  ]
}
