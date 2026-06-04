# C134 Embedded Diagnostic Playbook

Built from accepted high-priority visible-text cases.

## Ant/power

Cases: 95

Signals:

- `c134-0001` symptom: 1月29日，上午10点59分左右，A-111蚂蚁机器人更换升压模块之后，自检报错。
  analysis: Downloaded local assets under `assets/c134-0001/`.
- `c134-0005` symptom: 1月29日，下午16点48分左右发现，A-101蚂蚁机器人在运动过程中重启。
  analysis: Downloaded local assets under `assets/c134-0005/`.
- `c134-0009` symptom: 1月30日，上午11点30分左右发现，A-107蚂蚁机器人原地重启。
  analysis: Downloaded local assets under `assets/c134-0009/`.
- `c134-0012` symptom: 1月31日，上午9点24分左右发现，A-107蚂蚁机器人在举升的过程中原地重启。
  analysis: System log confirms a real reboot/reset close to the reported lift-time restart.
- `c134-0019` symptom: 如题  20.10分左右  A110蚂蚁在运行过程中关机   将它推到充电桩位置重启初始化后发现电量剩余44%
  analysis: 通过日志可知，A110号蚂蚁从19点开始到20点期间，电量从24%持续降低到0%，导致升压模块检测到电池低电量自动关机。升压模块低电量自动关机的条件为持续3min电量低于0%（4.0V），期间只要电量高于0%一次，时间会重新计数。
- `c134-0024` symptom: 如题  19.18分，109蚂蚁报"under voltage"，如下图：
  analysis: Local assets downloaded under `assets/c134-0024/`.
- `c134-0032` symptom: 1月31日，下午14点47分左右发现，A-109蚂蚁机器人在休息位前的通道重启。
  analysis: Downloaded local assets under `assets/c134-0032/`.
- `c134-0035` symptom: 14点55分左右：110蚂蚁在休息位“重启”，当观察到他时，他的指示灯是蓝色长亮。
  analysis: Downloaded local assets under `assets/c134-0035/`.
- `c134-0036` symptom: 10点25分左右：111蚂蚁在运行过程中 “重启”，当观察到他时，他的指示灯是蓝色长亮。
  analysis: Downloaded local assets under `assets/c134-0036/`.
- `c134-0040` symptom: 19.45分  107报错  观察到小车状态灯熄灭   在FLO界面看到小车电量灯见底
  analysis: 11/20/2025, 19:00:16 电量上报20

Training focus:

- Correlate battery percentage, boost-module shutdown, reboot timing, charging-point state, and NXP/system logs.
- Separate real power loss from UI/status-light restart symptoms.

## Ant/motion-localization

Cases: 31

Signals:

- `c134-0003` symptom: 2025-10-21-10:29:27 A-107蚂蚁在返回库区时，报[ERROR]1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost duuring linear motion，直接装到货架立柱上
  analysis: Downloaded local assets under `assets/c134-0003/`.
- `c134-0011` symptom: 19点33分，102蚂蚁直线运动时丢码，车不在码线上
  analysis: 【C134】A102 DM LOST 【2025-11-03】
- `c134-0015` symptom: 11月8日，编号为102的蚂蚁机器人在前往取箱的过程中跑偏在路上，界面上报错误如下:
  analysis: Downloaded local assets under `assets/c134-0015/`.
- `c134-0018` symptom: 如题  20.17分左右   102蚂蚁在离开WS001的离开点后  在104休息区前方道理地码丢失  DM code lost during linear motion
  analysis: can2 (1).pcap
- `c134-0034` symptom: 9点36分：102蚂蚁在A3-S1货架下行走至【125949GG105082】处地码停止不动。观察发现102蚂蚁存在跑偏问题，偏向运动方向的左侧。
  analysis: image.png
- `c134-0037` symptom: 12点55分左右：109蚂蚁跑偏，105出充电位与109相撞。
  analysis: 地码有灰尘
- `c134-0038` symptom: 13点08分左右：111蚂蚁跑偏
  analysis: 地码污渍
