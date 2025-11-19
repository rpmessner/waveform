defmodule Waveform.Synth do
  @moduledoc """
  High-level API for triggering synths in SuperCollider.

  This module provides a simple interface for playing notes and synths
  via OSC messaging. It handles node allocation, group management, and
  basic parameter normalization.

  ## Examples

      # Trigger a synth with a MIDI note number
      Synth.trigger("my-synth", note: 60, amp: 0.5)

      # Trigger with specific node and group IDs
      Synth.trigger("my-synth", [note: 60], node_id: 1001, group_id: 1)

      # Play a note by name (requires Harmony library)
      Synth.play("c4", synth: "saw", amp: 0.8)
  """

  alias Waveform.OSC
  alias Waveform.OSC.Group
  alias Waveform.OSC.Node

  @doc """
  Trigger a synth with the given name and parameters.

  ## Parameters
  - `synth_name` - Name of the SuperCollider synth to trigger (string or charlist)
  - `params` - Keyword list of synth parameters
  - `opts` - Options for node and group (optional)
    - `:node_id` - Specific node ID (defaults to auto-allocated)
    - `:group_id` - Target group ID (defaults to process-specific group)
    - `:action` - Add action (defaults to :head)

  ## Examples

      Synth.trigger("saw", note: 60, amp: 0.5)
      Synth.trigger("kick", amp: 0.8, group_id: 10)
  """
  def trigger(synth_name, params \\ [], opts \\ []) do
    node_id = opts[:node_id] || Node.next_synth_node().id
    group_id = opts[:group_id] || Group.synth_group(self()).id
    action = opts[:action] || :head

    # Normalize params to flat list: [:key1, value1, :key2, value2, ...]
    normalized_params = normalize_params(params)

    OSC.new_synth(to_charlist(synth_name), node_id, action, group_id, normalized_params)

    %{node_id: node_id, group_id: group_id}
  end

  @doc """
  Play a note using a synth.

  This is a convenience function that adds a `:note` parameter.
  If the Harmony library is available, you can pass note names like "c4".

  ## Examples

      # With MIDI number
      Synth.play(60, synth: "saw", amp: 0.5)

      # With note name (requires Harmony)
      Synth.play("c4", synth: "piano")
  """
  def play(note, opts \\ [])

  def play(note, opts) when is_binary(note) do
    if Code.ensure_loaded?(Harmony.Note) do
      midi = Harmony.Note.get(note).midi
      play(midi, opts)
    else
      raise "Harmony library not available. Use MIDI numbers instead or add {:harmony, ...} to deps."
    end
  end

  def play(note, opts) when is_number(note) do
    synth_name = opts[:synth] || "default"
    params = Keyword.merge([note: note], Keyword.delete(opts, :synth))

    trigger(synth_name, params)
  end

  # Normalize parameters to the flat list format expected by OSC
  defp normalize_params(params) when is_list(params) do
    Enum.reduce(params, [], fn {key, value}, acc ->
      if is_number(value) do
        [key, value | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end
end
