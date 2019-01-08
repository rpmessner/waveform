ExUnit.start()
ExUnit.configure(colors: [enabled: true])

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

  defmodule DidNotRaise, do: defstruct(message: nil)

  defmacro assert_compile_time_raise(expected_exception, expected_message, fun) do
    actual_exception =
      try do
        Code.eval_quoted(fun)
        %DidNotRaise{}
      rescue
        e -> e
      end

    quote do
      assert unquote(actual_exception.__struct__) === unquote(expected_exception)
      assert unquote(actual_exception.message) === unquote(expected_message)
    end
  end

  defmacro assert_compile_time_throw(expected_error, fun) do
    actual_exception =
      try do
        Code.eval_quoted(fun)
        :DID_NOT_THROW
      catch
        e -> e
      end

    quote do
      assert unquote(expected_error) === unquote(Macro.escape(actual_exception))
    end
  end

  defmacro match_compile_time_raise(expected_exception, fun) do
    actual_exception =
      try do
        Code.eval_quoted(fun)
        %DidNotRaise{}
      rescue
        e -> e
      end

    quote do
      unquote(expected_exception) = unquote(actual_exception)
    end
  end

  defmacro match_compile_time_throw(expected_error, fun) do
    actual_exception =
      try do
        Code.eval_quoted(fun)
        :DID_NOT_THROW
      catch
        e -> e
      end

    quote do
      unquote(expected_error) = unquote(Macro.escape(actual_exception))
    end
  end
end