- `c134-0041` symptom: 如题A111蚂蚁从WS001-1位置退出  料箱下降动作完成   开始转向前报cammand
  analysis: 涉及命令A-111-S357381-2025-11-28T12:47:20.525Z-0
- `c134-0043` symptom: 12月3日16点25分：105蚂蚁在WS001-3退出工位时跑偏，视频如下：
  analysis: 12/3/2025, 16:25:18 A-105蚂蚁开始退出WS001-3
- `c134-0093` symptom: 12月20日，上午9点06分左右，A-103蚂蚁机器人在休息位上报转角过大且原地重启
  analysis: image.png

Training focus:

- Correlate DM code loss, angle deviation, floor-code contamination, speed/acceleration changes, and collision aftermath.
- Treat path blockage and localization loss as separate hypotheses until logs/video confirm one.

## Ant/network

Cases: 14

Signals:

- `c134-0002` symptom: 1月29日，下午13点25分左右发现，A-110蚂蚁机器人断连。
  analysis: 根据网卡的dumpcap日志， 13点21分19秒的时候最后一次和108通讯， 推测为网卡异常
- `c134-0027` symptom: 11月17日，上午8点44分，现场售后人员发现FLO上只有13台机器人，少了一台蚂蚁机器人，故去查看情况，检查后发现A-112蚂蚁机器人断连,此时FLO上并没有报错信息。当时A-112蚂蚁机器人情况如下图所示:
  analysis: A-112-S238671-2025-11-16T09:21:39.384Z-0这是重启前最后一条执行的命令，执行结果为成功，可以确定蚂蚁重启前在“IDLE”状态。
- `c134-0139` symptom: 1月13日，上午8点49分左右，在A-111蚂蚁机器人休息位前发生堵车。在flo界面上发现A-111蚂蚁机器人断连。
  analysis: Downloaded local assets under `assets/c134-0139/`.
- `c134-0157` symptom: 1月21日，下午13点35分左右，A-108蚂蚁机器人断连。
  analysis: A-108 网络信息
- `c134-0167` symptom: 1月24日，上午8点27分左右，A-107蚂蚁机器人断连。通过CMD去ping机器人的IP地址，发现无法ping通。
  analysis: Downloaded local assets under `assets/c134-0167/`.
- `c134-0227` symptom: 2月3日，中午13点37分左右，FLO界面上所有机器人全部短暂断连，13点39分后恢复正常。
  analysis: 服务器网络监控脚本显示该时间点到 AP 有轻微丢包现象
- `c134-0228` symptom: 2月3日，下午16点22分左右，A-104蚂蚁机器人断连，两个IP均能ping通。
  analysis: image.png
- `c134-0252` symptom: 2月22日，下午13:33分发现，A-107蚂蚁机器人在休息位断连。两个IP地址均无法ping通。
  analysis: image.png
- `c134-0256` symptom: 2月25日，上午11点10分发现，A-108蚂蚁机器人在充电桩位置断连。尝试ping两个IP地址发现都无法ping通。
  analysis: image.png
- `c134-0283` symptom: 4月19日，中午11点24分左右发现，A-107蚂蚁机器人断连。
  analysis: image.png

Training focus:

- Correlate robot disconnect time with AP packet loss, network-card dumpcap, MQTT, and last robot-to-robot communication.
- Distinguish single-robot NIC failure from site-wide network instability.

## Ant/load-handling

Cases: 27

Signals:

- `c134-0020` symptom: 8点40分，在WS002-2的盘点任务完成之后，A-110的蚂蚁机器人没有取箱离开，而是停在原地。
  analysis: Available robot logs mainly show the manual-recovery window, not the original no-action root cause.
- `c134-0047` symptom: 如题  18.27分  109蚂蚁在A2-S2-B9(左右一个)PT位取箱  举升后报错  人员处理时发现该位置没有料箱
  analysis: 18点9分的clear的A-108蚂蚁
- `c134-0048` symptom: 12月4日16.31分   A105蚂蚁在WS001-2位置  需要举升进入拣货台  但是举升失败报错
  analysis: 此报错非机器人上报
