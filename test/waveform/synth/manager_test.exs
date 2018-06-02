defmodule Waveform.Synth.ManagerTest do
  use ExUnit.Case

  alias Waveform.Synth.Manager, as: Subject

  setup do
    Subject.reset()
    :ok
  end

  test "defaults synth" do
    assert Subject.current_synth_name() == :prophet
    assert Subject.current_synth_value() == 'sonic-pi-prophet'
  end

  test "sets current synth" do
    assert Subject.current_synth_name() == :prophet
    assert Subject.current_synth_value() == 'sonic-pi-prophet'
    Subject.set_current_synth(:tb303)
    assert Subject.current_synth_name() == :tb303
    assert Subject.current_synth_value() == 'sonic-pi-tb303'
  end

  test "does't set unknown synth" do
    assert Subject.current_synth_name() == :prophet
    Subject.set_current_synth(:wtf_is_this)
    assert Subject.current_synth_name() == :prophet
    assert Subject.current_synth_value() == 'sonic-pi-prophet'
  end

  test "remembers last synth" do
    assert Subject.current_synth_name() == :prophet
    Subject.set_current_synth(:tb303)
    assert Subject.current_synth_name() == :tb303
    Subject.use_last_synth()
    assert Subject.current_synth_name() == :prophet
    assert Subject.current_synth_value() == 'sonic-pi-prophet'
  end

  test "doensn't forget default" do
    assert Subject.current_synth_name() == :prophet
    Subject.use_last_synth()
    assert Subject.current_synth_name() == :prophet
  end
end
