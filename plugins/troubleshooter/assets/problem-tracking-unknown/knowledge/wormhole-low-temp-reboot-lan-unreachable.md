# Wormhole Low-temperature Reboot LAN Unreachable

## Symptoms

- Wormhole board 1.1 or MT7621-based Wormhole board is repeatedly power-cycled under low temperature.
- Test script sends CAN commands successfully, waits for the device to reboot, then tests management address `192.168.40.1`.
- After some reboot cycles, `192.168.40.1` connectivity fails three times and the test flow terminates.
- The case may include OpenWrt/Wormhole firmware images rather than runtime logs.

## Fault Tree

1. Separate CAN fixture success from LAN boot failure.
   - If CAN command send succeeds before the wait period, do not diagnose CAN first.
   - Focus on the post-reboot LAN bring-up window.
2. Confirm expected network target.
   - Verify whether `192.168.40.1` is still the expected LAN bridge or management IP after the tested firmware/config.
   - Check static IP, bridge name, interface names, DSA port names, and management network route.
3. Inspect firmware/config migration risk.
   - For OpenWrt images, inspect metadata before testing.
   - If the image reports `image 1.1, device 1.0` or `Config cannot be migrated from swconfig to DSA`, wipe/rebuild config or explicitly verify the migrated network config.
4. Compare successful and failed cold boots.
   - Capture serial console, kernel `dmesg`, `logread`, netifd, PHY/link, and DSA switch logs from a successful cycle and a failed cycle.
   - Find the first divergence before deciding hardware or software root cause.
5. Only then inspect low-temperature hardware branches.
   - Check PHY/switch cold start, MT7621 reset/clock, power rails, flash/config read, connector/interface board, and cable/link LEDs.
   - Low temperature is a stress condition, not a root cause by itself.

## Evidence Needed

- Temperature chamber setpoint and actual board temperature for successful and failed cycles.
- Reboot cycle number, command sent, wait time, and exact connectivity-check timestamps.
- Serial console logs from successful and failed cycles.
- OpenWrt `dmesg`, `logread`, netifd, `/etc/config/network`, `ip addr`, `bridge link`, `ethtool` or equivalent PHY/link status.
- ARP/ping/packet capture from the test PC side.
- Firmware image metadata and whether config was wiped or migrated.
- Power rail, reset, and clock measurements under low temperature if logs point to hardware boot instability.

## Logs And Files To Inspect

- Search test logs for `192.168.40.1`, `网络检测`, `连续 3 次失败`, `冷重启`, `第 42 轮`, `第 24 轮`, `第 20 轮`.
- Search firmware metadata for `OpenWrt`, `ramips/mt7621`, `wormhole_mt7621`, `image 1.1, device 1.0`, `swconfig`, `DSA`.
- Search device logs for `br-lan`, `netifd`, `lan`, `eth`, `mt7530`, `mt7621`, `link up`, `link down`, `DSA`, `PHY`, `reset`, `watchdog`.

## Likely Causes

- Stale or incompatible LAN/switch configuration after swconfig-to-DSA migration.
- Wrong expected management IP or bridge after firmware upgrade/config wipe.
- Netifd or DSA switch/PHY initialization race during cold boot.
- Hardware cold-start sensitivity in PHY/switch, reset/clock, power rail, or flash/config read path.
- Test fixture timing too short only if device eventually becomes reachable after the 90-second window.

## Exclusion Checks

- Do not classify as CAN bus failure when the visible test shows CAN command success and the failure is in LAN connectivity.
- Do not claim hardware low-temperature defect without failed-cycle boot/link/power evidence.
- Do not claim OpenWrt firmware defect from image metadata alone; treat it as a high-priority branch requiring config and boot-log verification.
- Do not accept a single successful ping before the next reboot as proof that failed cycles have no issue.
- Do not keep using `192.168.40.1` as target without confirming expected IP after firmware/config changes.

## Confirmed Examples

- `problem-tracking-unknown-pt-0090`: Wormhole baseboard `P2672-A2-WORMHOLE1-1` with interface board `P2674-A1-MANTIS-LINK`.
  - Source reports `-15°` repeated power-cycle testing: the 42nd reboot failed, then the 24th reboot after another power-on failed again.
  - Source reports `-5°` cold reboot testing: the 20th reboot also failed.
  - Screenshot at `2026-05-19 20:51:20` starts checking `192.168.40.1`; three failures occur by `20:51:35`, then the script terminates.
  - Screenshot at `2026-05-20 16:48:13` starts checking `192.168.40.1`; three failures occur by `16:48:28`, then the script terminates.
  - Screenshot at `2026-05-21 15:29:03` starts checking `192.168.40.1`; three failures occur by `15:29:18`, then the script terminates.
  - Attached firmware is `u-boot legacy uImage, MIPS OpenWrt Linux-6.12.74`, OpenWrt `25.12.2`, target `ramips/mt7621`, board `wormhole_mt7621`.
  - Firmware metadata warns `image 1.1, device 1.0`, force/wipe required, and config cannot migrate from `swconfig` to `DSA`.

## Unresolved Examples

- `problem-tracking-unknown-pt-0090` lacks failed-cycle serial logs, OpenWrt logs, netifd/DSA/PHY status, device config, PC-side packet capture, chamber telemetry, and hardware measurements. Use it as a diagnostic pattern, not a confirmed root cause.

## Specialist Routing

- `network-infra`: LAN reachability, management IP, bridge/switch/DSA state, ARP, packet capture, test PC path.
- `embedded-software`: OpenWrt boot, firmware compatibility, netifd, DSA migration, kernel/PHY logs.
- `can-bus`: test command fixture only after LAN branch is understood.
- `vision-media`: screenshot transcription and test-sequence confirmation.
