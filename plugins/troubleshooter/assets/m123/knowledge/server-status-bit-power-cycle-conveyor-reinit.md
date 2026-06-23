# Server Status Bit Power-cycle Conveyor Reinit

## Symptoms

- OmniSort / M123 MiniSort Pro loses drive power after door-lock or safety power interruption, then restarts.
- After restart, one or more feeder/conveyor stations do not home or do not run their origin procedure.
- UI reports feeder motor error and feeder CAN node heartbeat loss at the same recovery timestamp.
- Restarting the conveyor-side service or process, recorded in the source as `9352`, can restore feeder recovery.

## Fault Tree

1. Reconstruct the power-cycle timeline before treating the feeder as a standalone motor failure.
   - In `m123-pt-0141`, source text records door-lock drive-power cut at `13:04:19`, successful restart at `13:21:10`, both feeders not homing, station 2 motor error recoverable, and station 1 CAN heartbeat loss not recoverable until `9352` restart.
   - Local log `assets/m123-pt-0141/retry-source-EcmKbfXCyoJe3dxThICcP1pHnUe.log` shows multiple node heartbeat timeouts around `2026-06-05T13:04:26` to `13:04:29`, then `PDO disable failed` and `sys shutdown enter disable state` at `13:05:07`.
2. Check whether central control sent the server power-state transition.
   - Protocol screenshot `retry-image-004-VnDnbZ6KcomnEfxuExacwpbwnvh.png` defines `server status bit1` as power state: `0: 紧急停止`, `1: 良好`.
   - Source analysis states that during drive-power loss, central control did not set `server status bit1` to `0`, so the feeder could not detect the power-state change and reinitialize peripherals.
3. Separate expected power-cut CAN fallout from the recovery blocker.
   - Heartbeat timeouts during the power-loss window can be a consequence of drive-power cut.
   - A persistent unrecoverable `供包机CAN节点心跳丢失` after restart points to stale recovery state or missing reinitialization, not necessarily a broken CAN device.
4. Compare recoverable motor error versus non-recoverable heartbeat loss.
   - UI screenshot `retry-image-002-YQspbLHPGoR17bxqQ84cydaCn2b.jpg` shows `2026-06-05 13:21:10` errors: `供包机电机错误` and `供包机CAN节点心跳丢失`.
   - Source text says station 2 recovered after motor-error recovery, while station 1 heartbeat loss could not recover until `9352` restart.
5. Validate recovery by service restart and subsequent homing.
   - Local log shows `sys running enter enable state` at `2026-06-05T13:21:11`, `homing complete, target reached`, `position origin reached`, then one `SDO response error` / `can_bus_SDO_write()` at `13:21:12`.
   - Screenshot `retry-image-001-JwwVbtBiboOPyjxunsxciEDunLc.jpg` shows the upper system at `13:21:10` entering running, detecting `M123-SITE-1-CONVEYOR: receive-conveyor-error: CONVEYOR_EVENT_0X0F`, `DOOR-B open`, and clearing site package caches.

## Evidence Needed

- Raw central-control or sort-conveyor lines proving the actual `server status bit1` value before, during, and after the power cut.
- Exact command/process identity for `9352` and its restart log.
- CAN heartbeat or candump trace showing whether nodes resumed after `9352` restart.
- Confirmation that station 1 and station 2 run the same feeder firmware/config before comparing recovery behavior.

## Logs And Files To Inspect

- Case body: `cases/accepted/m123/0141-IeU8wApy6inePnk94otcvqzwn2e-2026-06-05-M123-迷你播Pro-动力电断电-重新开机后1号供包机没有对原点.md`.
- Local log: `assets/m123-pt-0141/retry-source-EcmKbfXCyoJe3dxThICcP1pHnUe.log`.
- Local images: `retry-image-001-JwwVbtBiboOPyjxunsxciEDunLc.jpg`, `retry-image-002-YQspbLHPGoR17bxqQ84cydaCn2b.jpg`, `retry-image-003-VrhDbGQVao5jV5xtIOvcsAmAnjd.png`, `retry-image-004-VnDnbZ6KcomnEfxuExacwpbwnvh.png`.
- Search terms: `server status`, `bit1`, `动力电`, `门锁动力电断电`, `供包机CAN节点心跳丢失`, `供包机电机错误`, `CONVEYOR_EVENT_0X0F`, `heartbeat timeout`, `PDO disable failed`, `sys shutdown enter disable state`, `sys running enter enable state`, `can_bus_SDO_write`, `9352`.

## Likely Causes

- Missing `server status bit1 = 0` transition during drive-power loss prevents feeder-side logic from seeing the power interruption and reinitializing peripherals.
- Upper-system reset can leave a feeder in stale state if the conveyor service did not observe a full power-state transition.
- CAN heartbeat loss after a power event can be a recovery-state symptom; treat it as root cause only after power-state transition and reinitialization are verified.

## Exclusion Checks

- Do not diagnose a damaged motor or CAN board only from heartbeat loss during the power-cut window.
- Do not treat station 2's recoverable motor error as identical to station 1's unrecoverable heartbeat loss; compare post-recovery behavior.
- Do not claim bit1 root cause as frame-level confirmed unless raw status-write logs or protocol frames are available.
- Do not route this to C134/Mantis power knowledge from the word `重启`; this is an OmniSort M123 feeder/conveyor power-state reinit case.

## Confirmed Examples

- `m123-pt-0141`: source timeline and screenshots show door-lock drive-power interruption, restart at `13:21:10`, feeder motor error plus CAN heartbeat loss, and recovery only after `9352` restart. Local log confirms 13:04 heartbeat timeouts, 13:05 shutdown-disable transition, and 13:21 homing/re-enable activity.

## Unresolved Examples

- `m123-pt-0141`: raw `server status bit1` write/read logs and `9352` restart logs are missing, so the bit1 mechanism is source-analysis-supported but not frame-level confirmed locally.

## Specialist Routing

- `embedded-software`: central-control server status bits, conveyor service restart/reinit, state-machine recovery.
- `can-bus`: node heartbeat loss, SDO/PDO errors, post-power CAN recovery.
- `scheduler-traffic`: startup/running transition, site cache clearing, feeder availability after recovery.
- `vision-media`: UI screenshots and protocol screenshot only; do not use screenshots alone to prove raw frame timing.
