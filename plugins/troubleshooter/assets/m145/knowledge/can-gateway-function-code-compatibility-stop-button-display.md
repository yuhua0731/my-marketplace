# CAN Gateway Function-Code Compatibility Hiding Feeder Stop Buttons

## Symptoms

- M145 Sort Control System overview does not show feeder emergency-stop or pause buttons.
- Relationship/configuration table can look structurally normal, and services may have been restarted after upload.
- Overview still shows general system state, power state, current feeder, system pause, and class-1 emergency stop status.
- The missing UI control is specific to feeder stop/pause controls, not a full frontend outage.

## Fault Tree

- Confirmed branch: overview button rendering depends on CAN gateway function-code mapping.
  - `m145-pt-0157` source says the uploaded function code was an old-version function code.
  - Source analysis says old function codes became incompatible after CAN gateway firmware upgrade.
  - Source resolution says the button display recovered after modifying the function code.
- Confirmed branch: compare relationship table with IO address variable table.
  - Relationship table screenshot shows `SITE-1`, CAN Node ID `1`, channel indexes `0o03` and `0o02`, function codes `PowerStopButton` and `UrgentStopButton`, MQTT topics `/PowerStopButton/SITE-1` and `/UrgentStopButton/SITE-1`.
  - IO address table `M145_IO地址变量表_V01.xlsx` shows feeder segment `ALL_CAN-4`, `1#9352 BUS-2`, `CAN-ID (DEC) = 1`.
  - The same IO table shows `DI03` is `暂停（黄）NO反馈` and `DI04` is `急停（红）NO反馈`.
- Likely branch: firmware upgrade changed accepted function-code names, semantics, or binding rules, so legacy `PowerStopButton` / `UrgentStopButton` entries no longer produce the expected frontend controls.
- Blocked branch: exact old-to-new function-code mapping is not visible in local assets.
  - No raw config before/after, gateway firmware version, frontend/service logs, or corrected relationship table is present.

## Evidence Needed

- CAN gateway firmware version before and after the upgrade.
- Raw relationship configuration table before and after the fix.
- Exact accepted function-code names for the upgraded gateway firmware.
- Frontend/backend logs showing whether button metadata was ignored, filtered, or failed validation.
- CAN gateway/config-loader logs around upload and service restart.
- Post-fix overview screenshot showing feeder emergency-stop and pause buttons restored.

## Logs And Files To Inspect

- `cases/accepted/m145/0157-WTwpwso86iMoj1kCZ2ycLn6Dn6b-2026-06-11-M145供包机急停暂停按钮配置后不显示.md`: source body.
- `assets/m145-pt-0157/retry-image-001-Xnmtb8npBoWdhexsEHfc1SFEn4g.png`: Sort Control System overview, time `2026-06-12 11:27:13`, station `M145-SITE-1`, feeder `M145-SITE-1`, missing feeder stop/pause buttons at the marked area.
- `assets/m145-pt-0157/retry-image-002-U40BbIO97oIiwoxqDlCcTipynke.png`: relationship table with `PowerStopButton`, `UrgentStopButton`, `/PowerStopButton/SITE-1`, `/UrgentStopButton/SITE-1`, CAN Node ID `1`, and channel indexes `0o03` / `0o02`.
- `assets/m145-pt-0157/retry-image-003-SpUabFqHkoKhrFxUub8cg1Zbn43.png`: `M145_IO地址变量表_V01.xlsx`, feeder segment `ALL_CAN-4`, `1#9352 BUS-2`, `250K Bit/sec`, `CAN-ID (DEC) = 1`, `DI03` pause yellow NO feedback, `DI04` emergency-stop red NO feedback.
- Search terms: `PowerStopButton`, `UrgentStopButton`, `M145-SITE-1`, `/PowerStopButton/SITE-1`, `/UrgentStopButton/SITE-1`, `供包机急停`, `供包机暂停`, `功能码`, `CAN网关固件升级`, `DI03`, `DI04`.

## Likely Causes

- Relationship table uses old function-code names that the upgraded CAN gateway firmware no longer recognizes.
- Function-code semantics for feeder emergency stop and pause changed across gateway firmware versions.
- The UI does not render feeder control buttons when the gateway/config service cannot bind function-code metadata to supported topics or IO channels.

## Exclusion Checks

- Exclude generic frontend outage if other overview widgets, status indicators, and system controls render normally.
- Exclude missing relationship upload only after confirming the running service read the uploaded table, not merely that the table exists locally.
- Exclude IO wiring or CAN electrical failure if the symptom is only missing UI buttons and there are no CAN heartbeat, input-state, or gateway communication alarms.
- Exclude firmware incompatibility only after checking the gateway firmware version against the function-code schema and corrected table.
- Do not infer the corrected function-code names from this case; require the fixed table or firmware schema.

## Confirmed Examples

- `m145-pt-0157`: M145 overview does not display feeder emergency-stop/pause buttons. Source analysis says the uploaded function code was an old version and became incompatible after CAN gateway firmware upgrade. After modifying the function code, display recovered.

## Unresolved Examples

- `m145-pt-0157`: exact upgraded function-code names, firmware version, raw logs, and post-fix screenshot are not present in local assets.

## Specialist Routing

- Start with `embedded-software` for CAN gateway firmware version, config-loader behavior, and function-code schema compatibility.
- Add `can-bus` for gateway node/channel mapping and IO state only if electrical/CAN evidence is needed.
- Add `scheduler-traffic` or frontend/service routing only if the uploaded table is correct but the overview still does not render the control.
