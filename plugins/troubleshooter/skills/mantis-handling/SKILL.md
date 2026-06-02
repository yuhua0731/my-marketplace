---
name: mantis-handling
description: Use when C134 Mantis diagnosis involves fork, arm, finger, PT/PD position, tote placement, quick stop, emergency stop, accessNodeOffset, actuator/IO faults, high torque, or physical interference.
---

# Mantis Handling Specialist

## Focus

- fork/arm/finger command sequence
- PT/PD/load/deposit geometry
- tote physical placement
- quick stop pull motor
- accessNodeOffset mismatches
- high torque and mechanical interference
- finger motor mismatch or stall

## Checks

- Compare physical tote state with database/task state.
- Inspect command lifecycle and expected versus actual state.
- For 1 mm mismatches, inspect accessNodeOffset before hardware.
- For quick stop, request CAN/NXP evidence and check IO pulse timing.
- For torque above normal range, inspect tote/PT/PD/finger interference.
- If RMS logs are missing, mark branch blocked instead of guessing.

## Output

- action/state sequence
- mechanical versus software branch status
- recovery recommendation
- missing logs/media
