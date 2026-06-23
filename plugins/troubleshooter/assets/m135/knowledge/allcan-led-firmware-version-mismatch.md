# ALLCAN-LED State Color Stuck On Initialization Color

## Symptoms

- M135 robot `ALLCAN-LED` light strip stays at the initialization color.
- Light color does not follow robot states such as running, fault, standby, or idle.
- Field video shows robot/track light colors are visible on site, but local tools only extracted a representative frame, not full state-transition proof.
- Source analysis says the robot firmware is wrong and the firmware could not be flashed through Wormhole.

## Fault Tree

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

## Evidence Needed

- Expected M135 firmware baseline and version matrix for `J51A76MN`.
- Raw robot/NXP/STM logs around the observed LED state mismatch.
- Raw flashing log from Wormhole and J-Link, including firmware package name, checksum, bootloader version, and target storage layout.
- CAN capture or ALLCAN status frames showing whether robot state changes are published to the LED device.
- Full video frame review covering at least two robot state transitions, not only a representative thumbnail.
- Post-J-Link verification that the ALLCAN-LED follows running, fault, standby, and idle states.

## Logs And Files To Inspect

- `cases/accepted/m135/0170-CVSAweTqQiHOt3kidfwca53Yn1b-2026-06-16-M135-机器人ALLCAN-LED颜色与机器人状态不符.md`: source body.
- `assets/m135-pt-0170/retry-image-001-IIJebS4Pbo4zn7xzdJucInWkntb.png`: robot version table; `J51A76MN` row is highlighted, and visible firmware/tag values differ from nearby rows.
- `assets/m135-pt-0170/retry-image-002-DeIEbCgleoiGbXx7qLncSL8nnWe.png`: flashing output; `flash-image` returns `Response status = 20106 (0x4e8a) kStatus_FlexSPINOR_CommandFailure`.
- `assets/m135-pt-0170/retry-source-UkNkbQaU4oOWZXxMm6pcX5NrnKI.mp4`: 91.034s H.264/AAC video; representative frame shows M135/OmniSort site lighting, but full frame extraction was unavailable locally.
- Search terms: `ALLCAN-LED`, `初始化颜色`, `不跟随机器人运行`, `机器人固件不对`, `虫洞无法烧录`, `JLink`, `flash-image`, `kStatus_FlexSPINOR_CommandFailure`, `FlexSPINOR`, `J51A76MN`.

## Likely Causes

- Robot firmware image or version does not match the M135 ALLCAN-LED state protocol.
- Wormhole flashing path cannot write the target image because of FlexSPI NOR command failure, bootloader/storage mismatch, or wrong flashing flow.
- LED state mapping remains at initialization because the robot-side firmware never publishes or interprets the expected state updates.

## Exclusion Checks

- Do not route to workstation WLED/HLED unless evidence names a workstation light strip; robot `ALLCAN-LED` is a robot/device branch.
- Do not declare a CAN root cause without CAN frames, node IDs, heartbeat/status-PDO evidence, or robot logs showing CAN propagation failure.
- Do not treat a visible `Write File complete` line as successful firmware flashing when the later `flash-image` command fails.
- Do not treat J-Link handling as verified resolution unless a post-flash state-transition test is available.
- Exclude wrong firmware/package only after comparing the robot ID, target board, firmware package, tag, commit, and expected M135 baseline.

## Confirmed Examples

- `m135-pt-0170`: M135 robot `ALLCAN-LED` remains at initialization color and does not follow running/fault/standby states. Source analysis says robot firmware is wrong. Wormhole flashing is reported unavailable; attached flashing screenshot shows `flash-image` fails with `kStatus_FlexSPINOR_CommandFailure`. Resolution says J-Link was used.

## Unresolved Examples

- `m135-pt-0170`: final exact firmware target, J-Link raw log, post-flash retest, and CAN status propagation remain missing.

## Specialist Routing

- Start with `embedded-software` for firmware version matrix, bootloader/flashing path, and robot-side state mapping.
- Add `can-bus` only after collecting CAN/status-frame evidence for LED state propagation.
- Add `vision-media` when video or screenshots are needed to compare actual light colors against robot state transitions.
