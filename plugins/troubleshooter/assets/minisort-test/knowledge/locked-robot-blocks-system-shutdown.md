# Locked Robot Blocks System Shutdown

## Symptoms

- MiniSort Pro / OmniSort runs in self-test or no-scan loading mode.
- One or more robots are locked before shutdown.
- The operator clicks system shutdown, but the system does not complete shutdown.
- UI remains alive and can still show robot/system states.

## Fault Tree

1. Confirm this is a shutdown workflow/state issue.
   - If UI is responsive and drive/controller indicators are still visible, do not start with hardware power failure.
   - Find the backend shutdown request and first blocking step.
2. Check robot lock state.
   - Identify locked robot IDs and whether they are expected to move to shutdown/parking position.
   - Determine whether locked robots are excluded from dispatch but still counted in shutdown barriers.
3. Check robot state consistency.
   - A robot that is locked and initializing/idle may be unable to accept park/shutdown commands.
   - Compare locked robot state with other running robots at the same timestamp.
4. Check product behavior policy.
   - MiniSort Pro should either reject shutdown with a clear prompt, safely unlock/park, or force-stop after safe-state checks.
   - Silent hanging means the lock state is not handled as a first-class shutdown precondition.
5. Validate the fix by reproduction.
   - Lock the same class of robot, request shutdown, and verify terminal state or explicit prompt.

## Evidence Needed

- Backend shutdown logs from the exact click time.
- Robot lock/unlock event logs, locked robot IDs, and caller.
- Robot state timeline for locked and unlocked robots.
- Shutdown state-machine or scheduler barrier logs.
- Product requirement for shutdown behavior when robots are locked.
- Post-fix retest showing either completed shutdown or a clear actionable prompt.

## Logs And Files To Inspect

- Search for `shutdown`, `关机`, `lock`, `locked`, `unlock`, `robot lock`, `M002L`, `parking`, `park`, `disable`, `state`, `barrier`, and `system shutdown`.
- Inspect scheduler/task logs, robot state service logs, lock-state storage, and UI action request logs around the shutdown click.
- Screenshot evidence is useful for visible state; backend logs are required to identify the exact blocking code path.

## Likely Causes

- Locked robot remains counted in all-robots-ready/all-robots-parked shutdown barrier.
- Locked robot cannot receive park/shutdown command, so shutdown waits indefinitely.
- MiniSort Pro lacks explicit handling for manual robot lock during self-test/no-scan loading mode.
- UI issues shutdown request but backend rejects or stalls without surfacing the blocking robot.

## Exclusion Checks

- Exclude power-hardware failure when the UI is responsive and normal system indicators are visible.
- Exclude generic robot offline branch unless the locked robot is also disconnected or heartbeat-lost.
- Exclude CAN/embedded root cause until logs show command delivery, state-machine, heartbeat, or actuator errors.
- Exclude normal shutdown delay only after checking whether the same robot remains locked/initializing across the waiting period.
- Do not remove the lock-state precondition from the diagnosis; this case is about shutdown under locked-robot state.

## Confirmed Examples

- `minisort-test-pt-0065`: MiniSort Pro self-test mode locked other robots, ran for 2 minutes, then shutdown at `2026-05-06 15:29` failed. Source analysis says `M002L` was locked and Mini Pro did not yet support this robot-lock scenario well. Screenshot at `2026-05-06 16:07:55` shows `M002L` grey/initializing while the rest of the visible robots are running.

## Unresolved Examples

- `minisort-test-pt-0065`: shutdown backend logs, lock event logs, exact blocking state-machine step, and post-fix retest are not local.

## Specialist Routing

- `scheduler-traffic`: shutdown barriers, lock state, parking/dispatch state, system mode.
- `embedded-software`: only if backend logs show robot state-machine or command execution failure.
- `vision-media`: UI screenshot interpretation and visible robot/system state.
