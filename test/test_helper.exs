ExUnit.start()

defmodule Waveform.Assertions do
  import ExUnit.Assertions

  def assert_synthdef(actual, expected) do
    %Waveform.Synth.Def{synthdefs: [actual]} = actual
    %Waveform.Synth.Def{synthdefs: [expected]} = expected

    assert actual.name == expected.name
    assert actual.ugens == expected.ugens
    assert actual.constants == expected.constants
    assert actual.param_names == expected.param_names
    assert actual.param_values == expected.param_values
  end
end
