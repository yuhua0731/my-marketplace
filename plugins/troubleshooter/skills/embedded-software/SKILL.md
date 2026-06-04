---
name: embedded-software
description: Use when diagnosis involves embedded logs, NXP logs, firmware startup, reboot markers, uptime resets, state-machine transitions, MQTT client behavior, overlay/SD-card issues, IO, sensors, or module logs.
---

# Embedded Software Specialist

## Focus

- NXP logs
- firmware startup/self-check
- `UPTIME` reset and reboot markers
- HSM/node402/state-machine transitions
- overlay/SD-card/logging failures
- MQTT client behavior on robot
- sensor and actuator state from robot-side logs

## Checks

- Identify last log before fault and first log after recovery.
- Confirm reboot only with log evidence, not UI alone.
- If logs start after the event, mark pre-event evidence missing.
- Separate robot-side MQTT loss from AP/server path loss.
- For self-check failures, identify module and firmware/config context.
- For storage issues, check overlay usage, mount failure, missing rotated logs, and recurrence.

## Output

- exact log lines and timestamps
- firmware/state-machine branch status
- excluded branches
- required firmware/config/logging follow-up
