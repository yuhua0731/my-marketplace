# DM Camera Link Loss Collision Chain

## Symptoms

- In the OmniFlow 2F dispatch test area, one Ant reports `DM code lost` / `FUTURE_STATE_NOT_MATCH` and stops near a path node.
- Another Ant receives a route through the same node or corridor and physically collides with the stopped robot.
- Follow-on robots may then collide in sequence because the first stopped robot becomes an unplanned obstacle.
- Normal ping to robot IPs can still show 0% loss, while the robot-local `lan1` / DM camera link is flapping.
- Robot-side failure may occur before the upstream command-status view catches up when MQTT disconnects during or after the DM loss window.

## Fault Tree

- Confirmed branch: the first stopped robot must be identified before blaming the later collision.
  - In `test-floor-traffic-pt-0008`, source text says A3772 reported `DM code lost` at `01:59:37` and stopped near `N3`.
  - A3767 then executed `A3767-S46169-2026-04-08T17:59:37.818Z-command-label-6` from `N1` toward `N3` and collided with A3772.
  - The monitoring video thumbnail shows the relevant 2F area at `2026-04-09 02:03:28`, but the collision point is a blind spot.
- Confirmed branch: A3772 had local DM/barcode link symptoms before the stop.
  - `011-source-O2T4bo311oT5LOxJuJGcPKybn5e.log` shows `gvsp poll timeout`, `gvcp poll timeout`, `failed to receive success ack`, and barcode heartbeat failures before the final stop.
  - At `2026-04-08T17:59:36Z`, A3772 logs `DM LOST, distance without barcode update: 3005.832722 mm`.
  - At `2026-04-08T17:59:37Z`, A3772 logs `CoordY is not as expected. expected value: 102000, actual value: 103767.265625, tolerance: 100`.
  - A3772 command `A3772-S44142-2026-04-08T17:59:05.997Z-command-label-6` ends with `COMPLETE_FAILURE` for `DIFF402_ERROR#MOVER_MOTOR#DM code lost` and `FUTURE_STATE_NOT_MATCH#CoordY`.
- Confirmed branch: A3772 local `lan1` link flapped during and after the failure window.
  - `010-source-Jv0zbRPa0okCzzxfCs1czK0UnWf.log` shows dense `lan1: Link is Down` / `Link is Up - 100Mbps/Full` events from `2026-04-08T17:59:34Z` through the following minutes.
  - Image evidence also shows the same `lan1` flapping around the event.
- Confirmed branch: A3778 repeated the same failure pattern in `test-floor-traffic-pt-0107`.
  - A3778 command `A3778-S55772-2026-05-05T16:29:51.767Z-command-label-0` starts as `PROCESSING` for a `MOVE` to `coordY=102000`.
  - At `2026-05-05T16:29:58Z`, A3778 logs dense `gvsp poll timeout` and `gvcp poll timeout`; at `16:29:59Z`, barcode heartbeat logs `failed to receive success ack`, `failed to send packet`, and `failed to get heartbeat status`.
  - At `2026-05-05T16:29:59Z`, A3778 logs `DM LOST, distance without barcode update: 3012.835117 mm`.
  - At `2026-05-05T16:30:01Z`, A3778 fails future-state check: `CoordY` expected `102000`, actual `103721.218750`.
  - At `2026-05-05T16:30:01Z`, A3778 reports `COMPLETE_FAILURE` for `DIFF402_ERROR#MOVER_MOTOR#DM code lost` plus `FUTURE_STATE_NOT_MATCH#CoordY`; the following spin command is cancelled.
  - A Wormhole screenshot at `2026-05-06T00:29:58+0800` shows `lan1: Link is Down` and `br-lan: port 1(lan1) entered disabled state`, aligning the robot-local DM timeout with the NXP-Wormhole physical link branch.
