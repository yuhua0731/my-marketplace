# C134 High-Priority Asset Intake Plan

source: `training/c134/high-priority-asset-downloads.md`
local_asset_status: no downloaded case assets found under `assets/`
status: waiting for local files

## Batch 1: Ant Reboot / Power Root Cause

Purpose: resolve repeated accepted-like reboot cases with CAN + NXP + system/wormhole evidence.

Request these first:

- `c134-0069` A-107 原地重启
  - `can1_C134_A-107_9点整至9点14分.pcap`
  - `can2_C134_A-107_9点整至9点14分.pcap`
  - `nxp_C134_A-107_9点整至9点14分.log`
  - `wormhole_C134_A-107_9点整至9点14分.log`
- `c134-0036` A-111 运行过程“重启”/蓝灯常亮
  - `can1.pcap`
  - `can2.pcap`
  - `nxp.log`
  - `wormhole.log`
- `c134-0124` A106 原地重启
  - `A-106_can1_20260106T015000Z_to_20260106T021500Z.pcap`
  - `A-106_can2_20260106T015000Z_to_20260106T021500Z.pcap`
  - `A-106_nxp_20260106T015000Z_to_20260106T021500Z.log`
  - `A-106_system_20260106T015000Z_to_20260106T021500Z.log`
- `c134-0412` A-107 运动过程中重启
  - `A107-can1-20260126-185000-to-20260126-192000.pcap`
  - `A107-can2-20260126-185000-to-20260126-192000.pcap`
  - `A107-nxp-20260126-185000-to-20260126-192000.log`
  - `A107-wormhole-20260126-185000-to-20260126-192000.log`
- `c134-0437` A-107 运行过程中停止不动
  - `A-107_can1_20260126T104127Z_to_20260126T111127Z.pcap`
  - `A-107_can2_20260126T104127Z_to_20260126T111127Z.pcap`
  - `A-107_nxp_20260126T104127Z_to_20260126T111127Z.log`
  - `A-107_system_20260126T104127Z_to_20260126T111127Z.log`
- `c134-0005` A-101 运动过程中重启
  - `A-101_can1_20260129T082537Z_to_20260129T085537Z.pcap`
  - `A-101_can2_20260129T082537Z_to_20260129T085537Z.pcap`
  - `A-101_nxp_20260129T082537Z_to_20260129T085537Z.log`
  - `A-101_system_20260129T082537Z_to_20260129T085537Z.log`

Optional only if timing/physical state is disputed: listed `.jpg`, `.MOV`, `.mp4` files for the same cases.

## Batch 2: Ant Motion / Localization

Purpose: resolve floor-code, WS entry/exit, and camera/fork collision patterns.

Request these after Batch 1:

- `c134-0361` A-102 enters WS001-3 and scissor hits drag bar
  - all listed videos/images
  - all listed NXP/system/CAN logs if available
- `c134-0015` A-102 跑偏
  - NXP/CAN/wormhole logs first
  - video/images second
- `c134-0199` A103 跑偏
  - NXP/CAN logs and route video
- `c134-0208` A-107 WS001-3 转角过大
  - NXP log and command/MQTT/RCS evidence
- `c134-0003` A-107 跑偏
  - video/images plus NXP/CAN if listed

Minimum judgment requirement: exact route segment, DM read/no-read sequence, command start/end coordinates, and video when physical collision or WS interference is claimed.

## Batch 3: Ant Network

Purpose: separate single-robot NIC/failover from site-wide network path.

Request:

- `c134-0139` A-111 断连
- `c134-0167` A107 断连
- `c134-0371` 全库机器人短暂断连
- `c134-0370` 全库短暂断连

Minimum files: robot system/wormhole logs, NXP MQTT disconnect logs, ping/AP/EasyBox monitoring, and any pcap/dumpcap. Screenshots are optional unless they contain exact timestamps or IPs.

## Batch 4: Ant Load Handling

Purpose: resolve no-lift, no-action, and PT/WS handling failures.

Request:

- `c134-0055` A106 在工作台没有举升动作
  - `A-106_can1_20260202T131441Z_to_20260202T135141Z.pcap`
  - `A-106_can2_20260202T131441Z_to_20260202T135141Z.pcap`
  - `A-106_nxp_20260202T131441Z_to_20260202T135141Z.log`
  - corresponding system/wormhole/RCS/WAS logs if in omitted `... 4 more`
  - videos only if lift/sensor timing is unclear
- `c134-0061` A-105 A1-S2-B2 接驳位还箱失败
  - `14点20分至14点50分 A-105蚂蚁机器人can1.pcap`
  - `14点20分至14点50分 A-105蚂蚁机器人can2.pcap`
  - `14点20分至14点50分 A-105蚂蚁机器人nxp.log`
  - `14点20分至14点50分 A-105蚂蚁机器人wormhole.log`

Minimum judgment requirement: load sensor transition, lift/fork state, command lifecycle, tote physical seating, and exact PT/WS geometry.

## Intake Rules

- Put each downloaded set under `assets/<case_id>/`.
- Keep original filenames unchanged.
- After files arrive, update the corresponding `cases/needs-assets/c134/<case>.md`.
- Promote only when logs/video are sufficient to distinguish observed fact, inference, and root cause.
- If only screenshots arrive for a log-dependent case, keep it in `needs-assets`.
