# Conveyor External Error Replay Force Unload

## Symptoms

- Mini / MiniSort feeder or conveyor keeps force-unloading after reboot or system reset.
- The operator did not click the force-unload popup before resetting the system; after reboot the popup disappears.
- After one delivery error, pressing pause can leave the feeder stopped while the robot belt keeps running.
- The system may report `向机器人发送暂停命令响应超时`.

## Fault Tree

- Confirmed branch: feeder disconnect/reconnect creates an external error at central control.
  - In `minisort-test-pt-0070`, source analysis says the feeder disconnected at about `11:45`.
  - The screenshot shows `2026-06-03T11:45:55.280000+0800 ERROR: M143-SITE-1-CONVEYOR: disconnect`.
  - The same screenshot shows `M143-SITE-1-CONVEYOR: recover` and `set errorCode by server: CONVEYOR RECONNECTED`.
  - Source analysis calls this external error `外部错误0x06` for `供包机断连`.
- Confirmed branch: reset clears central-control error state but the feeder can replay the old external error after the next startup.
  - Source text says test staff reset the system at `13:15` without clicking the force-unload popup.
  - After reset, central control no longer has the `供包机断连` / `外部错误0x06` error-code record.
  - On startup, the feeder sends the same `外部错误0x06` back to central control.
- Confirmed branch: recovery/force-unload cannot close cleanly when the error code is no longer known by central control.
  - Source analysis says the operator clicked error recovery and force unload started.
  - Because central control had no matching `供包机断连` error code, the force-unload state could not end and the robot continued force-unloading.
- Design branch: the preferred durable fix is embedded-side suppression of old external errors across startup.
  - Source lists three options and states that embedded modification makes the old startup-sent external error stop being pushed after the next boot.
  - This produces normal operation: no force unload, no popup, and if an external error happens during operation, feeder disconnect/reconnect can recover automatically without force unload.

## Evidence Needed

- Raw central-control log around `2026-06-03T11:45:47` to `11:45:55`, including complete `errorCode`, popup, recover, and force-unload lines.
- Feeder/embedded log proving whether `外部错误0x06` was persisted and resent after reboot.
- System reset log around `13:15`, including central-control error-state cleanup.
- UI operation record: whether the force-unload popup was ignored, dismissed, or recovered before reset.
- Post-fix retest for all three candidate solutions, especially embedded suppression of startup replay.

## Logs And Files To Inspect

- Case body: `cases/accepted/minisort-test/0070-Lqv4wh9Lwib6fUkFOyTc0tW6nPd-2026-06-03-Mini-重启后供包机一直在强排.md`.
- `assets/minisort-test-pt-0070/001-image-249a9ca66003.png`: log screenshot inspected visually and with OCR. It shows `/StackLightBuzzer/DOOR-B`, `K16A28MN conveyor is not unload force, finish unload force, true`, `DISPATCHING_SHUTTLE_TO_SITE_HAS_ERRORS_FAIL`, `M143-SITE-1-CONVEYOR: disconnect`, `recover`, `set errorCode by server: CONVEYOR RECONNECTED`, and `M143-DOOR-B-BULB turn to yellow`.
- Search terms: `外部错误0x06`, `供包机断连`, `CONVEYOR RECONNECTED`, `M143-SITE-1-CONVEYOR`, `forceUnloadActionBase`, `is not unload force`, `finish unload force`, `DISPATCHING_SHUTTLE_TO_SITE_HAS_ERRORS_FAIL`, `向机器人发送暂停命令响应超时`, `RESET SYSTEM`, `强排`.

## Likely Causes

- External feeder-disconnect error is persisted or replayed by the feeder/embedded side after reboot while central-control state has been reset.
- Central control cannot map the replayed external error to a live error-code record, so error recovery cannot finish the force-unload lifecycle.
- Force-unload/recovery code path lacks idempotent handling for stale external errors after system reset.
- Less likely as primary cause: mechanical feeder jam, because the source ties recovery to error-code/state handling rather than a physical blockage.

## Exclusion Checks

- Do not route to generic M111 conveyor-recovery race only from `Mini`, `供包机`, `恢复`, and `强排`; this is a MiniSort Test stale external-error replay case.
- Do not diagnose feeder motor or belt hardware if logs show disconnect/recover and error-code replay explains the force-unload state.
- Do not treat the vanished popup as recovery; the source says the popup disappeared after system reset while the stale external error still came back.
- Do not choose central-control auto force-unload as a final fix without checking abnormal-mouth force-unload behavior, because source warns parcels delivered within 5 seconds after startup can be force-unloaded incorrectly.
- Do not choose a default-error-code popup fix as final if product behavior requires no unexplained popup after normal reboot.

## Confirmed Examples

- `minisort-test-pt-0070`: after feeder parameter changes and feeder reboot, test staff reset the system without clicking the force-unload popup. Later, the feeder replayed `外部错误0x06` for `供包机断连`; central control had already cleared that error-code record, so recovery/force unload could not finish and the robot continued force-unloading. Screenshot evidence shows `M143-SITE-1-CONVEYOR: disconnect`, `recover`, `set errorCode by server: CONVEYOR RECONNECTED`, and dispatch error-return lines around `2026-06-03T11:45:55`.

## Unresolved Examples

- `minisort-test-pt-0070`: raw logs, embedded retained-error storage, central-control reset cleanup logs, and post-fix retest artifacts are not local.

## Specialist Routing

- Start with `scheduler-traffic` for central-control error state, force-unload lifecycle, popup/recovery behavior, and dispatch failure propagation.
- Add `embedded-software` for feeder-side external-error retention/replay across startup.
- Add `network-infra` only for the feeder disconnect/reconnect transport evidence.
- Add `vision-media` only to inspect screenshots; this case is not primarily visual.
