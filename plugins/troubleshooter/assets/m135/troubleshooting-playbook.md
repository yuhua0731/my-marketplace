# M135 Troubleshooting Playbook

Use this as the human-readable entrypoint before specialist routing.

## Global Process

1. Record exact symptom, timestamp, robot ID, station/location, task/container ID, and available filenames.
2. Classify the case by observed symptom, not by incidental WS/robot/location words.
3. Load the matching knowledge file and traverse the highest-value fault branch first.
4. Mark every branch as `confirmed`, `likely`, `excluded`, or `blocked`.
5. Treat unavailable videos, images, logs, and chat records as missing assets, not analyzed evidence.
6. Stop only at confirmed root cause, sufficient operational conclusion, or excluded branch.

## Route Order

- Reboot, shutdown, charging, low voltage: embedded-software first, then can-bus/scheduler/network.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## ALLCAN-LED State Color Stuck On Initialization Color

Knowledge file: `docs/m135/knowledge/allcan-led-firmware-version-mismatch.md`

### First Checks

- Confirmed branch: robot-side firmware/version evidence must be checked before treating this as workstation WLED.
  - Case `m135-pt-0170` title and symptom both refer to robot `ALLCAN-LED`.
  - The archive field says `WLED/workstation light strip`, but the source text and media point to robot/device state lighting.
  - Version screenshot highlights robot `J51A76MN`; nearby rows show different visible firmware/tag values, and the exact expected baseline is not visible.
- Confirmed branch: normal Wormhole flashing path failed.
  - Source text says `通过虫洞无法烧录固件到机器人`.
  - Flash screenshot shows `fill-memory` and `configure-memory` responses succeed, then `flash-image` returns `kStatus_FlexSPINOR_CommandFailure`.
- Likely branch: wrong robot firmware or wrong firmware package prevents ALLCAN-LED state mapping from matching runtime robot states.
  - Source analysis explicitly says `机器人固件不对`.
  - Resolution says `使用jlink处理`.
- Blocked branch: whether the issue is pure firmware mismatch, flash storage/NOR failure, bootloader incompatibility, or package mismatch.
  - No raw flashing log, firmware package checksum, expected version matrix, or post-J-Link retest is present.
- Blocked branch: CAN device-state propagation.
  - The case is archived as CAN, but no CAN frame, heartbeat, node ID, or status-PDO evidence is available.

### Evidence

- Expected M135 firmware baseline and version matrix for `J51A76MN`.
- Raw robot/NXP/STM logs around the observed LED state mismatch.
- Raw flashing log from Wormhole and J-Link, including firmware package name, checksum, bootloader version, and target storage layout.
- CAN capture or ALLCAN status frames showing whether robot state changes are published to the LED device.
- Full video frame review covering at least two robot state transitions, not only a representative thumbnail.
- Post-J-Link verification that the ALLCAN-LED follows running, fault, standby, and idle states.

### Exclusions

- Do not route to workstation WLED/HLED unless evidence names a workstation light strip; robot `ALLCAN-LED` is a robot/device branch.
- Do not declare a CAN root cause without CAN frames, node IDs, heartbeat/status-PDO evidence, or robot logs showing CAN propagation failure.
- Do not treat a visible `Write File complete` line as successful firmware flashing when the later `flash-image` command fails.
- Do not treat J-Link handling as verified resolution unless a post-flash state-transition test is available.
- Exclude wrong firmware/package only after comparing the robot ID, target board, firmware package, tag, commit, and expected M135 baseline.

### Examples

- `m135-pt-0170`: M135 robot `ALLCAN-LED` remains at initialization color and does not follow running/fault/standby states. Source analysis says robot firmware is wrong. Wormhole flashing is reported unavailable; attached flashing screenshot shows `flash-image` fails with `kStatus_FlexSPINOR_CommandFailure`. Resolution says J-Link was used.

- `m135-pt-0170`: final exact firmware target, J-Link raw log, post-flash retest, and CAN status propagation remain missing.
