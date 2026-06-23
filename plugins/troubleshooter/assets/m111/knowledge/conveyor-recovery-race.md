# Conveyor Recovery Race After Load Failure

## Symptoms

- Mini / OmniSort conveyor or lift resumes an upstream error while the robot load or unload failure has not fully reported.
- The lift changes floor or begins forced discharge before the physical parcel state and robot state converge.
- Operator sequence includes manual recovery of conveyor overheight, throw failure, or load failure within seconds.

## Fault Tree

- Confirmed branch: recovery ordering race.
  - In `m111-pt-0037`, conveyor overheight was restored at `2026-04-10 14:58:05`, robot throw failure was restored at `14:58:08`, and robot load failure was reported at `14:58:14`.
  - Visible source states the lift was still on floor 1 when conveyor overheight was restored, then rose to floor 2 before the robot reported load error.
- Likely branch: missing interlock between conveyor recovery and robot load-failure acknowledgement.
  - Do not allow conveyor/lift recovery to advance floor or force-discharge while the paired robot station action is still unresolved.
- Blocked branch: media-only confirmation of exact lift movement.
  - Videos were downloaded, but source text already carries the key timing and fix statement.

## Evidence Needed

- Operator recovery timestamps for conveyor error and robot error.
- Robot ID, site number, lift floor, parcel physical location before and after recovery.
- RCS / conveyor state-machine logs around `restore error`, `load fail`, `throw fail`, `force throw`, and lift floor transition.
- Video is useful to confirm physical floor/parcel state, but must not replace state-machine timestamps.

## Logs And Files To Inspect

- Conveyor / lift controller logs for error recovery and floor transitions.
- RCS scheduler logs for robot action lifecycle: begin load, load success/fail, begin throw, throw success/fail.
- UI operation logs showing manual recovery order.
- Local assets: `assets/m111-pt-0037/001-source-EFhBbisIhoCFqGxNAl7cRXylnbg.mp4`, `assets/m111-pt-0037/002-source-JkY4bSPhHopVVrx9RYscnP75nyf.mp4`.

## Likely Causes

- Recovery handler clears conveyor error without checking whether the current robot-station transaction has reached a terminal state.
- Lift floor transition is triggered from conveyor error recovery rather than from a synchronized parcel ownership state.
- Manual recovery sequence exposes a race that normal happy-path testing misses.

## Exclusion Checks

- Exclude pure sensor fault only if logs show the state machine advanced before any sensor inconsistency.
- Exclude robot hardware fault if the robot correctly reports throw/load failure and the bad behavior occurs during conveyor recovery.
- Exclude operator error only if the software explicitly permits the recovery sequence without guarding parcel ownership.

## Confirmed Examples

- `m111-pt-0037`: two parcels with same destination. Simulated robot throw failure, conveyor overheight, then load failure. The source says code was modified and the issue was fixed.

## Unresolved Examples

- None in this knowledge file.

## Specialist Routing

- Start with `scheduler-traffic` for action lifecycle and interlock timing.
- Add `mantis-handling` / handling specialist for lift floor and parcel physical state.
- Use `vision-media` only to confirm the observed parcel/floor sequence.
