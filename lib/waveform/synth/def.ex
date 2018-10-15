defmodule Waveform.Synth.Def do
  alias Waveform.Synth.Def.Submodule, as: Submodule
  alias Waveform.Synth.Def.Compile, as: Compile
  alias Waveform.Synth.Def.Expression, as: Expression

  alias Waveform.Synth.Manager, as: Manager

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

      #internal state
      arguments: []
    )
  end

  defmodule Ugen.Input do
    defstruct(
      src: nil,
      constant_index: nil
    )
  end

  alias Ugen.Input, as: Input

  @ugens Def.Ugens.definitions

  defmacro defsubmodule({_, _, [name]}, params, do: {:__block__, _, submodule_forms}) do
    submodule = Submodule.define(name, params, submodule_forms)

    quote do
      unquote(Macro.escape(submodule))
    end
  end

  defmacro defsynth({_, _, [name]}, params, do: {:__block__, _, ugen_forms}) do
    name = parse_synthdef_name(name)

    %Def{} = synthdef = parse_synthdef(name, params, ugen_forms, %Def{})

    compiled = Compile.compile(synthdef)
    Manager.create_synth(name, compiled)

    quote do
      { unquote(Macro.escape(synthdef)), unquote(compiled) }
    end
  end

  def parse_synthdef_name(name) do
    to_string(name) |> String.split() |> List.last() |> Recase.to_kebab()
  end

  def parse_synthdef(name, params, lines, %Def{synthdefs: synths} = sdef) do
    param_names = Keyword.keys(params) |> Enum.map(&to_string(&1))
    param_values = Keyword.values(params) |> Enum.map(fn p ->
      {result, _ } = Code.eval_quoted(p)
      result
    end)

    unless Enum.all?(param_values, &is_number(&1)) do
      raise "Default param values must be numbers: #{Macro.to_string(params)}"
    end

    param_values = param_values |> Enum.map(&(&1 + 0.0))
    control_outputs = Enum.map(param_values, fn _ -> 1 end)

    control = %Ugen{name: "Control", rate: 1, special: 0, outputs: control_outputs}

    parameters =
      Keyword.keys(params)
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        {name, %Input{src: 0, constant_index: i}}
      end)
      |> Enum.into(%{})

    synth =
      parse_lines(
        %Synth{
          name: name,
          constants: [],
          param_names: param_names,
          param_values: param_values,
          parameters: parameters,
          assigns: %{},
          ugens: [control]
        },
        lines
      )

    %{sdef | synthdefs: [synth | synths]}
  end

  defp parse_lines(%Synth{} = synth, []), do: synth

  defp parse_lines(%Synth{} = synth, [line | rest]) do
    case line do
      {op, _, [{assign_name, _, nil}, expression]} when op in [:<-, :=] ->
        parse_assignment(synth, assign_name, expression)

      _ ->
        raise "cannot parse line #{Macro.to_string(line)}"
    end
    |> parse_lines(rest)
  end

  defp parse_assignment(%Synth{} = synth, output_name, expression) do
    {%Synth{assigns: assigns} = synth, input} =
      case expression do
        {:%, _, _} = ugen ->
          synth = parse_ugen(synth, ugen)

          {
            synth,
            %Input{src: Enum.count(synth.ugens) - 1, constant_index: 0}
          }

        _ ->
          Expression.parse(synth, expression)
      end

    assigns = Map.put(assigns, output_name, input)

    %{synth | assigns: assigns}
  end

  @kr %{outputs: [1], rate: 1, special: 0}
  @ar %{outputs: [2], rate: 2, special: 0}

  defp build_ugen(name, base), do: build_ugen(name, base, priority: :low)
  defp build_ugen(name, base, priority: priority) do
    ugen_def = Map.get(@ugens, name)

    unless ugen_def, do: raise "Unknown or unimplemented ugen #{name}"

    %{defaults: ugen_base, arguments: arguments} = ugen_def
    ugen_name = %{name: to_string(name)}

    options = if priority == :high do
      [base, ugen_base, ugen_name]
    else
      [ugen_base, base, ugen_name]
    end

    ugen = Enum.reduce(options, %{}, &Map.merge(&1, &2))
    { ugen, arguments }
  end

  defp parse_ugen_name(ugen_name) do
    {ugen_opts, arguments} = case ugen_name do
      {:__aliases__, _, [name]} ->
        build_ugen(name, @kr)

      {{:., _, [{:__aliases__, _, [name]}, :kr]}, _, _} ->
        build_ugen(name, @kr, priority: :high)

      {{:., _, [{:__aliases__, _, [name]}, :ar]}, _, _} ->
        build_ugen(name, @ar, priority: :high)

      _ ->
        IO.inspect("error") && raise "can't parse #{Macro.to_string(ugen_name)}"
    end

    { struct(Ugen, ugen_opts), arguments }
  end

  defp parse_submodule(synth, name, _options) do
    case name do
      {:__aliases__, _, [name]} ->
        submodule = Submodule.lookup(name)

        if submodule do
          parse_lines(synth, submodule.forms)
        end
      _ -> nil
    end
  end

  defp parse_ugen(
         %Synth{} = synth,
         {:%, _,
          [
            ugen_name,
            {:%{}, _, options}
          ]} = ugen
       ) do

    case parse_submodule(synth, ugen_name, options) do
      nil ->
        { ugen, arguments } = parse_ugen_name(ugen_name)

        # sort options by order of arguments list
        options =
          Enum.sort_by(options, fn {key, _value} ->
            Enum.find_index(arguments, &(&1 == key))
          end)

        {
          ugen,
          %Synth{ugens: ugens} = synth,
          _
        } = parse_ugen_options({ugen, synth, options})

        %{synth | ugens: ugens ++ [ugen]}
      synth -> synth
    end
  end

  defp parse_ugen_options({%Ugen{} = ugen, %Synth{} = synth, []}), do: {ugen, synth, []}

  defp parse_ugen_options({
         %Ugen{inputs: inputs} = ugen,
         synth,
         [{_, expression} | rest_options]
       }) do
    {%Synth{} = synth, input} = Expression.parse(synth, expression)

    parse_ugen_options({
      %{ugen | inputs: List.flatten(inputs ++ [input])},
      synth,
      rest_options
    })
  end
end
