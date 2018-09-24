defmodule Waveform.Music.TransposeTest do
  use ExUnit.Case

  alias Waveform.Music.Transpose, as: Subject

  test "transposes roman numeral root note" do
    assert :c = Subject.transpose_roman(:c, :I)
    assert :d = Subject.transpose_roman(:c, :II)
    assert :d = Subject.transpose_roman(:c, :ii)
    assert :e = Subject.transpose_roman(:c, :iii)
    assert :f = Subject.transpose_roman(:c, :IV)
    assert :f = Subject.transpose_roman(:c, :iv)
    assert :g = Subject.transpose_roman(:c, :v)
    assert :a = Subject.transpose_roman(:c, :vi)
    assert :b = Subject.transpose_roman(:c, :vii)
    assert :a = Subject.transpose_roman(:bb, :vii)
  end

  test "transposes simple notes" do
    assert :c = Subject.transpose_note(:c, "1P")
    assert :bb = Subject.transpose_note(:bb, "1P")
    assert :c = Subject.transpose_note(:bb, "2M")

    # assert Subject.transpose_note(:"c4", "1P") = :"c4"
    # assert Subject.transpose_note(:"bb4", "1P") = :"bb4"
    # assert Subject.transpose_note(:"bb4", "2P") = :"c5"
  end
end
