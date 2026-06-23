# CAN2 Fork-Arm Belt Harness Intermittent CANL Fault

## Symptoms

- Mantis 2.6.0 CAN2 resistance jumps frequently between `60Ω` and `120Ω`.
- Pressing, pushing, or moving the left fork arm makes CAN2 resistance visibly unstable.
- The source points to the left fork-arm communication belt harness rather than ALLCAN board termination switch mis-touch.

## Fault Tree

- Confirmed branch: resistance instability is mechanically coupled to the left fork arm.
  - Source symptom says CAN2 line resistance frequently jumps in the `60Ω~120Ω` range.
  - Source says pressing/pushing the left fork arm causes obvious CAN2 resistance fluctuation.
  - Local video thumbnail `retry-source-BUxib...mp4` shows a multimeter around `118.5Ω` while the fork-arm area is being manipulated.
- Confirmed branch: ALLCAN termination switch mis-touch was checked and excluded.
  - Source says ALLCAN-8_580 cover was removed and the resistor DIP switch was checked.
  - Pressing/pushing the fork arm did not cause DIP switch mis-touch.
- Confirmed branch: board sockets are stable when the fork-arm communication belt harness is disconnected.
  - Source says after removing ALLCAN-8_580 and side ALLCAN-4_590 covers, disconnecting both ends of the fork-arm communication belt harness, and measuring the sockets while moving the fork arm, resistance at both board sockets was normal and stable.
- Confirmed branch: the harness itself shows intermittent CANL continuity.
  - Source says multimeter continuity test on the fork-arm communication belt harness found CANH normal.
  - Source says CANL beeper became intermittent while the fork arm was pulled back and forth.
  - Source cause: one or more positions inside the fork-arm communication belt harness caused CANL short/unstable continuity when the fork arm moved.
- Resolution branch: replacing the left fork-arm communication belt harness.
  - Follow-up states normal debugging on `2026-06-01`, `2026-06-02`, and `2026-06-11`, then issue closed.

## Evidence Needed

- Full multimeter video/audio or measurement log showing the resistance jump sequence while moving the fork arm.
- Clear photo of the disconnected ALLCAN-8_580 and ALLCAN-4_590 connector points.
- Harness part number, connector pinout, affected CANH/CANL pins, and replacement part record.
- Post-replacement resistance measurement under repeated fork-arm movement.
- CAN traffic/log evidence showing whether communication errors disappeared after harness replacement.

## Logs And Files To Inspect

- `cases/accepted/mantis-test/0119-Ib0QwUmHuiD6ouk1XrqcyGAynoe-2026-05-27-Mantis-2.6.0-CAN2电阻异常问题.md`: source body.
- `assets/mantis-test-pt-0119/retry-source-BUxibBVYKohu2SxpnDscKOK2nqb.mp4`: 20.7105s H.264/AAC video; representative frame shows fork-arm manipulation and multimeter reading around `118.5Ω`.
- `assets/mantis-test-pt-0119/retry-source-RBc2bUEeCortPGxDtInc16HFnkf.mp4`: 24.5315s HEVC/AAC video; representative frame shows disconnected harness/connector measurement and multimeter around `0.37`.
- Search terms: `Mantis 2.6.0`, `CAN2`, `60Ω`, `120Ω`, `ALLCAN-8_580`, `ALLCAN-4_590`, `左侧货叉臂`, `货叉臂通讯皮带线束`, `CANL`, `CANH`, `阻值跳变`, `蜂鸣`.

## Likely Causes

- Left fork-arm communication belt harness has an internal intermittent fault on CANL, exposed only when the fork arm moves.
- Cable bending, drag-chain motion, connector strain, or internal conductor damage creates intermittent resistance/continuity changes.
- Because board socket resistance remains stable after disconnecting the harness, ALLCAN board termination is less likely than harness failure.

## Exclusion Checks

- Do not blame CAN termination DIP switch if pressing/pushing the fork arm does not touch the ALLCAN-8_580 resistor switch and socket measurements remain stable.
- Do not replace ALLCAN-8_580 or ALLCAN-4_590 before disconnecting the fork-arm harness and measuring board-side socket resistance.
- Do not treat a static normal resistance as sufficient; move the fork arm while measuring because the fault is motion-coupled.
- Do not declare CANH/CANL both faulty if continuity testing shows CANH stable and CANL intermittent.
- Do not close after replacement without dynamic resistance retest and communication retest under fork-arm motion.

## Confirmed Examples

- `mantis-test-pt-0119`: Mantis 2.6.0 CAN2 resistance jumped between `60Ω` and `120Ω`. Pushing/pressing the left fork arm reproduced instability. ALLCAN-8_580 termination switch mis-touch was excluded. With both ends of the fork-arm communication belt harness disconnected, board socket resistance at ALLCAN-8_580 and ALLCAN-4_590 was normal and stable during fork movement. The harness continuity test found CANH normal but CANL beeper intermittent while moving the fork arm. Replacing the left fork-arm communication belt harness resolved the issue; follow-up on 2026-06-01, 2026-06-02, and 2026-06-11 reported normal debugging/no abnormality.

## Unresolved Examples

- `mantis-test-pt-0119`: local assets lack the still image referenced in the source, raw CAN logs, full measurement audio/transcript, exact harness part number, and post-replacement measurement video.

## Specialist Routing

- Start with `can-bus` for CAN2 resistance, termination, CANH/CANL continuity, and dynamic measurement under fork-arm motion.
- Add `mantis-handling` for fork-arm movement, belt/drag-chain routing, mechanical strain, and replacement access.
- Add `vision-media` for video/photo inspection of movement-coupled measurements and connector state.
