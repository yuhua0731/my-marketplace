# Drag Chain Sag Scraping Stainless Bracket

## Symptoms

- OmniSort / M145 drag chain is reported as too long.
- The robot reaches the D door area and the drag chain folds downward.
- The lowered/folded drag chain scrapes a stainless bracket or support.
- The available video shows the drag-chain path in the rail/frame area, but the exact contact instant is not clearly captured in extracted frames.

## Fault Tree

1. Confirm the physical interference point first.
   - Inspect slow-motion video frames and onsite witness marks.
   - Mark the drag chain and stainless bracket contact side, height, and longitudinal position.
   - Measure static and dynamic clearance at the D door position.
2. Check drag-chain geometry.
   - Verify chain free length, mounting positions, bend radius, cable fill, and support span.
   - Excess length or unsupported span can let the chain fold downward into the bracket.
   - Wrong fixed/end mounting can shift the fold point into the local frame envelope.
3. Check bracket and frame envelope.
   - Compare the D door stainless bracket with neighboring sections.
   - Look for protruding edges, low bracket height, local deformation, or installation tolerance.
   - Confirm whether the bracket is inside the real dynamic motion envelope, not only the CAD static envelope.
4. Check motion and installation contributors.
   - Speed, acceleration, vibration, rail tilt, or robot installation skew can increase chain sag near one location.
   - Repeat passes at normal speed and reduced speed to separate geometry from dynamic excitation.
5. Validate correction.
   - Shorten/re-route/support the drag chain or modify the bracket only after contact point is confirmed.
   - Re-run full-travel passes through D door and inspect for noise, scrape marks, and clearance.

## Evidence Needed

- Original video or high-frame-rate clip showing the contact instant.
- Close-up photos of drag-chain and stainless-bracket witness marks.
- Measured clearance at D door through full travel.
- Drag-chain length, bend radius, cable fill, and mounting position.
- Bracket drawing/BOM/version and installed height/offset.
- Before/after full-travel validation video after any mechanical change.

## Logs And Files To Inspect

- Motion logs are secondary: use them only to correlate robot position, speed, and repeatability around D door.
- Search source text and reports for `D门`, `拖链`, `折叠下坠`, `不锈钢支架`, `剐蹭`, `drag chain`, `clearance`, `bend radius`, and `motion envelope`.
- Inspect installation photos, CAD drawings, bracket BOM, and drag-chain routing drawings before prescribing part changes.

## Likely Causes

- Excess drag-chain length or unsupported span causes downward fold/sag.
- Drag-chain fixed/end mounting makes the fold point occur near the D door bracket.
- Stainless support or guard intrudes into the real chain dynamic envelope.
- Installation tolerance, local rail/bracket offset, or vibration makes the issue location-specific.

## Exclusion Checks

- Do not call embedded/CAN/scheduler root cause without logs showing abnormal commanded motion or state transitions.
- Do not prescribe shortening the chain until bend radius, cable fill, and full-travel margin are checked.
- Do not blame the stainless bracket alone if the same bracket geometry works at other sections but this chain is longer or unsupported.
- Do not treat a single static photo as proof of clearance; the failure is reported during motion near D door.
- If the video does not show contact clearly, keep the branch as likely mechanical interference and record missing contact/witness-mark evidence.

## Confirmed Examples

- `m145-pt-0159`: source says M145 drag chain is long; near D door, the drag chain folds downward and scrapes a stainless bracket. Local video is available and shows the drag-chain path near the rail/frame/bracket area.

## Unresolved Examples

- `m145-pt-0159`: extracted frames do not clearly show the exact scrape instant, measured clearance, wear marks, or final corrective action.

## Specialist Routing

- `vision-media`: inspect video frames, contact point, witness marks, and clearance photos.
- `robot-motion`: correlate position/speed/repeatability only if motion dynamics may worsen contact.
- `embedded-software`: only if logs suggest abnormal motion commands or state-machine behavior contributed.
