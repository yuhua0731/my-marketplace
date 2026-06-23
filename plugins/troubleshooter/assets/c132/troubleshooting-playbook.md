# C132 Troubleshooting Playbook

Use this as the human-readable entrypoint before specialist routing.

## Global Process

1. Record exact symptom, timestamp, robot ID, station/location, task/container ID, and available filenames.
2. Classify the case by observed symptom, not by incidental WS/robot/location words.
3. Load the matching knowledge file and traverse the highest-value fault branch first.
4. Mark every branch as `confirmed`, `likely`, `excluded`, or `blocked`.
5. Treat unavailable videos, images, logs, and chat records as missing assets, not analyzed evidence.
6. Stop only at confirmed root cause, sufficient operational conclusion, or excluded branch.

## Route Order

- Reboot, shutdown, charging, low voltage: embedded-software first, then can-bus/scheduler/network.
- Shutdown blocked after robot lock/manual lock: scheduler-traffic first, then embedded state-machine only if logs show command/state failure.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Mechanical scrape, bracket contact, drag-chain sag, rail interference: vision-media first, then robot-motion/hardware evidence; embedded only if motion logs implicate control behavior.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## C132 Fork Cover Deformation Rail Wear

Knowledge file: `docs/c132/knowledge/fork-cover-deformation-rail-wear.md`

### First Checks

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

### Evidence

- Robot ID, side, fork location, load, endurance hours, and exact rail station.
- Close-up images of the worn rail before cleanup and after retest.
- Images of nearby cover/guard/bracket geometry and screw seating.
- Dynamic clearance check through the full fork stroke under representative
  load.
- Retest duration and whether new powder, discoloration, scratch depth, or noise
  appeared.
- If field inspection says no abnormal interference, record whether this was a
  static visual check or a dynamic full-stroke/load check.

### Exclusions

- Exclude CAN/drive root cause unless same-window logs show motor, CAN, or drive
  alarms related to fork movement.
- Exclude normal break-in wear when the wear is concentrated and paired with
  powder/discoloration.
- Exclude rail material as the first branch when a visible cover deformation
  aligns with the contact path.

### Examples

- `c132-pt-0174`: C132-2 reworked `J38A07SP` ran `35kg` pull/return for
  `14h`. A-side inner fork rail top had concentrated abnormal wear,
  discoloration, and powder. Source analysis found the fork outer cover bottom
  slightly bulged downward and rubbing the rail during fork extension/retraction.
  Resolution was repairing or replacing the deformed cover. After rail surface
  repair, follow-up on `2026-04-13` after `90h` and `2026-04-17` after `198h`
  reported no new wear.

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