- Confirmed branch: MQTT/control-plane visibility can lag the robot-side failure.
  - In `test-floor-traffic-pt-0107`, A3778 logs `MQTT client disconnected -116` at `2026-05-05T16:30:06Z`, reconnects at `16:30:38Z`, then reports `Missing block(s)` and `NoRead status ongoing`.
  - The command-status screenshot shows external `COMPLETE_FAILURE` visible at local `2026/5/6 00:30:39`, after robot-side failure at `00:30:01`.
- Likely branch: scheduler/traffic logic must be checked as the secondary safety layer.
  - The direct initiating fault is A3772 localization/link loss, but A3767 still received or continued a route into the occupied conflict area.
  - Determine whether scheduler knew A3772 was failed near `N3`, whether reservation/future-state occupancy was released incorrectly, and whether the blind spot/route segment had conflict protection.
  - In `test-floor-traffic-pt-0107`, source text says A3769 hit A3778 around `00:30:28`; this needs A3769 route/reservation logs to prove the scheduling branch.
- Excluded branch for this case: broad robot network outage as the primary explanation.
  - Screenshots show ordinary ping to A3767/A3772 IPs around `02:02` with 0% loss and low latency.
  - This does not exclude DM camera local link failure on A3772 `lan1`.

## Evidence Needed

- Exact collision position, route segment, and whether the area is covered by traffic reservation/interlock.
- A3772 robot logs before first stop: DM/barcode, `lan1`, motion, future-state, and command status.
- A3767 command timeline and scheduler decision logs around `2026-04-08T17:59:37Z` to confirm when the route to `N3` was issued.
- A3778 robot logs before first stop: `A3778-S55772`, DM/barcode, `lan1`, MQTT disconnect/reconnect, future-state, and command status.
- A3769 command timeline and scheduler decision logs around local `2026-05-06 00:30:01` to `00:30:39` to confirm why it entered A3778's stopped/conflict area.
- RCS/RMS/SAS reservation state for `N1`, `N2`, `N3`, and the relevant corridor before and after A3772 failure.
- Full video or whiteboard export if physical collision sequence or blind spot boundary matters.
- Hardware swap results: DM camera cable, camera, Wormhole board, switch port, and whether the fault follows the robot or component.

## Logs And Files To Inspect

- Local case: `cases/accepted/test-floor-traffic/0008-HwrJwqf2riCeHqkfHtVcp5OenOh-2026-04-09-二楼调度的蚂蚁机器人撞车.md`.
- Local assets:
  - `assets/test-floor-traffic-pt-0008/009-source-CEWtbnSFOoymKExHU3ScveTjnoe.mp4`
  - `assets/test-floor-traffic-pt-0008/010-source-Jv0zbRPa0okCzzxfCs1czK0UnWf.log`
  - `assets/test-floor-traffic-pt-0008/011-source-O2T4bo311oT5LOxJuJGcPKybn5e.log`
  - `assets/test-floor-traffic-pt-0008/012-source-LlJPbOjo4obliexL2FscHoibnHb.log`
  - `assets/test-floor-traffic-pt-0008/013-source-MXzDbI40foEYDsxRQxEcJbsrnKd.log`
  - `assets/test-floor-traffic-pt-0008/*image*`
- Local case: `cases/accepted/test-floor-traffic/0107-IweOwFgkRi9Qx6kkDPocdJjtnaf-2026-05-06-二楼蚂蚁调度测试撞击问题.md`.
- Local assets:
  - `assets/test-floor-traffic-pt-0107/007-source-EjSGbn7lLo8xBRxgGTyc6T2AnPg.log`
  - `assets/test-floor-traffic-pt-0107/008-source-D9EXbsRMgozuLUxqcgSc4S3tnDh.mp4`
  - `assets/test-floor-traffic-pt-0107/001-image-7ab598128d1d.jpg`
  - `assets/test-floor-traffic-pt-0107/002-image-95b602e19390.jpg`
  - `assets/test-floor-traffic-pt-0107/003-image-7701b35d5f38.png`
  - `assets/test-floor-traffic-pt-0107/004-image-9ee980e47f4f.png`
  - `assets/test-floor-traffic-pt-0107/005-image-1e8a3ce431a0.png`
  - `assets/test-floor-traffic-pt-0107/006-image-5e6be3e5b2a6.png`
