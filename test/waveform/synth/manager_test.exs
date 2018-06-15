defmodule Waveform.Synth.ManagerTest do
  use ExUnit.Case

  alias Waveform.Synth.Manager, as: Subject

  setup do
    on_exit(fn ->
      Subject.reset()
    end)

    :ok
  end

  test "defaults synth" do
    assert Subject.current_synth_name(self()) == :prophet
    assert Subject.current_synth_value(self()) == 'sonic-pi-prophet'
  end

  test "sets current synth" do
    assert Subject.current_synth_name(self()) == :prophet
    assert Subject.current_synth_value(self()) == 'sonic-pi-prophet'

    Subject.set_current_synth(self(), :tb303)

    assert Subject.current_synth_name(self()) == :tb303
    assert Subject.current_synth_value(self()) == 'sonic-pi-tb303'
  end

  test "does't set unknown synth" do
    assert Subject.current_synth_name(self()) == :prophet
    Subject.set_current_synth(self(), :wtf_is_this)
    assert Subject.current_synth_name(self()) == :prophet
    assert Subject.current_synth_value(self()) == 'sonic-pi-prophet'
  end

  test "remembers last synth" do
    assert Subject.current_synth_name(self()) == :prophet
    Subject.set_current_synth(self(), :tb303)
    assert Subject.current_synth_name(self()) == :tb303
    Subject.use_last_synth(self())
    assert Subject.current_synth_name(self()) == :prophet
    assert Subject.current_synth_value(self()) == 'sonic-pi-prophet'
  end

  test "doensn't forget default" do
    assert Subject.current_synth_name(self()) == :prophet
    Subject.use_last_synth(self())
    assert Subject.current_synth_name(self()) == :prophet
  end
end