- `c134-0055` symptom: 2月2日，晚9.29分 A106带料箱TOTE-H-200585前往WS001-2位置，蚂蚁到达工作位的举升点时，没有举升动作，clear后任务变成带料箱返回接驳位。
  analysis: Local assets downloaded under `assets/c134-0055/`.
- `c134-0061` symptom: 12月5日，下午14点40分左右，A-105蚂蚁机器人在A1-S2-B2-PL1-PT1-PS1上放箱失败。
  analysis: Downloaded local assets under `assets/c134-0061/`.
- `c134-0078` symptom: 12月23日，13点59分，A-104蚂蚁机器人在WS001-2前的地码举箱报错。
  analysis: 见同类问题分析：【问题跟踪】2025-12-23 C134项目 A-104蚂蚁机器人举升失败
- `c134-0084` symptom: A-102蚂蚁机器人A3-S2-B10接驳位取箱失败  FLO界面能看到箱在位传感器是触发状态  但是实际料箱倾斜
  analysis: This is a visual/sensor mismatch handling case.
- `c134-0086` symptom: A-104蚂蚁机器人A2-S2-B9接驳位取箱失败  料箱倾斜
  analysis: - Observed fact: field photo shows A-104 with the tote visibly tilted/not normally seated at `A2-S2-B9`.
- `c134-0094` symptom: 12月20日，上午10点45分左右（具体时间未知），A-107蚂蚁机器人在A2-S2-B12-PT1位置取箱报错。
  analysis: - Observed fact: FLO screenshot shows A-107 active task failed while extracting `TOTE-L-600138` at `A2-S2-B12-PT1`.
- `c134-0098` symptom: 12月12日，上午8点40左右（具体时间未知），A-105蚂蚁机器人在PT位A1-S2-B2上还箱失败。
  analysis: image.png

Training focus:

- Correlate fork/arm state, PD/PT position, tote presence, motor state, quick stop, and offset calibration.
- Separate mechanical obstruction, position offset, task-state mismatch, and actuator/IO faults.

## Ant/sensor

Cases: 7

Signals:

- `c134-0137` symptom: 1月18日，上午15点05分左右，A112箱在位传感器报错。
  analysis: image.png
- `c134-0160` symptom: 1月21日，下午16点10分左右，A-102蚂蚁机器人在移动的过程中报错。
  analysis: - Observed fact: source reports A-102 fault while moving at about 2026-01-21 16:10 local time.
- `c134-0169` symptom: 1月21日，下午18点40分左右，A-101蚂蚁机器人在移动的过程中报错。
  analysis: - Observed fact: source reports A-101 fault while moving at about 2026-01-21 18:40 local time.
- `c134-0170` symptom: 1月21日，下午20点16分左右，A-112蚂蚁机器人在移动的过程中报错。
  analysis: - Observed fact: source reports A-112 fault while moving at about 2026-01-21 20:16 local time.
- `c134-0171` symptom: 1月19日，下午12点55分左右，A-108蚂蚁机器人原地报错。
  analysis: - Observed fact: source reports A-108 fault at about 2026-01-19 12:55 local time.
- `c134-0181` symptom: 1月4日，下午17点13分左右，A-101蚂蚁机器人在WS002进入点报错  箱在位传感器状态异常   人工检查发现   箱在位传感器正常触发  箱子正常位于蚂蚁顶升机构上
  analysis: - Observed fact: source reports A-101 load-sensor state abnormal at WS002 entry point around 2026-01-04 17:13 local time.
- `c134-0230` symptom: 2月6日，下午13点46分左右发现，WS002-3工位的箱在位传感器线束断裂。
  analysis: - Observed fact: source states WS002-3 load-sensor harness was broken at about 2026-02-06 13:46 local time.

Training focus:

- Correlate sensor trigger state with physical obstruction, IO wiring, and recovery after clear/reinitialize.

## Mantis/load-handling

Cases: 56

Signals:

