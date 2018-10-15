ExUnit.start()

defmodule Waveform.Assertions do
  import ExUnit.Assertions

  def assert_synthdef(synthdef, {actual, compiled}) do
    %Waveform.Synth.Def{synthdefs: [actual]} = actual
    %Waveform.Synth.Def{synthdefs: [expected]} = synthdef

    assert actual.name == expected.name
    assert actual.constants == expected.constants
    assert actual.param_names == expected.param_names
    assert actual.param_values == expected.param_values
    assert actual.ugens == expected.ugens

    expected = Waveform.Synth.Def.Compile.compile(synthdef)
    assert expected == compiled, "Compiled output does not match"
  end
end
