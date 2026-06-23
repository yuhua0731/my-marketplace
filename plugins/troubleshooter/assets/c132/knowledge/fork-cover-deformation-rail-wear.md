# C132 Fork Cover Deformation Rail Wear

## Scope

Use this when C132 / OmniFlow Mantis fork rails show localized top wear, powder,
discoloration, or scratches after endurance pull/return operation, especially
when nearby fork covers or guard plates may be deformed.

This is primarily a mechanical interference and handling-domain pattern. Do not
start from CAN, firmware, or scheduler unless same-window logs show drive,
communication, or task-flow faults.

## Symptoms

- A-side fork inner rail top has concentrated abnormal wear, dark discoloration,
  bright rubbed areas, or powder/debris.
- Wear appears after `35kg` load pull/return endurance operation.
- A nearby fork outer cover or guard plate is locally bent, bulged, or shifted
  toward the rail.
- After cover repair/replacement and rail surface repair, endurance retest shows
  no new wear.
- In unresolved recurrence cases, the rail may show localized scratches and
  debris after longer endurance exposure even when field inspection reports no
  obvious noise or static interference.

## Fault Tree

- Cover deformation / rail interference:
  - Confirmed when the cover bottom is locally bulged downward and aligns with
    the rail-top wear path.
  - Dynamic fork extension/retraction can create contact even when a static
    photo looks close but not touching.
- Rail material or surface finish:
  - Consider when wear is distributed along the rail or repeats without a nearby
    interference source after dynamic clearance checks. Requires material,
    hardness, coating, or batch evidence.
- Assembly alignment:
  - Consider screw seating, cover mounting height, rail height, fork parallelism,
    bracket deformation, and post-rework assembly tolerances.
- Load/endurance exposure:
  - Heavy-load endurance can expose a small interference; it is not sufficient
    as root cause without a contact source.

## Evidence Needed

- Robot ID, side, fork location, load, endurance hours, and exact rail station.
- Close-up images of the worn rail before cleanup and after retest.
- Images of nearby cover/guard/bracket geometry and screw seating.
- Dynamic clearance check through the full fork stroke under representative
  load.
- Retest duration and whether new powder, discoloration, scratch depth, or noise
  appeared.
- If field inspection says no abnormal interference, record whether this was a
  static visual check or a dynamic full-stroke/load check.

## Logs And Files To Inspect

- Case source text and follow-up notes.
- Local images under `assets/<case_id>/`, especially rail-top close-ups and
  cover deformation photos.
- If available: motor current/torque trend during fork movement, motion alarms,
  CAN/drive faults, and maintenance repair records.

## Likely Causes

- Fork outer cover bottom locally deformed downward, rubbing the inner rail top
  during fork movement.
- Post-rework cover or bracket mounting tolerance leaves insufficient dynamic
  clearance.
- Rail surface wear is a secondary result of mechanical contact, not the primary
  component failure.

## Diagnostic Rules

- A localized wear stripe plus powder/debris should trigger immediate inspection
  of adjacent covers, guard plates, screw heads, and brackets for interference.
- Repair the contact source before judging rail durability. Polishing or
  replacing the rail alone can hide the symptom temporarily.
- Validate with endurance retest under the same load and inspect the same rail
  station; no new wear after a meaningful retest supports the interference
  diagnosis.
- If dynamic clearance is not measured, keep the evidence gap explicit even when
  photos and retest strongly support the diagnosis.
- Absence of noise is not enough to exclude light mechanical rubbing. Use
  same-station photos, debris/scratch progression, and dynamic clearance checks.

## Exclusion Checks

- Exclude CAN/drive root cause unless same-window logs show motor, CAN, or drive
  alarms related to fork movement.
- Exclude normal break-in wear when the wear is concentrated and paired with
  powder/discoloration.
- Exclude rail material as the first branch when a visible cover deformation
  aligns with the contact path.

## Confirmed Examples

- `c132-pt-0174`: C132-2 reworked `J38A07SP` ran `35kg` pull/return for
  `14h`. A-side inner fork rail top had concentrated abnormal wear,
  discoloration, and powder. Source analysis found the fork outer cover bottom
  slightly bulged downward and rubbing the rail during fork extension/retraction.
  Resolution was repairing or replacing the deformed cover. After rail surface
  repair, follow-up on `2026-04-13` after `90h` and `2026-04-17` after `198h`
  reported no new wear.

## Unresolved Examples

- `c132-pt-0174`: no before/after clearance measurements, no dynamic contact
  video, no rail/cover material inspection, and no torque/current trend were
  available locally.
- `c132-pt-0005`: C132-2 reworked `J38A07SP` and `J38A11SP` ran `35kg`
  pull/return for `87h`; A-side inner fork silver/black rail top showed
  localized scratches and debris. Source says field inspection found no noise
  or obvious abnormal interference and continued observation was planned. Treat
  it as a recurrence of the rail-wear symptom, not as confirmed cover
  deformation, until dynamic clearance, cover/guard/bracket geometry, and
  material checks are completed.

## Specialist Routing

- `mantis-handling`: fork extension/retraction, cover/bracket geometry,
  load/endurance retest, rail contact path.
- `vision-media`: compare rail wear photos, cover deformation photos, and
  before/after retest stations.
- `embedded-software` or `can-bus`: only if movement logs show drive/CAN alarms
  in the same time window.
