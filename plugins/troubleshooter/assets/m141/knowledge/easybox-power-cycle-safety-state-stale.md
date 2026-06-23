# EasyBox Power-cycle Safety State Stale

## Symptoms

- OmniSort / M141 loses incoming power during shuttle-mode self-run, then power is reconnected.
- UI reports motor and power-related events such as `电机报错`, `供包机CAN节点心跳丢失`, `导轨供电电源1异常`, or `导轨供电电源2异常`.
- After power returns, line-stick cart electromagnetic-force and safety-lock states shown by the system are stale or wrong.
- Even when the physical class-1 emergency stop is not pressed and the door lock is locked, the UI may still show `一类急停` red and cannot recover until the status is refreshed or EasyBox/CAN Gateway is updated.

## Fault Tree

1. Start from the recovery state after power returns, not only from the initial motor/CAN alarms.
   - If controller/feeder indicators are green but `动力电源` or `一类急停` remains red, inspect the safety-state reporting path.
   - If all devices are offline, diagnose power/network first before stale safety state.
2. Separate real emergency-stop state from stale imported node state.
   - Check whether the physical emergency-stop button is pressed, whether the door is locked, and whether safety-lock/electromagnetic-force inputs are actually triggered.
   - If physical inputs are normal but UI still shows red, suspect stale state in EasyBox/CAN Gateway or imported EasyBox table nodes.
3. Check whether EasyBox also powered off.
   - If EasyBox loses power, it may not emit a change event on reboot because the imported node state did not change while it was offline.
   - On reboot, EasyBox should actively query all imported node states and report them once.
4. Review the changed safety logic.
   - In branch `I-1472-mini-power-status-as-power-stop-signal`, power-supply feedback was treated as an emergency-stop signal.
   - This changes the recovery flow: door lock can fail before power is restored, and the user may need to restore power with the blue button before locking the door again.
5. Validate the fix with gateway version and reboot behavior.
   - `CAN Gateway 1.0` / EasyBox version `V3.1.4` is the confirmed fix path in `m141-pt-0171`.
   - After update/restart, verify that emergency-stop button and safety-lock states are refreshed accurately.

## Evidence Needed

- UI event timeline around power loss and recovery.
- Physical emergency-stop, door-lock, electromagnetic-force, and safety-lock state at recovery time.
- EasyBox/CAN Gateway version and reboot/update records.
- Logs or screenshots showing feeder CAN heartbeat loss and conveyor error codes.
- Operator recovery sequence: door lock, blue power button, refresh status, one-key apply/release electromagnetic force.
- Raw EasyBox/CAN logs if available; screenshots alone confirm UI state but not frame-level CAN timing.

## Logs And Files To Inspect

- Search UI/events for `一类急停`, `动力电源`, `门上锁失败`, `导轨供电电源`, `供包机CAN节点心跳丢失`, `电机报错`.
- Search device logs for `CONVEYOR_EVENT_0X03`, `CONVEYOR_EVENT_0X0F`, `receive-conveyor-error`, `SITE-1_CONVEYOR`, `SITE-2_CONVEYOR`.
- Inspect EasyBox/CAN Gateway version page for `V3.1.4` or later.
- Inspect screenshots/videos for whether controller/feeder are green while emergency-stop/power remains red.

## Likely Causes

- Stale safety state is likely when physical inputs are normal but UI still shows emergency stop or power fault after EasyBox power-cycle.
- EasyBox/CAN Gateway missing reboot-time state query/report is likely when the imported electromagnetic-force/safety-lock state did not change while EasyBox was powered off.
- Power-stop-as-emergency-stop logic can make the recovery path user-visible and different from the previous flow.
- Initial motor/CAN heartbeat events can be expected consequences of cutting incoming power; do not treat them as the root cause unless they remain after state refresh and power recovery.

## Exclusion Checks

- If the physical emergency-stop is still pressed or the door is not actually locked, do not classify as stale state.
- If EasyBox/CAN Gateway remains offline, diagnose network/power for the gateway first.
- If version is already updated and reboot-time state report is confirmed, inspect upper-system state clearing and UI refresh logic.
- If raw CAN/EasyBox logs are missing, do not claim exact frame-level missed report timing.

## Confirmed Examples

- `m141-pt-0171`: M141-3 cut incoming power at `2026-06-16 15:34`, reconnected at `15:36`, and class-1 emergency stop could not recover by `16:42`.
  - Event UI shows `2026-06-16 15:34:39` `电机报错`, `15:34:44` `供包机CAN节点心跳丢失`, and `15:34:54/55` `导轨供电电源1/2异常`.
  - Debug page at `2026-06-16 16:37:14` shows line-stick cart electromagnetic-force, position, and safety-lock states as triggered.
  - Runtime overview at `2026-06-16 16:41:29` shows `动力电源` red and `一类急停` red while feeder and controller indicators are green.
  - Log screenshot shows `M141-3-SITE-2-CONVEYOR` `CONVEYOR_EVENT_0X03` and `M141-3-SITE-1_CONVEYOR` `CONVEYOR_EVENT_0X0F`.
  - Chat analysis states EasyBox also powered off; after EasyBox powers on, the mobile rack electromagnetic-force state had not changed, so it did not actively report. The proposed rule is to query imported EasyBox table nodes on power-up and report once.
  - Resolution screenshot confirms `CAN Gateway 1.0` current version `V3.1.4`; source text says updating EasyBox to `3.1.4` and restarting can correctly refresh emergency-stop button state.

## Unresolved Examples

- `m141-pt-0171` lacks raw EasyBox/CAN logs, so the exact missed CAN/report frame timing is not confirmed.
- The case confirms behavior for M141-3 and EasyBox/CAN Gateway `3.1.4`; verify the same power-cycle query/report behavior before generalizing to other M141 stations or older gateway versions.

## Specialist Routing

- `embedded-software`: EasyBox/CAN Gateway reboot behavior, version, state import/report logic, upper-system state clearing.
- `can-bus`: feeder CAN heartbeat loss, conveyor error events, raw CAN/EasyBox frames if available.
- `scheduler-traffic`: whether system recovery flow blocks startup/tasks after safety state remains red.
- `vision-media`: UI/video confirmation of power, emergency-stop, controller, feeder, and safety-lock state only.
