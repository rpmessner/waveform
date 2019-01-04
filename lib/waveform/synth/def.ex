defmodule Waveform.Synth.Def do
  alias Waveform.Synth.Def.Compile
  alias Waveform.Synth.Def.Parse
  alias Waveform.Synth.Def.Submodule
  alias Waveform.Synth.Manager

  alias __MODULE__

  defstruct(synthdefs: [])

  defmodule Synth do
    defstruct(
      # outputted to .synthdef
      name: nil,
      constants: [],
      param_values: [],
      param_names: [],
      ugens: [],
      variants: [],

      # internal state
      parameters: %{},
      assigns: %{}
    )
  end

  defmodule Ugen do
    defstruct(
      # outputted to .synthdef
      name: nil,
      rate: nil,
      special: nil,
      inputs: [],
      outputs: [],

      # internal state
      arguments: []
    )
  end

  defmodule Ugen.Input do
    defstruct(
      src: nil,
      constant_index: nil
    )
  end

  alias Ugen.Input

  defmacro defsubmodule({_, _, [name]}, params, do: {:__block__, _, submodule_forms}) do
    submodule = Submodule.define(name, params, submodule_forms)

    quote do
      unquote(Macro.escape(submodule))
    end
  end

  defmacro defsynth(
             {:__aliases__, _, [name]},
             params,
             do: {:__block__, _, expressions}
           ) do
    build_synthdef(name, params, expressions)
  end

  # {LPF.ar(WhiteNoise.ar(0.1),1000)}.scope

  defmacro defsynth(
             {:__aliases__, _, [name]},
             params,
             do: expressions
           ) do
    build_synthdef(name, params, expressions)
  end

  def build_synthdef(name, params, expressions) do
    name = parse_synthdef_name(name)

    %Def{} = synthdef = parse_synthdef(name, params, expressions, %Def{})

    compiled = Compile.compile(synthdef)
    Manager.create_synth(name, compiled)

    quote do
      {unquote(Macro.escape(synthdef)), unquote(compiled)}
    end
  end

  defp parse_synthdef_name(name) do
    to_string(name) |> String.split() |> List.last() |> Recase.to_kebab()
  end

  defp parse_synthdef(name, params, lines, %Def{synthdefs: synths} = sdef) do
    param_names = Keyword.keys(params) |> Enum.map(&to_string(&1))

    param_values =
      Keyword.values(params)
      |> Enum.map(fn p ->
        {result, _} = Code.eval_quoted(p)
        result
      end)

    unless Enum.all?(param_values, &is_number(&1)) do
      raise "Default param values must be numbers: #{Macro.to_string(params)}"
    end

    param_values = param_values |> Enum.map(&(&1 + 0.0))
    control_outputs = Enum.map(param_values, fn _ -> 1 end)

    control =
      if Enum.count(params) > 0 do
        [%Ugen{name: "Control", rate: 1, special: 0, outputs: control_outputs}]
      else
        []
      end

    parameters =
      Keyword.keys(params)
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        {name, %Input{src: 0, constant_index: i}}
      end)
      |> Enum.into(%{})

    {synth, _} =
      Parse.parse(
        %Synth{
          name: name,
          constants: [],
          param_names: param_names,
          param_values: param_values,
          parameters: parameters,
          assigns: %{},
          ugens: control
        },
        lines
      )

    %{sdef | synthdefs: [synth | synths]}
  end
end
