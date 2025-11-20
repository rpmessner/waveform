# Pattern Scheduler - Concrete Walkthrough

This document walks through **exactly** how the pattern scheduler works with a real example.

## The Setup

```elixir
# Start the scheduler
PatternScheduler.start_link(cps: 0.5)  # One cycle every 2 seconds

# Schedule a simple pattern
PatternScheduler.schedule_pattern(:drums, [
  {0.0, [s: "bd"]},    # Bass drum at start
  {0.5, [s: "sd"]}     # Snare drum at middle
])
```

## Timeline: What Happens Second-by-Second

### **T = 0.000s** (Scheduler starts)

```elixir
State = %{
  start_time: 0,           # Reference point
  cps: 0.5,                # Half a cycle per second
  patterns: %{
    drums: %Pattern{
      events: [{0.0, [s: "bd"]}, {0.5, [s: "sd"]}],
      active: true
    }
  },
  scheduled_events: #MapSet<[]>  # Nothing sent yet
}
```

The scheduler immediately sends itself a `:tick` message to run in 10ms.

---

### **T = 0.010s** (First tick!)

**Step 1: Where are we in musical time?**
```elixir
elapsed_time = 0.010s
current_cycle = 0.010s * 0.5 cps = 0.005 cycles
```

**Step 2: Where will we be after latency?**
```elixir
latency = 0.02s (20ms from SuperDirt)
latency_cycles = 0.02s * 0.5 cps = 0.01 cycles
look_ahead_cycle = 0.005 + 0.01 = 0.015 cycles
```

**Step 3: What events fall in window [0.005, 0.015]?**

Pattern drums has two events:
- Event 1: cycle position 0.0 → occurs at cycles 0.0, 1.0, 2.0, ...
- Event 2: cycle position 0.5 → occurs at cycles 0.5, 1.5, 2.5, ...

Check Event 1 (position 0.0):
```
First occurrence >= 0.005 is at cycle 1.0
Is 1.0 in [0.005, 0.015]? NO
Skip
```

Check Event 2 (position 0.5):
```
First occurrence >= 0.005 is at cycle 0.5
Is 0.5 in [0.005, 0.015]? NO
Skip
```

**Result:** No events scheduled this tick.

**Step 4:** Schedule next tick in 10ms.

---

### **T = 0.020s** (Second tick)

```elixir
current_cycle = 0.020 * 0.5 = 0.010 cycles
look_ahead_cycle = 0.010 + 0.01 = 0.020 cycles
```

**Window: [0.010, 0.020]**

Still no events in this window (closest is 0.5). Skip.

---

### **T = 0.990s** (Tick #99)

```elixir
current_cycle = 0.990 * 0.5 = 0.495 cycles
look_ahead_cycle = 0.495 + 0.01 = 0.505 cycles
```

**Window: [0.495, 0.505]** ← This is interesting!

Check Event 1 (position 0.0):
```
First occurrence >= 0.495 is at cycle 1.0
Is 1.0 in [0.495, 0.505]? NO
```

Check Event 2 (position 0.5):
```
First occurrence >= 0.495 is at cycle 0.5
Is 0.5 in [0.495, 0.505]? YES! ✅
```

**SCHEDULE IT!**

```elixir
event_id = {:drums, 0.5, 0.5}  # {pattern, cycle, position}

# Check if already sent
MapSet.member?(scheduled_events, event_id)?
# => false (first time)

# Send to SuperDirt!
SuperDirt.play([s: "sd"])
# This creates an OSC bundle timestamped for ~1.0 seconds from now

# Mark as scheduled
scheduled_events = MapSet.put(scheduled_events, event_id)
```

**Result:** Snare scheduled! It will play at T ≈ 1.000s.

---

### **T = 1.000s** - **🥁 SNARE PLAYS!**

The snare drum actually sounds because SuperDirt received the timestamped bundle 10ms ago.

---

### **T = 1.990s** (Tick #199 - almost at cycle 1.0)