- `c134-0008` symptom: 18点30分，M-A2-S1螳螂前防夹传感器触发报错，此时货叉已伸出，指拨已落下，为拉箱动作准备完毕，但箱子没有卡住，货叉也没有被阻碍；
  analysis: - Local assets downloaded: NXP log, wormhole log, CAN1/CAN2 pcaps, and two photos.
- `c134-0010` symptom: 1月30日，下午15点44分左右发现，A2巷道螳螂在A2-S2-B5-PT1拉箱失败。（该PT位还没有更换钣金件）。
  analysis: - Local assets downloaded: NXP, wormhole, can1/can2 pcaps, UI screenshot, and field photo.
- `c134-0013` symptom: 11月7日 10点10分左右 A3巷道螳螂机器人在移动到箱子的点位后，停止不动并报错，如下：
  analysis: - Local assets downloaded: CAN1/CAN2 pcaps, wormhole log, and four photos.
- `c134-0026` symptom: 16:24 螳螂机器人报错拉箱失败，把螳螂恢复后螳螂左右摇摆，下方蚂蚁停止不动
  analysis: - Local assets downloaded: `mmexport1763197708759.mp4`, `0.log`, `0.log.20251115-155335.gz`, `0.log.20251115-161022.gz`, `0.log.20251115-162526.gz`, and `0.log.20251115-164306`. Original short `.gz` request names map to the downloaded `0.log.*.gz` files.
- `c134-0054` symptom: 12月4日，上午9点45分左右，A-106蚂蚁需要在PT位上取货，此时M1螳螂进行避让。
  analysis: - Observed fact: source states A-106 needed to pick at a PT around 2025-12-04 09:45 local time while M1 performed避让.
- `c134-0076` symptom: 12月22日，10点56分48秒，M-A3-S2-1螳螂在A3-S1-B1-L11-T3拉箱失败
  analysis: - Local assets downloaded: video, CAN1/CAN2 pcaps, RCS/RMS logs, and three photos.
- `c134-0077` symptom: 12月22日，11点39分，A1巷道螳螂上报还箱错误。从监控与实际的情况来看，在11点38分50秒左右，A1巷道螳螂已经将料箱放在了PT位上。
  analysis: 12/22/2025, 11:38:00 螳螂机器人M-A1-S1-1，收到拉取TOTE-H-100073箱子的任务。
- `c134-0079` symptom: 12月22日，18.54分   M3螳螂因为接驳位原因导致拉箱失败  人工介入断电重启，人工clear一次。
  analysis: 根据视频中反馈整理反馈和发生问题时间点
- `c134-0085` symptom: 12月29日，下午13点14分左右，A2巷道螳螂在A2-S2-B3处的PT位拉箱时报错，此时拉的料箱箱号为100269.
  analysis: - Local assets downloaded: NXP, wormhole, can2 pcap, UI screenshot, and field photo. Source says CAN1 was `0kb` during the fault and could not be collected.
- `c134-0096` symptom: 12月17日，下午14点26分左右，A2巷道螳螂机器人在拉箱时报错。
  analysis: accept

Training focus:

- Correlate fork/arm state, PD/PT position, tote presence, motor state, quick stop, and offset calibration.
- Separate mechanical obstruction, position offset, task-state mismatch, and actuator/IO faults.

## Mantis/power

Cases: 6

Signals:

- `c134-0053` symptom: 2月2日，下午15点09分左右发现，A3巷道的1号螳螂机器人重启。
  analysis: 2月2日15:09左右发现 A3巷道1号螳螂重启，FLO 截图显示 `M-A3-S2-1` 为 `Unknown`，active task `Moving To (7652, 14416, 2094)` failed。
- `c134-0182` symptom: 1月5日，下午18点12分左右，M-A3-S2-2螳螂将料浆TOTE-H-200050放置与A3-S2-B10接驳位后报错   FLO界面观察螳螂位unknow状态  此时伸缩臂已完全收回
  analysis: 1月5日18:12左右，`M-A3-S2-2` 将 `TOTE-H-200050` 放置于 `A3-S2-B10` 接驳位后报错；FLO 截图显示 `M-A3-S2-2` 为 `Unknown`，active task `Depositing To A3-S2-B10-PL1-PT1-PS1` failed、`Unloading From M-A3-S2-2` failed，child tote 为 `TOTE-H-200050`。
