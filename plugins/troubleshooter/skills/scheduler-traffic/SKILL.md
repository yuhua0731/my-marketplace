---
name: scheduler-traffic
description: Use when C134 diagnosis involves SAS, RCS, RMS, WAS, task assignment, reservations, locks, deadlock/interlock, no-action symptoms, duplicate deposit tasks, Redis, Kafka task state, or robot availability.
---

# Scheduler Traffic Specialist

## Focus

- task and command generation
- robot reservations and interlocks
- duplicate assignment
- no-task/no-action after state change
- Redis timeout and lock behavior
- SAS/RCS/RMS/WAS service timelines

## Checks

- Build a timestamped task/command/reservation timeline.
- Confirm whether robot received a next command.
- For no-action with healthy robot, inspect scheduler/service state before robot hardware.
- For duplicate deposit contention, verify available PD/tunnel count and simultaneous decisions.
- For Redis timeout, inspect whether orchestration logs stopped or lock was not released.
- Preserve exact task labels and command labels.

## Output

- task/command/reservation timeline
- service-side root cause or exclusion
- recovery and logging recommendations
