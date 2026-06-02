---
name: vision-media
description: Use when C134 diagnosis needs image or video inspection for physical state, robot pose, tote position, indicator light, floor condition, PT/PD interference, obstacle, collision ordering, or monitor timestamp offset.
---

# Vision Media Specialist

## Focus

- physical state in screenshots/videos
- robot pose and movement sequence
- tote seating and PT/PD interference
- indicator light and UI state
- floor-code contamination
- obstacle/collision ordering
- timestamp offset between monitor and real time

## Checks

- Establish observed physical facts only.
- Note timestamp source and offset.
- Separate visible sequence from inferred root cause.
- Flag inaccessible media as missing assets.
- Do not use image/video alone to prove log-level causes.

## Output

- physical observation timeline
- confidence and limitations
- missing media requests
- branch support or exclusion from visual evidence
