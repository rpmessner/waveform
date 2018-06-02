deftrack :quarters, beats: 4, over: 4 do #, effects: [{:reverb, amp: 1}] do
  %{beat: 1} -> play :c4, :major
  %{beat: 2} -> play :g4, :major
  %{beat: 3} -> play :e4, :minor
  %{beat: 4} -> play :a4, :minor #doesn't get played
end

