defmodule Waveform.Music.FormTest do
  use ExUnit.Case

  alias Waveform.Music.Chord, as: Chord
  alias Waveform.Music.Form, as: Subject

  require Subject
  import Subject

  describe "Simple Blues" do
    defform SimpleBlues do
      beats_per_measure(4)
      key(:g)
      octave(5)

      measures(:I7, :IV7, :I7, :I7, :IV7, :IV7, :I7, :I7, :V7, :IV7, :I7, :V7)
    end

    test "can return chord at beat 1" do
      assert %Chord{tonic: :g5, quality: :dom7, inversion: 0} = SimpleBlues.chord_at(beat: 1)
    end

    test "respects inversion value" do
      assert %Chord{tonic: :g5, quality: :dom7, inversion: 1} =
               SimpleBlues.chord_at(beat: 1, inversion: 1)
    end

    test "respects octave value" do
      assert %Chord{
               tonic: :g6,
               quality: :dom7,
               inversion: 1
             } = SimpleBlues.chord_at(beat: 1, inversion: 1, octave: 6)
    end

    test "finds chord at measure" do
      assert %Chord{tonic: :g5, quality: :dom7, inversion: 0} = SimpleBlues.chord_at(measure: 1)
    end

    test "finds chord in next measure by beat" do
      assert %Chord{tonic: :c5, quality: :dom7, inversion: 0} = SimpleBlues.chord_at(beat: 5)
    end

    test "finds chord in future measure by beat" do
      assert %Chord{tonic: :c5, quality: :dom7, inversion: 0} =
               SimpleBlues.chord_at(measure: 6, beat: 1)

      assert %Chord{tonic: :d5, quality: :dom7, inversion: 0} =
               SimpleBlues.chord_at(measure: 9, beat: 1)
    end
  end

  describe "Rhythm Changes" do
    defform RhythmChanges do
      beats_per_measure(4)
      octave(5)
      key(:bb)

      part(:A)

      measures(
        {:IM7, :vim7},
        {:iim7, :V7},
        {:iiim7, :vim7},
        {:iim7, :V7},
        {:iim7, :V7, of: :IV},
        {:IVM7, :VIIb7},
        {:iiim7, :vim7},
        {:iim7, :V7}
      )

      # part :B
      # measures {:iim7, of: :III}, {:V7, of: :III},
      #          {:iim7, of: :VI}, {:V7, of: :VI},
      #          {:iim7, of: :II}, {:V7, of: :II},
      #          :iim7, :V7

      # form :A, :A, :B, :A
    end

    test "can return chord at beat and/or measure" do
      assert %Chord{tonic: :bb5, quality: :maj7, inversion: 0} = RhythmChanges.chord_at(beat: 1)

      assert %Chord{tonic: :bb5, quality: :maj7, inversion: 0} =
               RhythmChanges.chord_at(measure: 1)

      assert %Chord{tonic: :g5, quality: :min7, inversion: 0} =
               RhythmChanges.chord_at(measure: 1, beat: 3)
    end

    test "can tanspose chord at beat and/or measure" do
      assert %Chord{tonic: :f5, quality: :min7, inversion: 0} =
               RhythmChanges.chord_at(measure: 5, beat: 1)

      assert %Chord{tonic: :f5, quality: :min7, inversion: 0} =
               RhythmChanges.chord_at(measure: 5, beat: 2)

      assert %Chord{tonic: :bb5, quality: :dom7, inversion: 0} =
               RhythmChanges.chord_at(measure: 5, beat: 3)

      assert %Chord{tonic: :bb5, quality: :dom7, inversion: 0} =
               RhythmChanges.chord_at(measure: 5, beat: 4)
    end

    test "respects octave & inversion value" do
      assert %Chord{
               tonic: :bb6,
               quality: :maj7,
               inversion: 1
             } = RhythmChanges.chord_at(beat: 1, inversion: 1, octave: 6)
    end

    test "finds chord in next measure by beat" do
      assert %Chord{tonic: :c5, quality: :min7, inversion: 0} = RhythmChanges.chord_at(beat: 5)
    end
  end

  # describe "Trane Changes" do
  #   defform GiantSteps do
  #     beats_per_measure 4
  #     key :b

  #     measures(
  #       {:IM7, beats: 2},
  #       {:V7, :IM7, of: :III},
  #       {:V7, beats: 2, of: :vi}, {:IM7, of: :vi},
  #       {:iim7, :V7, :IM7, of: :III, beats: 6},
  #       {:V7, :IM7, of: :vi},
  #       {:V7, beats: 2}, {:IM7},
  #       {:iim7, :V7, of: :vi}, {:IM7, of: :vi},
  #       {:iim7, :V7, of: :III}, {:IM7, of: :III},
  #       {:iim7, :V7}, {:IM7},
  #       {:iim7, :V7, of: :vi}, {:IM7, of: :vi},
  #       {:iim7, :V7}
  #     )
  #   end
  # end
  # describe "Windows Chick Corea" do
  #   defform Windows do
  #     beats_per_measure 4
  #     key :b

  #     measures(
  #       part: :a,
  #       :im7,
  #   end
  # end
end
