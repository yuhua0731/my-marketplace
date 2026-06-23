# Ant Reboot Command Cancel Collision Chain

## Symptoms

- In the OmniFlow 2F dispatch test area, an Ant collision is reported after one robot disappears from heartbeat or reboots while a motion command is active.
- Source symptom for `test-floor-traffic-pt-0108`: `16:56:44撞车`.
- Source analysis says A3766 rebooted, so the command did not finish, and A3766 heartbeat data disappeared at `16:55:52`.
- Command screenshots show `robotLabel: A3766`, task `A3766_Task_20260506085427854401`, command set `A3766-S65084-2026-05-06T08:54:29.458Z`, and later `failureReason: Rebooted`.

## Fault Tree

- Confirmed branch: A3766 rebooted or lost runtime continuity while a command was in progress.
  - Screenshot evidence shows command `A3766-S65084-2026-05-06T08:54:29.458Z-command-label-10` is `CANCELLED` at local `2026/5/6 17:30:29`, with `failureReason: Rebooted`.
  - Screenshot evidence shows command-label-9 was `PROCESSING` at local `2026/5/6 16:55:52`.
  - NXP log jumps from `2026-05-06T08:55:21Z` with `UPTIME:13523` to `2026-05-06T09:17:06Z` with `UPTIME:53`, which supports a reboot/log discontinuity.
- Confirmed branch: the active motion command before the log gap was still executing.
  - At `2026-05-06T08:55:19Z`, A3766 receives `robotCommandLabel: A3766-S65084-2026-05-06T08:54:29.458Z-command-label-3`, `robotCommandType: MOVE`.
  - Command target is `coordX: 102000`, `coordY: 108000`, with `maxVelocity: 2000`, `maxAcceleration: 400`, and `obstacleAvoidance: false`.
  - At `2026-05-06T08:55:21Z`, the robot is still moving: `estimation_state` has `v: 677.393799`, and current reference is near `y: 106578`.
- Likely branch: the collision is a consequence of robot disappearance/reboot during traffic execution, not a primary DM localization failure.
  - This case has no captured `DM LOST`, `FUTURE_STATE_NOT_MATCH`, `Link is Down`, or `Link is Up` evidence in the available A3766 log.
- Secondary branch: scheduler/traffic handling after robot heartbeat loss must be checked.
  - If a moving robot reboots or disappears, traffic should retain or protect its last known occupied segment until physical state is confirmed.
  - The visible case does not include scheduler reservation logs, so whether another robot was allowed into the conflict area remains unverified.
- Blocked branch: reboot root cause.
  - Available evidence proves reboot/discontinuity, but not whether it was caused by power, firmware, CAN, watchdog, operator action, network, or collision impact.

## Evidence Needed

- RCS/RMS/SAS scheduler logs around local `2026-05-06 16:55:52` to `16:56:44`, including reservation state, heartbeat timeout handling, and route release.
- Robot heartbeat history for A3766 showing the last heartbeat at local `16:55:52` and reconnection after reboot.
- NXP logs immediately before reset, including boot banner, reset reason, watchdog, hard fault, brownout, CAN fault, and power telemetry.
- CAN candump/pcap around the same window if CAN/power/motor state is suspected.
- Full video frames covering local `16:55:52` to `16:56:44` and the physical collision point.
- Any operator intervention, emergency stop, battery/boost, or hardware inspection notes after the collision.

## Logs And Files To Inspect

- `assets/test-floor-traffic-pt-0108/003-source-QHRgbTyMRomCkNxrxFRcYqY4nDg.log`: strip ANSI escapes, then search `A3766-S65084`, `status:PROCESSING`, `UPTIME`, `CANopenStack starting`, `heartbeat response`, `NoRead status`, `Rebooted`, `Reset reason`, `watchdog`, `HardFault`, `DM LOST`, and `FUTURE_STATE_NOT_MATCH`.
- `assets/test-floor-traffic-pt-0108/001-image-90611c78fd90.png`: command reporting screenshot with `PROCESSING` at local `16:55:52` and `CANCELLED` / `Rebooted` at local `17:30:29`.
- `assets/test-floor-traffic-pt-0108/002-image-9199d3212c3a.png`: duplicate/related command reporting screenshot confirming `failureReason: Rebooted`.
- `assets/test-floor-traffic-pt-0108/004-source-EtR0bjsFool7ZRxzqAlcIjgUnFb.mp4`: MP4 duration about `32.27s`; QuickLook thumbnail shows the 2F test area around local `16:56`, but full frame extraction was not available without ffmpeg.

## Likely Causes

- Robot-side reboot or power/runtime reset during an active move.
- Watchdog, brownout, firmware fault, or hardware reset, pending reset-reason evidence.
- Traffic reservation release or missing stale-occupancy protection after heartbeat loss.
- Physical collision may be consequence or trigger; determine order from scheduler/video evidence before assigning cause.

## Exclusion Checks

- Do not classify as DM camera/link-loss collision unless `DM LOST`, `FUTURE_STATE_NOT_MATCH`, GVSP/GVCP, or `lan1` link-flap evidence appears before the collision.
- Do not classify as pure scheduler fault while A3766 reboot/discontinuity is the strongest available initiating evidence.
- Do not classify as CAN root cause from `system_area: CAN` alone; require CAN frames, CANopen errors, motor heartbeat loss, or reset/power evidence.
- Do not use `CANCELLED / Rebooted` alone to prove why the robot rebooted; it proves command outcome after reboot.
- Do not use the QuickLook video thumbnail to prove collision order; it only confirms scene/time context.

## Confirmed Examples

- `test-floor-traffic-pt-0108`: A3766 active command sequence `A3766-S65084-2026-05-06T08:54:29.458Z` was in progress near local `16:55:52`; source reports collision at `16:56:44`; screenshots later show command cancellation with `failureReason: Rebooted`; log continuity drops from `UPTIME:13523` at `08:55:21Z` to `UPTIME:53` at `09:17:06Z`.

## Unresolved Examples

- `test-floor-traffic-pt-0108`: reboot root cause and scheduler collision-prevention behavior remain unresolved because reset reason, CAN/power evidence, scheduler reservation logs, and full decoded collision video are missing.

## Specialist Routing

- Start with `embedded-software` for reset continuity, reset reason, watchdog, brownout, firmware crash, and startup logs.
- Add `robot-motion` for active command geometry, moving/stopped state, last pose, and collision order.
- Add `scheduler-traffic` for heartbeat-loss handling, occupied-segment retention, route release, and conflict prevention.
- Add `can-bus` only if CANopen, motor heartbeat, power, or CAN frame evidence is available.
- Use `vision-media` to confirm scene, timestamp, and physical sequence when full video frames are available.
