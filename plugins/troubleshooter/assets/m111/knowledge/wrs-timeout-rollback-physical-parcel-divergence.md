# M111 WRS Timeout Rollback Versus Physical Parcel Delivery Divergence

source_set: `m111-pt-0104`
case_count: 1 M111 WRS/RCS timeout rollback and physical parcel delivery divergence case
status: runtime routing rules for WRS return-box counts becoming inconsistent after feeder/robot load-failure recovery while a second physical parcel continues to a normal target slot

## Symptoms

- M111 WRS / return-box flow sends two parcels to the feeder in quick succession.
- The first parcel is intentionally made to fail robot loading; the second parcel remains on the feeder belt.
- After waiting about 4 minutes, the WRS UI rolls back remaining delivery count from 42 to 44.
- After the operator recovers the robot load failure, the first parcel is force-discharged to an exception slot, but the second parcel is normally seeded/delivered to the target slot.
- WRS remaining delivery count and recorded/scanned count do not change even though the physical parcel reached the normal slot.

## Fault Tree

1. Build the WRS/RCS parcel ownership timeline.
   - `m111-pt-0104`: at `13:36:50`, two consecutive parcels were delivered to the feeder.
   - The first parcel had a simulated robot loading failure.
   - The second parcel stopped on the feeder belt while the first parcel remained unresolved.
2. Check WRS timeout rollback semantics.
   - Source analysis says WRS rolls back return-box pending/sorting quantity when a parcel times out.
   - During the unresolved robot load failure, the second parcel timed out at WRS layer and the remaining delivery count recovered from 42 to 44.
3. Check whether RCS still physically routes the timed-out parcel.
   - After the load-failure recovery, source says the first parcel was forced to an exception slot.
   - The second parcel then physically went to the normal target slot.
   - This creates a logical/physical split: WRS already rolled back the count, but RCS still treats the parcel as deliverable.
4. Validate timeout propagation and throw-time enforcement.
   - Source resolution adds timeout-duration injection when adding the barcode, tells RCS the parcel timeout duration, and makes RCS check timeout before throwing; timed-out parcels should go to exception.

## Diagnostic Rules

- For WRS count mismatch after feeder/robot exception recovery, reconstruct both logical count changes and physical parcel movement; do not inspect UI count alone.
- Search WRS/service logs for barcode add time, parcel timeout, rollback of pending/sorting quantity, remaining delivery count, recorded/scanned count, and in-transit count.
- Search RCS/conveyor logs for the same parcel ID/barcode/container: feeder receive, robot load failure, recovery, force discharge, throw target, and timeout status at throw time.
- If WRS has timed out a parcel but RCS still throws it to a normal slot, add or verify timeout metadata propagation from WRS to RCS and enforce timeout at throw decision.
- Route separately from generic conveyor recovery race when the symptom includes `剩余投递数量`, `已录入数量`, `退货箱`, WRS timeout rollback, or count/physical divergence.

## Evidence Needed

- WRS logs around `13:36:50` through the 4-minute timeout and recovery.
- RCS/conveyor logs for the first and second parcel IDs/barcodes, including load-failure recovery, force-discharge, and final slot.
- Exact before/after UI values for remaining delivery count, in-transit count, recorded count, and abnormal count.
- Barcode add request payload showing timeout duration after the fix.
- RCS throw-decision log proving timed-out parcels are redirected to exception after the fix.
- Full video review or frame sequence of the two parcels if physical movement is disputed.

## Logs And Files To Inspect

- Case body: `cases/accepted/m111/0104-Nrjqw7c5eipyc1kfiohcniXnnQg-2026-04-15-M111-WRS系统供包机出现异常恢复后-剩余投递量和实际情况不一致.md`.
- Local image: `assets/m111-pt-0104/001-image-87c0f0027298.jpg`.
  - 1886 x 738 JPEG.
  - Shows return-box detail list. For `sku002` / `upc002`: plan `50`, remaining delivery count `44`, in-transit count `0`, recorded count `6`, abnormal count `0`, status `已扫描`.
- Local video: `assets/m111-pt-0104/002-source-KdnCb4CgMo9ntDxam8dcAN4WnYd.mp4`.
  - QuickTime metadata: 960 x 540, duration about 94.667 s, size 20389301 bytes, H.264 video with AAC audio.
  - QuickLook representative frame `/tmp/m111-pt-0104-frames/002-source-KdnCb4CgMo9ntDxam8dcAN4WnYd.mp4.png` shows feeder/workstation equipment beside a WRS return-box detail UI.
- Search terms: `m111-pt-0104`, `M111`, `WRS`, `退货箱`, `剩余投递数量`, `已录入数量`, `在途数量`, `回滚`, `超时`, `超时时长`, `添加条码`, `装货失败`, `接货失败`, `强排`, `异常口`, `正常格口`, `第二个包裹`, `RCS`, `timeout`.

## Likely Causes

- WRS timeout rollback happens while the physical parcel is still held on the feeder and can later be routed by RCS.
- RCS lacks parcel timeout duration/state at throw decision time, so it sends a timed-out parcel to the normal slot.
- Count ownership between WRS and RCS is not synchronized during unresolved robot load-failure recovery.

## Exclusion Checks

- Exclude pure UI display defect only after WRS/RCS logs show counts and parcel states are correct internally.
- Exclude physical sensor package-tracing fault unless logs show the second parcel's physical presence/state is wrong before WRS timeout.
- Exclude generic conveyor recovery ordering race if the only mismatch is WRS timeout rollback versus later physical delivery; this branch needs count rollback and timeout evidence.
- Exclude operator recovery error if the system contract permits recovery while a timed-out parcel can still be delivered normally.

## Confirmed Examples

- `m111-pt-0104`: two parcels were sent to the feeder at `13:36:50`; the first parcel simulated load failure and the second stopped on the belt. After about 4 minutes, WRS restored remaining delivery count from `42` to `44`. After robot load-failure recovery, the first parcel went to exception by force discharge, while the second was delivered to a normal target slot. The source fix injects timeout duration when adding the barcode and makes RCS check timeout before throwing, sending timed-out parcels to exception.

## Unresolved Examples

- `m111-pt-0104`: local assets do not include WRS/RCS logs, exact parcel/barcode IDs for both physical parcels, add-barcode payload diff, or post-fix throw-decision logs.

## Specialist Routing

- Start with `scheduler-traffic` for WRS/RCS task lifecycle, timeout, rollback, recovery, and parcel ownership.
- Add `vision-media` for UI screenshot and physical parcel video/frame inspection.
- Add `embedded-software` only if feeder controller or conveyor state-machine logs show command/ack/state defects after the service timeout branch is checked.