```elixir
current_cycle = 1.990 * 0.5 = 0.995 cycles
look_ahead_cycle = 0.995 + 0.01 = 1.005 cycles
```

**Window: [0.995, 1.005]** ← Crossing into cycle 1!

Check Event 1 (position 0.0):
```
First occurrence >= 0.995 is at cycle 1.0
Is 1.0 in [0.995, 1.005]? YES! ✅
```

**SCHEDULE IT!**

```elixir
event_id = {:drums, 1.0, 0.0}

SuperDirt.play([s: "bd"])
# Timestamped for T ≈ 2.000s

scheduled_events = MapSet.put(scheduled_events, event_id)
```

Check Event 2 (position 0.5):
```
First occurrence >= 0.995 is at cycle 1.5
Is 1.5 in [0.995, 1.005]? NO
```

**Result:** Bass drum scheduled for cycle 1.0!

---

### **T = 2.000s** - **🥁 BASS DRUM PLAYS!**

The pattern loops! This is the start of cycle 1.

---

### **T = 2.990s** (Crossing to cycle 1.5)

Same logic - schedule the snare at cycle 1.5.

---

### **T = 3.990s** (Crossing to cycle 2.0)

Schedule bass drum at cycle 2.0.

**And so on forever!** 🔄

---

## Key Insights

### 1. **Look-Ahead Window**

The window is tiny (0.01 cycles = 0.02 seconds). We only schedule events that are about to happen.

```
[past...] [current] [look-ahead: 20ms] [future...]
           ^         ^-- We schedule anything here
           |-- We are here
```

### 2. **Deduplication via MapSet**

Multiple ticks might see the same event:

```
Tick at T=0.990s sees event at cycle 0.5 ✅ Sends it
Tick at T=1.000s sees event at cycle 0.5 ❌ Already in MapSet, skips
Tick at T=1.010s sees event at cycle 0.5 ❌ Already in MapSet, skips
```

The `event_id` tuple `{:drums, 0.5, 0.5}` ensures we only send once.

### 3. **Tempo Changes are Instant**

```elixir
PatternScheduler.set_cps(1.0)  # Double the speed!
```

Next tick:
```elixir
current_cycle = elapsed_time * 1.0  # Now going 2x faster
```

Already-scheduled events keep their timestamps, but future events use the new tempo immediately.

### 4. **Hot-Swapping Patterns**

```elixir
PatternScheduler.update_pattern(:drums, [
  {0.0, [s: "bd"]},
  {0.25, [s: "cp"]},  # Add a clap
  {0.5, [s: "sd"]},
  {0.75, [s: "cp"]}   # Add another clap
])
```

Next tick uses the new pattern. Already-scheduled events from the old pattern will still play, but after that it switches seamlessly.

---

## Why This Design Works

1. **Small tick interval** (10ms) → Responsive, catches events quickly
2. **Cycle-based math** → No drift over time, tempo changes are instant
3. **Look-ahead + OSC bundles** → Smooth playback, no jitter
4. **MapSet deduplication** → Never sends duplicates
5. **Immutable state** → Hot-swapping is safe and predictable

---

## Performance

**Per tick overhead:**
- Calculate 2 floats (current_cycle, look_ahead_cycle)
- For each pattern:
  - For each event:
    - Check if in window (usually not)
    - If yes: MapSet lookup + SuperDirt.play call

**Typical case** (3 patterns, 8 events each, 10ms ticks):
- ~100 ticks per second
- ~2400 window checks per second
- ~1-5 actual events scheduled per second

This is trivial for the BEAM VM!

---

## Next: What KinoSpaetzle Adds

The scheduler is now complete! KinoSpaetzle will:

1. **Parse Uzu patterns** (`"bd cp sd cp"` → events list)
2. **Call the scheduler** (`PatternScheduler.schedule_pattern(:p1, events)`)
3. **Provide UI** (play/stop buttons, code editor)
4. **Handle hot-swapping** (re-evaluate pattern on each play)

The hard part (precise scheduling) is done! 🎉
