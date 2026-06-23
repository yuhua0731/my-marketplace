# Baffle Raise Pause Completion Flag Recovery Failure

source_case: `component-test-pt-0117`
status: runtime routing rules for baffle robot recovery after throw failure, pause during baffle raise, and missing completion flag

## Symptoms

- After baffle robot throw/unload failure, recovery is performed.
- On the next loading attempt, the baffle is still raised or rises again, causing receiving/loading failure.
- The source time is `2026-05-07 17:21:19`; local NXP log covers the corresponding `2026-05-07T09:21Z` window.
- Source analysis says baffle raise is performed after movement, but the completion flag was also set only in the movement state.
- If pause is pressed before baffle raise completes, pause state does not receive or process the baffle-raise completion event, so the completion flag is not set.
- On the next movement, the unset/stale completion flag causes the baffle to rise again.

## Fault Tree

1. Reconstruct the handling sequence before blaming hardware.
   - Look for loading/throw failure, force-unload/recovery, move, baffle-up, pause, resume, and next loading attempt.
   - In `component-test-pt-0117`, the case body reports throw failure followed by recovery, then loading failure because the baffle was raised.
2. Check whether baffle-up is coupled to movement-state completion.
   - If `BeltGateFSM::Up` or equivalent baffle-up transition completes after movement has already been interrupted or paused, verify where the completion flag is set.
   - Completion must be set when the baffle-up state completes, not only while the parent movement state is active.
3. Treat pause/resume as an interleaving branch.
   - Pause during actuator motion can suppress state-specific completion handling if the event is only consumed in the original movement state.
   - Recovery code must either consume late actuator-complete events in pause/recovery states or persist actuator completion independently of the movement state.
4. Separate state-machine defect from communication or mechanical faults.
   - If the baffle motor reports completed `UP`, CAN/motor command path is not the primary suspect.
   - If the next loading fails only because the baffle is raised, inspect state flags and recovery sequencing before motor replacement.
5. Validate with both failure and post-fix evidence.
   - The source resolution is to set completion status when baffle raise state completes.
   - Follow-up says the fix was verified.

## Evidence From `component-test-pt-0117`

- Case body: symptom is `挡板机器人抛货失败后，恢复流程后挡板是升起状态导致接货失败`.
- Case body analysis: `挡板升起是在移动后进行的，完成标志也是在移动状态进行设置。测试时挡板还没有完成被按下了暂停，进入暂停状态后就收不到挡板上升完成的状态，无法设置完成标志，导致下次移动后挡板再次升起。`
- Case body resolution: `在挡板上升状态完成后设置完成状态。`
- NXP log `retry-source-EFdlb9yFroMUU1x9La5caN0Pnge.log`: 23,677 lines, timestamp range `2026-05-07T08:30:35Z` to `2026-05-07T09:39:34Z`.
- Target window:
  - `2026-05-07T09:20:14Z`: `SortHandlingFSM::Loading` enters `fault`; `handling error, reason 3, sensor a 0, sensor b 0`; controller enters `MainController::Fault`.
  - `2026-05-07T09:20:19Z`: controller transitions `MainController::Fault -> Handle`; `SortHandlingFSM::ForceUnloading` starts.
  - `2026-05-07T09:20:25Z`: force unloading terminates and controller returns to idle.
  - `2026-05-07T09:20:29Z`: a new loading cycle completes, then controller enters `Move`.
  - `2026-05-07T09:20:30Z`: `BeltGateFSM` transitions `idle -> BeltGateFSM::Up`; later `Gate status set to: UP`; movement then transitions to `Ack`.
- Video representative frames:
  - `retry-source-Zed3bawEsovwSIxowcMci27engd.mov`: QuickLook frame shows baffle robot/line with red status reflection.
  - `retry-source-QYxGbisD8oHwfkxZdHXcRM1In9d.mov`: QuickLook frame shows the same station with green status reflection after reported fix verification.

## Evidence Needed

- Case body analysis and exact reported timestamp.
- NXP or controller log covering loading fault, recovery/force-unload, next move, baffle-up, and next loading attempt.
- Failure video and post-fix video or representative frames showing baffle position and status light.
- Source diff or firmware trace proving where the baffle-up completion flag is written.
- Pause/resume reproduction where pause is pressed while baffle-up is still moving.
- Raw CAN/candump only if actuator command or feedback timing remains suspect after state-machine review.

