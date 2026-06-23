# Concave Parcel Multi-Parcel Detection

## Symptoms

- A concave or hollow parcel enters the Mini / OmniSort lift module and triggers a conveyor multi-parcel alarm.
- Upstream light curtain or upper-car segment appears to trigger only once.
- Videos show an irregular carton geometry rather than two clearly separate parcels.

## Fault Tree

- Confirmed branch: product geometry can mimic multi-parcel evidence.
  - In `m147-pt-0147`, the source says a concave parcel entered station 2 lift at `15:45:25` and reported conveyor multi-parcel.
  - The source also says the upper-car light curtain triggered only once.
  - Downloaded video thumbnail shows a long carton with a concave/damaged edge profile, not an obvious second parcel.
- Likely branch: detection window or downstream sensor pair interprets the concavity as two objects.
  - Check whether multi-parcel logic uses multiple light curtains, duration gaps, height profile, or lift entry timing.
- Blocked branch: full video timeline and sensor logs.
  - Videos are downloaded, but no matching IO/sensor timestamp log is present in the case.

## Evidence Needed

- Full IO timeline for upper-car light curtain, lift-entry light curtain, multi-parcel sensor, and conveyor speed.
- Parcel size, concavity direction, edge deformation, and orientation during entry.
- Alarm timestamp and whether the same parcel repeats the alarm under rotated orientation.
- Video frame sequence synchronized with sensor timestamps.

## Logs And Files To Inspect

- Local case: `cases/needs-assets/m147/0147-BwghwpH55iUFb3kWwuUcQWAcn9f-2026-06-16-M147-迷你播Pro-二号供包机投递凹型包裹多包问题.md`.
- Local assets: `assets/m147-pt-0147/retry-source-E2gbbGur4onNkzxBQbucTTThnIe.mov`, `assets/m147-pt-0147/retry-source-XEgNbFZ8eoXWmgxeMzDcQR0HnLf.MOV`.
- Search terms in logs when available: `multi parcel`, `多包`, `light curtain`, `光幕`, `lift`, `提升模组`, `station 2`.

## Likely Causes

- Irregular parcel profile creates separated sensor intervals within one physical parcel.
- Multi-parcel threshold is too sensitive for concave cartons or damaged packaging.
- Conveyor/lift timing treats a long parcel tail and leading edge as separate objects.

## Exclusion Checks

- Exclude true two-parcel condition only if upstream and lift-entry sensor timelines both show one continuous object and video confirms one parcel.
- Exclude pure software false alarm only after checking parcel orientation and sensor timing.
- Exclude upstream light curtain as sole evidence; the multi-parcel decision may use a downstream sensor or duration heuristic.

## Confirmed Examples

- None. `m147-pt-0147` remains `needs-assets` because IO logs were not present.

## Unresolved Examples

- `m147-pt-0147`: station 2 concave parcel caused multi-parcel alarm; source claims upper-car light curtain triggered once, but root cause needs IO timeline confirmation.

## Specialist Routing

- Start with `mantis-handling` / handling specialist for parcel geometry, conveyor timing, and lift-entry state.
- Add `vision-media` for full video review.
- Add `scheduler-traffic` only if sensor evidence shows a valid single parcel but service state still raises multi-parcel.
