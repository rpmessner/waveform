ExUnit.start()

defmodule Waveform.Assertions do
  import ExUnit.Assertions

  def assert_synthdef(synthdef, {actual, compiled}) do
    %Waveform.Synth.Def{synthdefs: [actual]} = actual
    %Waveform.Synth.Def{synthdefs: [expected]} = synthdef

    assert actual.name == expected.name, "Name does not match"
    assert actual.ugens == expected.ugens
    assert actual.constants == expected.constants, "Constants do not match"
    assert actual.param_names == expected.param_names, "Param names do not match"
    assert actual.param_values == expected.param_values, "Param values do not match"

    expected = Waveform.Synth.Def.compile(synthdef)
    assert expected == compiled, "Compiled output does not match"
  end
end
