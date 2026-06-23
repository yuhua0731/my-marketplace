# M145 Fault Taxonomy

## CAN Gateway And IO Function Codes

- `omnisort.m145.can_gateway_function_code_compatibility_stop_button_display`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M145 overview does not display feeder emergency-stop or pause buttons after relationship table upload and service restart.
  - Primary evidence: source says old-version function codes became incompatible after CAN gateway firmware upgrade; relationship table has `PowerStopButton` / `UrgentStopButton`; IO table maps `DI03` to pause and `DI04` to emergency stop; modifying function code restores display.
  - Primary specialists: `embedded-software`, `can-bus`; add `scheduler-traffic` only if config service/frontend binding remains suspect after function-code schema is verified.
  - Knowledge: `knowledge/can-gateway-function-code-compatibility-stop-button-display.md`.

## Scheduler Configuration

- `omnisort.m145.scheduler_config_hardlink_invalid_motion_command`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: system starts and robot appears online, but robot does not move; map and physical position diverge; `END CMD TIMEOUT ERROR` follows.
  - Primary evidence: runtime `move_cmd payload` with impossible `speed`/`acc`/`dec`, normal visible scheduler config, and duplicated config directories or lost hardlink.
  - Primary specialists: `scheduler-traffic`, `embedded-software`, `network-infra`, `vision-media`.
  - Knowledge: `knowledge/scheduler-config-hardlink-loss-invalid-motion-command.md`.

## Overview Geometry Rendering

- `omnisort.m145.overview_robot_width_scale_config_mismatch`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M145 overview page renders robot icons wider than slot/grid cells even though robot width config appears normal.
  - Primary evidence: overview screenshot with over-wide robot icon, parameter screenshot with `机器人宽 (mm)`, runtime config screenshot or raw config with `positionMap.shuttleWidth`, and map/grid scale values.
  - Primary specialists: `scheduler-traffic`, `vision-media`, `embedded-software`.
  - Knowledge: `knowledge/overview-robot-width-scale-config-mismatch.md`.

## Mechanical Interference

- `omnisort.m145.throwing_baffle_drive_shaft_scrape`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M145 lift-module throwing-mechanism baffle or side guard scrapes the active drive shaft, wheel, or roller.
  - Primary evidence: source reports `提升模组抛物机构挡板与主动轮轴剐蹭`; local close-up photos show the baffle/guard, drive shaft/roller, and belt path with very small clearance; local video thumbnail shows the same assembly envelope.
  - Primary specialists: `vision-media`, `robot-motion`; add `embedded-software` only if logs show abnormal commanded motion or cycle timing.
  - Knowledge: `knowledge/throwing-baffle-drive-shaft-scrape.md`.

- `omnisort.m145.drag_chain_sag_stainless_bracket_scrape`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M145 drag chain is too long; near D door, it folds downward and scrapes a stainless bracket.
  - Primary evidence: source explicitly reports `拖链较长`, `运行到D门附近`, `拖链折叠下坠`, and `与不锈钢支架发生剐蹭`; local video shows the drag-chain path in the rail/frame/bracket area.
  - Primary specialists: `vision-media`, `robot-motion`; add `embedded-software` only if logs show abnormal motion commands or state transitions.
  - Knowledge: `knowledge/drag-chain-sag-stainless-bracket-scrape.md`.

## Feeding Mechanical Parameters

- `omnisort.m145.lift_belt_coefficient_roller_diameter_small_parcel`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M145 minimum-size parcel feeding logic ends early; lift module feeds early/slowly enough that small parcels may not reach the robot or length measurement becomes biased.
  - Primary evidence: same speed command is sent to lift-module belt and feeder belt; tachometer images show lift-module `35.525 m/min` and feeder `48.795 m/min`; reducer ratios are close (`0.7` vs `0.71` / `14:20` vs `20:28`); source chat says lift-module roller diameter changed from `φ38` to `φ30`.
  - Primary specialists: `vision-media`, `embedded-software`, `scheduler-traffic`; use scheduler only after actual belt speed and mechanical parameters are checked.
  - Knowledge: `knowledge/lift-belt-coefficient-roller-diameter-small-parcel.md`.

## Evidence Status

- Treat UI config values as expected-state evidence, not proof of what the running scheduler read.
- Treat raw command payload as higher-value evidence than overview state when diagnosing no-move/timeout.
- Treat screenshot-only filesystem conclusions as provisional until path/inode checks or raw deployment logs confirm them.
- Treat overview geometry screenshots as display/config evidence only; prove renderer root cause with raw config, frontend payload, and scale calculation.
- Treat old function-code names as firmware-version-dependent; a relationship table that looks structurally complete can still fail after CAN gateway firmware upgrade.
- Treat missing feeder stop/pause buttons as a config/schema compatibility branch before blaming frontend rendering or CAN wiring.
- Treat lift-module baffle/drive-shaft scrape as a local mechanical-envelope problem; do not merge it with drag-chain scrape or belt-speed coefficient cases.
- Treat a close static photo as strong evidence of small clearance, but still require witness marks, measured clearance, or cycle video before prescribing part changes.
- Treat drag-chain scrape as a dynamic mechanical-envelope problem; do not prove clearance from a static photo alone.
- Treat unclear video contact frames as an evidence gap, not as confirmed root-cause detail.
- Treat identical configured lift/feeder belt coefficients as suspect after roller diameter changes; actual belt-speed measurement outranks assumed mechanical equivalence.