- Search terms:
  - `DM code lost`, `DM LOST`, `FUTURE_STATE_NOT_MATCH`, `CoordY`, `robotCommandLabel`, `COMPLETE_FAILURE`, `A3772-S44142`, `A3767-S46169`, `A3778-S55772`, `A3769`, `gvsp poll timeout`, `gvcp poll timeout`, `MQTT client disconnected -116`, `Missing block(s)`, `NoRead status ongoing`, `lan1`, `Link is Down`, `Link is Up`, `N1`, `N3`

## Likely Causes

- A3772 DM camera/barcode link intermittently failed, causing localization loss and future-state mismatch near `N3`.
- A3772 local Ethernet/DM camera physical chain was unstable: cable, connector, camera, Wormhole board port, or related power/ground path.
- Scheduler/traffic protection did not prevent A3767 from entering the route segment occupied by a failed/stopped robot.
- A3778 DM camera/barcode link failed while moving from `CoordY=115000` toward `102000`, leaving it stopped near `CoordY=103721.218750`.
- A3778 MQTT disconnect/reconnect delayed or complicated upstream visibility of the robot-side failure.
- Monitoring blind spot delayed human recognition of the stopped robot and subsequent chain collision.

## Exclusion Checks

- Do not treat the last collision robot as root cause until the first failed/stopped robot is identified.
- Do not use successful ping to robot IPs to exclude DM camera link loss; inspect robot-local `lan1`, barcode heartbeat, GVSP/GVCP, and DM read logs.
- Do not blame scheduler first if robot logs show `DM LOST` and `FUTURE_STATE_NOT_MATCH` before the collision; scheduler is the secondary collision-prevention branch.
- Do not treat `MQTT client connected!` after recovery as proof the movement was safe; compare failure time, reconnect time, and command-status publish time.
- Do not treat `Missing block(s)` after reconnect as root cause by itself; it is usually recovery/stale stream evidence after local link loss.
- Do not claim physical link root cause from one event alone; confirm with cable/camera/board swaps and whether lan1 flapping follows the component.
- Do not use blind-spot video as proof of collision order; use logs for order and video only for scene/time support.

## Confirmed Examples

- `test-floor-traffic-pt-0008`: A3772 reports DM loss and future-state mismatch at `2026-04-08T17:59:36Z` to `17:59:37Z`; A3767 then collides with the stopped robot near `N3` according to the source analysis.
- `test-floor-traffic-pt-0107`: A3778 reports `DM LOST` at `2026-05-05T16:29:59Z`, `FUTURE_STATE_NOT_MATCH#CoordY` and `COMPLETE_FAILURE` at `16:30:01Z`, MQTT disconnect at `16:30:06Z`, reconnect at `16:30:38Z`, then `Missing block(s)`/`NoRead` after reconnect. Source says A3769 hit A3778 during this stale/failure window.

## Unresolved Examples

- `test-floor-traffic-pt-0008`: A3772 `lan1` continues to flap after DM camera cable swap, and A3778/A3772 Wormhole board swap was planned. Final component-level root cause is not confirmed in the visible case.
- `test-floor-traffic-pt-0107`: final component-level cause of A3778 `lan1` down is not confirmed; scheduler/RCS logs for A3769 are still needed to prove the secondary collision-prevention failure.

## Specialist Routing

- Start with `robot-motion` for DM read loss, future-state mismatch, stopped pose, and collision order.
- Add `network-infra` for `lan1`, GVSP/GVCP, camera Ethernet, connector, and board-port instability.
- Add `scheduler-traffic` for reservation/interlock behavior after a robot stops near `N3`.
- Add `vision-media` only to confirm scene, blind spot, and physical sequence when the video covers it.
