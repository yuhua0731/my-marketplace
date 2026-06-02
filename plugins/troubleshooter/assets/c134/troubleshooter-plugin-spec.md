# Troubleshooter Plugin Spec

status: draft
target_plugin: `Troubleshooter`
primary_corpus: C134 field cases

## Goal

Take an issue packet or Feishu problem document, identify the observed symptom, build a fault tree, route evidence to specialists, and return a diagnosis that separates facts, claims, inference, confirmed cause, and missing evidence.

## Input Packet

- title/source
- product/project
- visible description
- timestamps
- robot/device IDs
- screenshots/videos
- logs: NXP, system/wormhole, CAN/candump/pcap, MQTT/Kafka/RCS/RMS/SAS
- current local files under `assets/<case_id>/`
- known recovery actions

## Output Packet

- decision: `diagnose`, `needs-assets`, `insufficient`, `reject`
- symptom summary
- impact
- observed facts
- evidence used
- fault tree with branch status: `confirmed`, `likely`, `excluded`, `blocked`
- root cause or operational conclusion
- next checks
- missing assets
- sensitivity/redaction notes
- specialist notes

## Leader Agent

Responsibilities:

- read source packet first
- classify system area with `docs/c134/fault-taxonomy.md`
- load matching knowledge file from `docs/c134/knowledge/`
- build initial fault tree from symptom
- decide specialist routing
- merge specialist conclusions only after checking conflicts
- keep unresolved branches explicit

Default route order:

1. exact symptom and system area
2. highest diagnostic value logs
3. physical/video evidence
4. scheduler/service state
5. recovery and recurrence

## Specialists

### can-bus

Use for:

- CANopen/device state
- motor heartbeat
- quick stop
- TPDO/IO timing
- boost module voltage/current
- candump/pcap timing

Outputs:

- frame/time evidence
- device state transitions
- confirmed/excluded electrical or motor branches

### embedded-software

Use for:

- NXP logs
- firmware startup/self-check
- reboot markers and `UPTIME`
- state-machine transitions
- overlay/SD-card/logging failures
- MQTT client behavior on robot

Outputs:

- exact log lines
- firmware/state-machine branch status
- required firmware/config follow-up

### robot-motion

Use for:

- Ant DM loss
- angle-too-large
- path/run deviation
- short-move planning
- camera offset
- collision sequence

Outputs:

- command geometry
- scan/read sequence
- motion fault tree branch result

### mantis-handling

Use for:

- Mantis fork/arm/finger
- PT/PD position
- tote placement
- quick stop pull motor
- accessNodeOffset mismatch
- high torque or physical interference

Outputs:

- action/state sequence
- mechanical versus software branch status
- recovery handling recommendation

### scheduler-traffic

Use for:

- SAS/RCS/RMS/WAS task state
- reservations and locks
- duplicate assignment
- no-task/no-action symptoms
- Redis lock/timeouts

Outputs:

- task/command/reservation timeline
- service-side root cause or exclusion

### network-infra

Use for:

- robot disconnect
- AP/EasyBox/ping
- MQTT/Kafka/RVS
- site-wide disconnect
- server disk I/O and EFK pressure

Outputs:

- connectivity scope
- network path branch status
- robot versus site/server conclusion

### vision-media

Use for:

- videos/images
- robot pose
- tote placement
- PT/PD interference
- indicator light
- floor-code contamination
- monitor timestamp offset

Outputs:

- physical observation timeline
- evidence confidence
- missing video/image requests

### workstation

Use for:

- WS/WLED
- operator station
- light strip
- workstation sensors

Guardrail: WLED belongs to workstation, not Ant. A WS location in a title does not automatically mean workstation root cause.

## Routing Map

- `ant.power`: embedded-software, can-bus, scheduler-traffic, network-infra
- `ant.motion_localization`: robot-motion, embedded-software, can-bus, vision-media
- `ant.network`: network-infra, embedded-software
- `ant.load_handling`: embedded-software, robot-motion, scheduler-traffic, vision-media
- `mantis.load_handling`: mantis-handling, can-bus, embedded-software, scheduler-traffic, vision-media
- `mantis.power`: embedded-software, can-bus, scheduler-traffic
- `mantis.network`: network-infra, embedded-software
- `workstation_wled`: workstation, network-infra if controller/network evidence exists

## Knowledge Files

- `docs/c134/knowledge/ant-power.md`
- `docs/c134/knowledge/ant-motion-localization.md`
- `docs/c134/knowledge/ant-network.md`
- `docs/c134/knowledge/ant-load-handling.md`
- `docs/c134/knowledge/mantis-load-handling.md`
- `docs/c134/knowledge/mantis-power-network.md`

## Asset Handling

- If Feishu attachments are inaccessible, return `needs-assets`.
- Request only files needed to decide the active fault-tree branches.
- Place files under `assets/<case_id>/`.
- Do not treat screenshots as proof of log-level root cause.
- Do not promote from `needs-assets` until evidence is sufficient.

## Prompt Guardrails

- Preserve exact timestamps, command labels, robot IDs, log names, coordinates, firmware/config names, and source wording.
- Mark chat claims as claims unless supported by logs/video/config/repeated evidence.
- Keep Ant, Mantis, workstation, scheduler, network, and server branches separate.
- Use `unknown` instead of inventing causes.