- `c134-0253` symptom: 2月24日，上午8点21分左右发现，A3巷道1号螳螂机器人原地重启，具体重启时间未知。
  analysis: 2月24日上午8点21分左右发现 A3巷道1号螳螂机器人原地重启，具体重启时间未知。截图显示 robot list 中 `M-A3-S2-1` 为 `Unknown`，另一张日志截图显示 `can1.pcap` 与 `can2.pcap` 在 `2026/2/24 8:26` 均为 `0 KB`，源文档结论为该时间段 CAN 日志丢失。
- `c134-0277` symptom: 3月18日，上午8点25分左右发现A3巷道1号螳螂机器人flo界面处于Unknown状态，由于螳螂机器人夜间不断电，所以判断该螳螂机器人重启。
  analysis: 3月18日上午8点25分左右发现 A3巷道1号螳螂机器人 FLO 界面处于 `Unknown`。源文档推断：由于螳螂夜间不断电，所以判断该螳螂机器人重启。截图显示 `M-A3-S2-1` 为 `Unknown`，位置 `x: 7652 y: 11348 z: 2094`，`Anti-pinch Front` 未触发。
- `c134-0350` symptom: 3月28日，上午8点47分，工作台WS002下发入库任务之后，全库机器人没有动作，flo界面没有报错，网络通畅。
  analysis: 截止到9:32 上层sas系统任务调度没有给螳螂下发拉箱的EXTRACT任务
- `c134-0438` symptom: 1月26日，下午13点25分左右， A1巷道螳螂机器人报错。在处理的过程中发现螳螂上存在料箱，但是FLO界面上该螳螂没有料箱。
  analysis: 螳螂报错后，料箱数据不准确属于正常现象。请按照标准流程操作，将出问题时对应的料箱传送到孤儿区，再重新走料箱入库流程。

Training focus:

- Correlate battery percentage, boost-module shutdown, reboot timing, charging-point state, and NXP/system logs.
- Separate real power loss from UI/status-light restart symptoms.

## Mantis/network

Cases: 2

Signals:

- `c134-0150` symptom: 1月26日，自下午16.30-18.10分，设备锻炼断联现象频发。
  analysis: 2026-01-23 聚合分析，11:56:37 - 14:56:00
- `c134-0353` symptom: 3月14日，上午9点32分，全库停止运行，flo界面显示所有机器人全部断连，flo界面显示所有机器人全部断连。刷新后，界面没有显示机器人。
  analysis: unknown

Training focus:

- Correlate robot disconnect time with AP packet loss, network-card dumpcap, MQTT, and last robot-to-robot communication.
- Distinguish single-robot NIC failure from site-wide network instability.

## Mantis/motion-localization

Cases: 1

Signals:

- `c134-0184` symptom: 1月7日，晚上20点01分50秒左右，M-A2-S1-1螳螂自B1往B13方向行走  撞上了穿梭A2巷道的A111蚂蚁
  analysis: 碰撞事件基本信息

Training focus:

- Correlate DM code loss, angle deviation, floor-code contamination, speed/acceleration changes, and collision aftermath.
- Treat path blockage and localization loss as separate hypotheses until logs/video confirm one.

## Mantis/sensor

Cases: 1

Signals:

- `c134-0303` symptom: 5月21号，下午14:27左右现场发现A3巷道1号螳螂机器人报错了，FLO界面显示是红框圈出部分的传感器触发。
  analysis: 5月21日14:27左右，现场发现 A3巷道1号螳螂机器人报错；FLO 传感器截图红框圈出 `Anti-pinch Rear`。现场检查螳螂传感器时发现货叉松动；联系技术部维修后，作业结束排查认为可能是皮带压块松动导致皮带松动。

Training focus:

- Correlate sensor trigger state with physical obstruction, IO wiring, and recovery after clear/reinitialize.
