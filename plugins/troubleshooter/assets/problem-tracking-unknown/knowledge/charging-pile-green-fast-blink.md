# Charging Pile Green Fast Blink During Ant Auto-Charge

## Symptoms

- Ant enters an OmniFlow charging pile in the 2F test area and appears to charge normally for about 1 to 15 minutes.
- The charging pile then enters green fast blink / green frequency blink, described in the source as `充电识别连接状态` or `充电桩系统关机`.
- Rebooting the charging pile can temporarily restore charging, but the symptom repeats.
- Battery state of charge may rise slowly, stay nearly unchanged, or fall during the reported window.

## Fault Tree

- Likely branch: charging session handshake or pile-side charge state is not sustained.
  - `problem-tracking-unknown-pt-0060` reports repeated green fast blink across `J33A49CS`, `J33A50CS`, `J33A51CS`, and `J33A52CS`.
  - `problem-tracking-unknown-pt-0061` reports `J33A52CS` green fast blink after about 15 minutes, then recurrence about 1 minute after restarting the Ant.
  - Restart recovery is a reset symptom, not proof of root cause.
- Likely branch: real charge current is intermittent or absent in part of the session.
  - `0060` robot logs show mixed SOC trends: examples include `49 -> 48`, `49 -> 48`, `49 -> 48`, `38 -> 40`, and `38 -> 45`.
  - `0061` normal position logs show nearly flat SOC: `005-source-LrEQb00YLoVYUwxENDCcZNjhnef.log` stays `74 -> 74`; `009-source-B6cWbocjno7mHJxI2oQcMUTGnkf.log` stays about `82 -> 83`.
  - `0061` Wormhole CAN battery extraction also conflicts by session: `006-source-O3nZbwZd3oghtfxje1fcgvVbnZc.log` rises `73.5% -> 90.6%`, while `010-source-RtaKbVyYGoYrucxhxcxcFNlHnzf.log` falls `86.9% -> 82.6%`.
- Possible branch: robot-side BMS/CAN reporting or charge protocol compatibility contributes.
  - The symptom is not isolated to one pile or one robot: `0060` names `A3778`, `A2055`, `A2046`, `A3772`, and `A3763`.
  - `A3763` reportedly changed five charging piles before scheduling started and still saw abnormal green blink.
- Possible branch: pile-side hardware, contact, power output, or controller state issue.
  - Video thumbnails confirm the robot is physically at the charging pile and green indicator state is visible.
  - Pile-side voltage/current/controller logs are not present, so this branch remains unconfirmed.
- Blocked branch: raw CAN pcap decoding.
  - `0061` pcap files are present and `tcpdump` reads PCAP-NG timestamps, but current local tooling reports payload type as `UNSUPPORTED`; frame-level CAN meaning is not decoded.

## Evidence Needed

- Exact timestamp window, pile ID, robot ID, and whether the robot was docked or already leaving.
- Charging pile controller logs, charger output voltage/current, relay/contact state, and internal error code around green fast blink.
- Robot BMS/CAN battery status aligned with the same window as the visible LED state.
- Decoded CAN frames for charge handshake, BMS state, charger request/response, and current limit.
- Representative video frames showing LED pattern before normal charge, at fast blink, after reboot, and after recurrence.
- Mechanical/contact evidence: robot dock alignment, charging brush/contact condition, pile connector, and cable/grounding state.

## Logs And Files To Inspect

- Local cases:
  - `cases/needs-assets/problem-tracking-unknown/0060-OVm2wiWKjiXjKGkKfUrcUEyCnHd-2026-03-24-二楼测试环境充电桩充电时绿灯快速闪烁充电异常.md`
  - `cases/needs-assets/problem-tracking-unknown/0061-NHDxww8CGi67jakMu9zcX8pMnLf-2026-03-31-二楼测试环境充电桩充电时绿灯快速闪烁充电异常.md`
- Local assets:
  - `assets/problem-tracking-unknown-pt-0060/*.log`
  - `assets/problem-tracking-unknown-pt-0060/*.mp4`
  - `assets/problem-tracking-unknown-pt-0061/*.log`
  - `assets/problem-tracking-unknown-pt-0061/*.pcap`
  - `assets/problem-tracking-unknown-pt-0061/*.mp4`
- Search terms:
  - `bat_percentage`, `Battery`, `can_battery_status`, `charge`, `charging`, `充电`, `绿灯`, `快闪`, `频闪`, `J33A`, `A3778`, `A2055`, `A3771`, `A3763`, `J33A52CS`

## Likely Causes

- Charge handshake enters recognition/connection state but the session does not sustain power delivery.
- Charger controller or pile-side state machine latches into a recoverable abnormal state that reboot clears temporarily.
- Intermittent contact, pile output, or current limit causes slow/stalled charge while LED still shows a connection-related state.
- Robot BMS/CAN state or protocol compatibility causes inconsistent charge enable/current request behavior across piles.

## Exclusion Checks

- Do not diagnose a single bad pile if the same robot reproduces across several piles.
- Do not diagnose a single bad robot if multiple robots reproduce on multiple piles.
- Do not use green LED state alone as proof of charge current; compare with SOC/current/voltage trends.
- Do not treat charge recovery after reboot as root cause; it only proves state reset changes behavior.
- Do not trust a pcap filename as decoded CAN evidence; decode frames and align them to the LED/SOC window.
- Do not merge flat position-log SOC and Wormhole CAN SOC without checking robot ID and timestamp alignment.

## Confirmed Examples

- None. These cases confirm a repeated symptom pattern and useful diagnostic branches, but not a final root cause.

## Unresolved Examples

- `problem-tracking-unknown-pt-0060`: repeated green fast blink after 1 to 15 minutes across several piles and robots. Robot-side SOC trends include slow charge, flat charge, and drops; charger-side logs/current/voltage are missing.
- `problem-tracking-unknown-pt-0061`: `J33A52CS` repeats green fast blink after 15 minutes and after Ant restart. Logs show conflicting SOC trends by source; pcap files are present but not decoded with available local tooling.

## Specialist Routing

- Start with `can-bus` for BMS/charger handshake, SOC trend, and pcap decode requirements.
- Add `embedded-software` for robot-side charge state, reboot/state-machine transitions, and log timestamp alignment.
- Add `vision-media` for LED pattern, docking/contact position, and before/after reboot sequence.
- Add `network-infra` only if charger/robot service connectivity or remote controller communication appears in the evidence.
