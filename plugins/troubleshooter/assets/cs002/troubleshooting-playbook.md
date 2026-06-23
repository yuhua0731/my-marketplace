# Cs002 Troubleshooting Playbook

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

## CS002 Throwing Mechanism Fastener Fatigue Fracture

Knowledge file: `docs/cs002/knowledge/throwing-mechanism-fastener-fatigue-fracture.md`

### First Checks

- Too few fixing points or poor load path:
  - Small corner fastener groups and long slots concentrate dynamic load at the
    folded sheet-metal edge.
- Fastener loosening under vibration:
  - Loose screws increase mechanism vibration amplitude, causing repeated
    bending at the fixed hole or fold.
- Lift backlash and height transition excitation:
  - Large reducer backlash or height difference between the lift plate and
    horizontal rail creates impact vibration as the robot passes the transition.
- Sheet-metal bend fatigue:
  - Folded regions can contain microcracks or lower fatigue margin; repeated
    bending eventually fractures the sheet metal.

### Evidence

- Robot IDs, location, runtime window, load state, and whether the fracture is
  on one or multiple robots.
- Close-up photos of the fracture surface, fixed holes, folded edge, screws,
  nuts, washers, and witness paint.
- Dynamic video or slow-motion capture when the robot crosses the lift/track
  transition.
- Measurement of lift reducer backlash and height difference between lift plate
  and horizontal rail.
- Fastener torque/process record, thread-locking method, washer/locking hardware
  spec, and post-run torque check.
- Repair action and retest result under the same transition and load.

### Exclusions

- Exclude CAN/software as primary when no logs show communication or drive
  errors before the mechanical crack.
- Exclude a pure material defect until fastener retention, fixing-point count,
  and vibration source are checked.
- Exclude simple screw replacement as a complete fix unless post-run torque and
  no-new-crack retest are recorded.

### Examples

- `cs002-pt-0062`: CS002 `I39B67S` / `I39B45S` baffle robots had throwing
  mechanism screw-fixed connection fractured during operation. Source analysis
  says the throwing mechanism and base frame had few fixing points; the CS002
  lift reducer had large backlash; the lift plate and horizontal rail had a
  large height difference; the robot generated severe vibration at this
  position. Loose screws increased mechanism vibration amplitude, and repeated
  bending caused sheet-metal fatigue fracture at the folded weak point. Local
  images show the cracked fastener/fold area and loose/clearance-prone fastener
  region; video thumbnails show lift/track transition and fastener group
  context.

- `cs002-pt-0062`: full frame-by-frame video inspection, vibration measurement,
  fastener torque/process record, fracture analysis, repair action, and retest
  evidence were not available locally.
