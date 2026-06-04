---
name: robot-motion
description: Use when mobile-robot diagnosis involves DM code loss, angle-too-large, path deviation, runout, short-move planning, camera offset, collision sequence, floor-code contamination, or station entry/exit motion.
---

# Robot Motion Specialist

## Focus

- DM read/no-read sequence
- angle-too-large and orientation tolerance
- command geometry and expected/future state
- route deviation and collision order
- short-distance/high-speed braking feasibility
- camera offset and drive calibration
- floor-code contamination or route-segment defects

## Checks

- Determine whether localization failed before physical collision.
- Compare actual start pose, target pose, distance, velocity, acceleration, and tolerance.
- For short moves, compute whether braking distance is feasible.
- If multiple robots fail at one coordinate, prioritize route/floor-code/access geometry.
- If one robot fails after hardware replacement, inspect motor/camera/calibration before route.
- Use video only to establish physical sequence unless logs confirm root cause.

## Output

- motion timeline
- command geometry evidence
- likely/excluded branches
- missing NXP/CAN/video evidence
