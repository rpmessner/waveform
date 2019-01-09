defmodule Waveform.Synth.Def.Envelope do
  defmodule Done do
    def none, do: 0
    def pause_self, do: 1
    def free_self, do: 2
    def free_self_and_prev, do: 3
    def free_self_and_next, do: 4
    def free_self_and_free_all_in_prev, do: 5
    def free_self_and_free_all_in_next, do: 6
    def free_self_to_head, do: 7
    def free_self_to_tail, do: 8
    def free_self_pause_prev, do: 9
    def free_self_pause_next, do: 10
    def free_self_and_deep_free_prev, do: 11
    def free_self_and_deep_free_next, do: 12
    def free_all_in_group, do: 13
    def free_group, do: 14
    def free_self_resume_next, do: 15
  end

  @curves %{
    step: 0,
    lin: 1,
    linear: 1,
    exp: 2,
    exponential: 2,
    sin: 3,
    sine: 3,
    wel: 4,
    welch: 4,
    sqr: 6,
    squared: 6,
    cub: 7,
    cubed: 7,
    hold: 8
  }

  @release -99
  @loop -99
  @peak_level 1.0
  @curve -4.0
  @bias 0.0
  @attack_time 0.01
  @decay_time 0.3
  @sustain_level 0.5
  @release_time 1.0

  def asr(options) do
    curve = Keyword.get(options, :curve, @curve)
    attack_time = Keyword.get(options, :attack_time, @attack_time)
    sustain_level = Keyword.get(options, :sustain_level, @sustain_level)
    release_time = Keyword.get(options, :release_time, @release_time)

    new(
      [0, sustain_level, 0],
      [attack_time, release_time],
      [curve, curve],
      1
    )
  end

  def adsr(options) do
    peak_level = Keyword.get(options, :peak_level, @peak_level)
    curve = Keyword.get(options, :curve, @curve)
    bias = Keyword.get(options, :bias, @bias)
    attack_time = Keyword.get(options, :attack_time, @attack_time)
    decay_time = Keyword.get(options, :decay_time, @decay_time)
    sustain_level = Keyword.get(options, :sustain_level, @sustain_level)
    release_time = Keyword.get(options, :release_time, @release_time)

    [
      bias,
      {:+, [], [peak_level, bias]},
      {:+, [], [{:*, [], [peak_level, sustain_level]}, bias]},
      bias
    ]
    |> new([attack_time, decay_time, release_time], [curve, curve, curve], 2, @loop)
  end

  def new([i1 | inputs], times, curves) when is_list(curves),
    do: new([i1 | inputs], times, curves, @release, @loop)

  def new([i1 | inputs], times, curve) when is_atom(curve),
    do: new([i1 | inputs], times, curve, @release, @loop)

  def new([i1 | inputs], times, curves, release) when is_list(curves),
    do: new([i1 | inputs], times, curves, release, @loop)

  def new([i1 | inputs], times, curve, release) when is_atom(curve),
    do: new([i1 | inputs], times, curve, release, @loop)

  def new([i1 | rest], times, curves, release, loop) when is_list(curves) do
    [i1, Enum.count(rest), release, loop] ++
      Enum.map(0..(Enum.count(rest) - 1), fn n ->
        [Enum.at(rest, n), Enum.at(times, n), 5, Enum.at(curves, n)]
      end)
  end

  def new([i1 | rest], times, curve, release, loop) do
    curve =
      if is_atom(curve) do
        Map.get(@curves, curve, 5)
      else
        curve
      end

    [i1, Enum.count(rest), release, loop] ++
      Enum.map(0..(Enum.count(rest) - 1), fn n ->
        [Enum.at(rest, n), Enum.at(times, n), curve, 0]
      end)
  end
end
