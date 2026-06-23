# Problem Tracking Unknown Fault Taxonomy

## Actuator Scanner State

- `problem_tracking_unknown.actuator_non_lock_barcode_pool_stale_display`
  - Product line: unknown or newly classified; source UI says system ID `M123`, but case metadata does not prove final product line/project assignment.
  - Typical symptom: in actuator mode with `非锁定`, scan and delivery succeed but the delivered barcode remains visible instead of returning to `未扫到条码`.
  - Primary evidence: UI screenshot/video showing `非锁定`, barcode `123455`, post-delivery stale barcode display, and code screenshot of `tryToPullProductBarcodeFromPool` returning before `qty--`.
  - Primary specialists: `scheduler-traffic`, `vision-media`, `embedded-software`.
  - Knowledge: `knowledge/actuator-non-lock-barcode-pool-stale-display.md`.

## Wormhole Network Boot

- `problem_tracking_unknown.wormhole_low_temp_reboot_lan_unreachable`
  - Product line: unknown or newly classified; evidence points to Wormhole/MT7621 board-level network boot, not a finished product line.
  - Typical symptom: under low-temperature repeated power-cycle testing, CAN command send succeeds but `192.168.40.1` network detection fails three times after reboot.
  - Primary evidence: cycle number, low-temperature condition, post-reboot wait window, `192.168.40.1` test output, OpenWrt/Wormhole firmware metadata, serial/netifd/DSA/PHY logs.
  - Primary specialists: `network-infra`, `embedded-software`, `can-bus`, `vision-media`.
  - Knowledge: `knowledge/wormhole-low-temp-reboot-lan-unreachable.md`.

## System Reset And Queue State

- `system_reset_queue_lock_race`
  - Product line: unknown or newly classified; screenshot suggests operation-station/shuttle workflow but metadata does not confirm product line.
  - Typical symptom: after deliberate mains power cut/system reset during shuttle-mode self-run or test workflow, UI reports `QUEUE RESET`.
  - Primary evidence: `problem-tracking-unknown-pt-0176` screenshot shows `异常：QUEUE RESET`, `发生时间：2026-06-17 15:54:06`, and `RETRY CREATE TEST ORDER`; source analysis says reset clears queue data and in-flight task lock can fail.
  - Primary specialists: `scheduler-traffic`, `embedded-software`, `vision-media`.
  - Knowledge: `knowledge/system-reset-queue-lock-race.md`.

## OmniFlow Charging

- `omniflow.charging_pile_green_fast_blink`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: Ant auto-charge starts normally, then charging pile green light fast-blinks or frequency-blinks after 1 to 15 minutes.
  - Primary evidence: robot ID, pile ID, LED video/frame, SOC/current/voltage trend, BMS/CAN charge status, pile controller log.
  - Primary specialists: `can-bus`, `embedded-software`, `vision-media`.
  - Knowledge: `knowledge/charging-pile-green-fast-blink.md`.

## OmniSort Rail Power Alarm Lifecycle

- `omnisort.rail_power_alarm_flood_after_power_cut`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: after intentional动力电源 cut and startup, Sort Control System repeatedly reports `导轨供电电源1异常，请检查` and `导轨供电电源2异常，请检查`, often self-closing without handling, and can flood the event table during equipment inspection.
  - Primary evidence: UI alarm screenshots, backend alarm lifecycle logs, rail power voltage/current/status telemetry, startup timing, and maintenance-mode state.
  - Primary specialists: `embedded-software`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/rail-power-alarm-flood-after-power-cut.md`.

## Evidence Status

- Treat successful CAN command send before reboot as test-fixture evidence; do not diagnose CAN first when the failure is `192.168.40.1` after reboot.
- Treat OpenWrt image metadata such as `image 1.1, device 1.0` and `swconfig` to `DSA` migration failure as a configuration/firmware risk branch, not a confirmed root cause.
- Treat low-temperature recurrence as stress-condition evidence; hardware root cause still needs serial logs, link/PHY status, or power/reset measurements.
- Cases may remain `needs-assets` after distilled training when the reusable symptom pattern is valuable but charger-side logs, decoded CAN frames, or exact current/voltage data are missing.
- Root cause must remain `unknown` unless LED state, SOC/current/voltage trend, and charger/robot state logs align in the same time window.
- Treat stale `system_area: CAN` labels as weak evidence; `QUEUE RESET` after reset/power-cut routes to scheduler/queue-state first unless CAN logs exist.
- Treat rail-power alarms after intentional动力电源切断 as alarm-lifecycle/power-state gating first; escalate to real hardware only when rail telemetry remains abnormal after the startup/maintenance grace period.
- Treat actuator non-lock stale barcode after successful scan/delivery as barcode-pool state cleanup first; do not route to scanner hardware or barcode-format debugging unless scan success is contradicted.