## Evidence Gaps

- No source code diff or commit is attached; exact state-machine implementation is inferred from case analysis.
- The `.hex` firmware is present and hash-recorded, but cannot be symbol-decoded locally.
- Local machine lacks `ffmpeg`/`ffprobe`; video review used QuickLook representative frames only, not frame-by-frame timing.
- The log contains frequent `CO_SDOclientUpload error: -11, index 6064 sub_index 0 node_id 1` entries; these are not proven to cause this handling failure.
- Pause command is not printed as a decoded text log line in the inspected window; pause interleaving comes from source analysis.

## Logs And Files To Inspect

- Search terms: `SortHandlingFSM::Loading`, `ForceUnloading`, `MainController::Fault`, `MainController::Idle -> Move`, `BeltGateFSM::Up`, `Gate status set to: UP`, `got gate evt 20`, `Ack`, `pause`, `resume`, `完成标志`, `暂停状态`.
- NXP log window around reported local time `2026-05-07 17:21:19`, equivalent to `2026-05-07T09:21Z` when logs are UTC.
- Video/frame evidence from `retry-source-Zed3bawEsovwSIxowcMci27engd.mov` and `retry-source-QYxGbisD8oHwfkxZdHXcRM1In9d.mov`.
- Firmware/source diff around baffle-up state completion and movement-state exit/pause handling.
- Any MQTT/control command decode that identifies pause/resume timing.

## Diagnostic Rules

- Route reports containing throw failure, recovery, raised baffle, failed re-loading, pause during baffle raise, missing completion flag, or `BeltGateFSM::Up` after recovery to `component_test.baffle_raise_pause_completion_flag_recovery`.
- In logs, search for `SortHandlingFSM::Loading`, `ForceUnloading`, `MainController::Fault`, `MainController::Idle -> Move`, `BeltGateFSM::Up`, `Gate status set to: UP`, `got gate evt 20`, `Ack`, and decoded pause/resume commands.
- Confirm whether baffle-up completion is recorded independent of movement state.
- If completion is only set in movement state, move completion-flag update into the baffle-up state completion path or add explicit late-event handling for pause/recovery states.
- Regression-test pause/resume exactly while baffle is still moving, not only after the actuator is already stationary.

## Likely Causes

- Primary: baffle-up completion flag is written only in movement state, so pause/recovery state misses the completion event.
- Primary: pause/resume interleaving allows actuator completion and parent movement completion to diverge.
- Secondary: recovery command sequence retries movement while baffle completion state is stale.
- Secondary only with aligned evidence: actuator feedback/CAN delay prevents baffle completion from being observed.
- Less likely when baffle-up completion is logged: mechanical baffle jam or motor wiring fault.

## Exclusion Checks

- Do not diagnose baffle motor CAN communication loss solely from repeated `0x6064` SDO errors unless CAN heartbeat/SDO/PDO timing proves the motor failed to execute or report baffle-up.
- Do not diagnose mechanical jam if logs show baffle-up completion and the failure is an incorrect next-state/retry decision.
- Do not blame scheduler/task assignment until embedded handling state and baffle completion flags are proven correct.
- Do not claim fix validation from a single still frame; require source follow-up, log sequence, or repeat test.

## Confirmed Examples

- `component-test-pt-0117`: source text says throw failure recovery left the baffle raised and caused loading failure. Source analysis identifies pause before baffle-up completion and completion flag being set only in movement state. Source resolution is to set completion when baffle-up state completes. Local NXP log shows loading fault, recovery/force-unload, next loading/move, `BeltGateFSM::Up`, and `Gate status set to: UP` in the inspected window. Follow-up says the fix was verified.

## Unresolved Examples

- `component-test-pt-0117`: source diff/commit is absent; pause command is not decoded as readable log text; video was inspected through representative QuickLook frames because local `ffmpeg`/`ffprobe` are unavailable; repeated `0x6064` SDO upload errors remain uncorrelated background evidence.

## Specialist Routing

- `embedded-software`: primary owner for state-machine completion flags, pause/recovery event consumption, and command sequencing.
- `vision-media`: inspect failure/fix videos for baffle position, status lamp, and loading path.
- `scheduler-traffic`: secondary only when upstream recovery commands or task retry semantics are unclear.
- `can-bus`: secondary only when actuator command/feedback or repeated SDO/heartbeat errors align with the failure window.
