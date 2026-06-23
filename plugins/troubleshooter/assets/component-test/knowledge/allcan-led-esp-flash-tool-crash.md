# ALLCAN-LED ESP Flash Tool Crash

source_set: `component-test-pt-0011`
case_count: 1 focused ALLCAN-LED ESP8266/WLED flash-tool crash case
status: runtime routing rules for ESP serial flashing tool exits/crashes

## Symptoms

- ALLCAN-LED ESP firmware flash tool exits or crashes directly.
- The target/device type may be `Wled-esp8266` or `ESP8266`.
- The user may report that the GUI cannot complete flashing, while command-line `esptool.exe` evidence may still show successful write/verify.

## Fault Tree

1. First split: GUI/tool crash versus actual ESP flashing failure.
   - `component-test-pt-0011`: source says the flash tool directly exits and cannot flash ALLCAN-LED `esp` firmware.
   - Video frames show `嵌入式烧录助手` with `Wled-esp8266`, `COM13`, `921600`, address `0x00000000`, device name `ESP8266`, and selected `wled.bin`.
   - Later representative frame no longer shows the GUI and shows the app folder containing `flash_tool.exe`.
2. If direct `esptool.exe` succeeds, prioritize wrapper/runtime.
   - Video background PowerShell shows `esptool.exe --chip esp8266 --port COM13 --baud 460800 write_flash -z 0x0 .\wled.bin`.
   - Visible output includes `Connected to ESP8266 on COM13`, `Hash of data verified`, and `Hard resetting via RTS pin...`.
   - This points away from target hardware as the first branch and toward GUI subprocess handling, argument construction, packaged runtime, or exception handling.
3. Check parameter mismatch.
   - GUI shows baud `921600`, while the visible CLI command uses `--baud 460800`.
   - Confirm which baud the GUI actually passes to `esptool.exe`.
4. Keep J-Link/STM failures separate.
   - ESP8266/WLED flashing uses serial bootloader + `esptool.exe`.
   - J-Link/STM ALLCAN-LED flashing uses SWD/J-Link and has different DLL/verify failure branches.

## Evidence Needed

- Flash-tool stdout/stderr, crash traceback, Windows Event Viewer entry, or dump file.
- Exact GUI action sequence and click-to-crash timestamp.
- Flash tool version, package contents, Python/PyInstaller or GUI framework runtime details.
- Actual command line launched by the GUI, including port, baud, address, and firmware path.
- Direct `esptool.exe` run result from the same machine/board/COM port.
- Target board photo, boot-mode wiring, USB-UART adapter, power source, and post-flash firmware behavior.

## Logs And Files To Inspect

- `cases/needs-assets/component-test/0011-VCMZwsB9Yiji7lkLI8ScMZDxnkh-2026-04-01-ALLCAN-LED烧录工具无法使用.md`
- `assets/component-test-pt-0011/001-source-GUMTbmwHloUgK4xuvbccbUKBnHg.mp4`
  - H.264, `35.967s`, `1916x1036`, `14068496` bytes.
  - Representative frames inspected at 0s, 10s, 25s, and 33s.
- Search terms: `ALLCAN-LED烧录工具无法使用`, `esp固件`, `ESP8266`, `Wled-esp8266`, `esptool.exe`, `write_flash`, `wled.bin`, `COM13`, `460800`, `921600`, `Hash of data verified`, `Hard resetting via RTS pin`, `flash_tool.exe`, `直接闪退`.

## Likely Causes

- GUI wrapper crashes after or while launching `esptool.exe`.
- Packaged runtime cannot handle subprocess output, path, permissions, working directory, or missing bundled dependency.
- GUI displays one baud rate but launches another command, creating inconsistent behavior.
- Antivirus, Windows permissions, or packaged executable quarantine can close the helper without a useful UI error.

## Exclusion Checks

- Do not classify as board/ESP failure if direct `esptool.exe` writes and verifies data on the same port.
- Do not classify as CAN failure; ESP flashing is serial bootloader work.
- Do not reuse J-Link DLL/verify rules unless the failing path is STM/J-Link/SWD.
- Do not accept GUI disappearance alone as root cause; require crash logs for final fix.
- Do not declare success without post-flash firmware behavior, even if esptool reports verified data.

## Confirmed Examples

- `component-test-pt-0011`: source reports ALLCAN-LED ESP firmware flash tool exits directly. Video frames show the GUI configured for `Wled-esp8266`, `COM13`, `921600`, address `0x00000000`, `ESP8266`, and `wled.bin`; background PowerShell shows direct `esptool.exe` flashing on `COM13` with `--baud 460800`, `Hash of data verified`, and `Hard resetting via RTS pin...`.

## Unresolved Examples

- `component-test-pt-0011`: missing crash log, exact GUI-launched command, post-flash target verification, board/adapter photo, and tool version/source.

## Specialist Routing

- Start with `embedded-software` for flash-tool packaging, subprocess invocation, serial bootloader flow, and crash logging.
- Add `vision-media` for UI/video evidence: selected device, COM port, baud, file path, and observed disappearance.
- Add hardware/electrical review only if direct esptool fails or the ESP cannot boot after verified flashing.
