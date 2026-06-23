# Baffle Added Drag Chain Bracket Interference

## Symptoms

- M111 or Mini drag-chain robot receives an added baffle, guard, cover, or retrofit mechanism.
- After the modification, the drag-chain mounting hole or bracket fastener access is blocked.
- The drag chain cannot be installed or fixed normally.
- The original bracket geometry does not match the added baffle mechanism.

## Fault Tree

1. Start with mechanical envelope and mounting access.
   - In `m111-pt-0058`, the source states the drag-chain fixed hole was blocked by the added baffle component.
   - The failure is a physical installability problem, not an initial software, CAN, or scheduling symptom.
2. Confirm whether the old bracket design is incompatible with the new mechanism.
   - Source analysis states: `原拖链支架与挡板机构不匹配，无法固定安装`.
   - Local image `001-image-125a4ca25d1d.png` shows a new metal drag-chain bracket and the original black bracket side by side with different geometry and hole layout.
3. Inspect cable and drag-chain routing after the fix.
   - Local image `002-image-5310d42b0f2d.jpg` shows the new bracket installed near the baffle-side structure, drag chain, and cables.
   - Representative video frame shows close-up inspection around the cable/drag-chain mounting area.
4. Confirm resolution by replacement.
   - Source action says `重新设计并下单拖链支架`.
   - Source follow-up says `更换新拖链支架后问题已解决`.
5. Do a full motion-cycle clearance check before closing a repeated field issue.
   - A static image can prove installability but not full travel clearance, cable bend radius, or scrape-free operation.

## Evidence Needed

- Before image/video showing the blocked mounting hole and the interfering baffle component.
- After image/video showing the new bracket installed and the drag chain fixed.
- CAD or drawing overlay for old bracket, new bracket, baffle component, mounting hole, cable route, and fastener access.
- Bracket part number, revision, and BOM/change notice.
- Full robot/baffle travel video or clearance measurement after replacement.
- Cable bend-radius and pinch/scrape inspection after repeated movement.

## Logs And Files To Inspect

- Case body: `cases/accepted/m111/0058-KIwZwvGuciEp3NkJ5XOcPgFonIh-2026-03-30-M111机器人加装挡板后干涉问题.md`.
- Local image: `assets/m111-pt-0058/001-image-125a4ca25d1d.png`.
- Local image: `assets/m111-pt-0058/002-image-5310d42b0f2d.jpg`.
- Local video: `assets/m111-pt-0058/003-source-J2Leb1NC4ovqXZx2u5FcQXQln5f.mp4`.
- Search terms: `拖链固定孔位`, `挡板部件遮挡`, `无法正常安装固定`, `原拖链支架`, `新拖链支架`, `支架不匹配`, `干涉`, `加装挡板`.

## Likely Causes

- Retrofit baffle geometry overlaps the original drag-chain bracket's mounting hole or fastener access.
- Original bracket was designed for the non-baffle configuration and lacks offset/clearance for the baffle mechanism.
- Cable/drag-chain route needs a revised support bracket after the baffle changes the local mechanical envelope.

## Exclusion Checks

- Do not diagnose CAN, firmware, scheduler, or workstation logic from a blocked mounting hole.
- Do not classify this as baffle actuator behavior unless logs or motion evidence show actuator state failure after mechanical installation succeeds.
- Do not close as solved from a redesigned bracket alone; verify installation, cable routing, bend radius, and full travel clearance.
- Do not generalize the new bracket to all M111 variants without checking baffle revision, robot side, hole pattern, and drag-chain route.

## Confirmed Examples

- `m111-pt-0058`: after adding a baffle to an M111 drag-chain robot, the baffle blocked the drag-chain fixed hole. Source analysis says the original bracket did not match the baffle mechanism. A redesigned drag-chain bracket was ordered; after replacing the new bracket, the problem was resolved. Local images show new/old bracket geometry comparison and the post-fix installation area.

## Unresolved Examples

- `m111-pt-0058`: exact missing initial annotated interference image, CAD/BOM revision, part number, and full motion-cycle clearance proof are not local.

## Specialist Routing

- Start with `vision-media` to inspect the physical interference, bracket geometry, cable route, and post-fix installation.
- Add `robot-motion` for full travel clearance, scrape/pinch risk, and moving-envelope checks.
- Add `embedded-software` only if mechanical clearance is good but actuator/sensor state still fails during movement.

