#!/usr/bin/env python3
import argparse
import json
import pathlib
import re


ROUTES = [
    {
        "area": "mantis.load_handling",
        "needles": ["螳螂", "M-A", "fork", "货叉", "拨指", "quick stop", "PT", "PD", "拉箱", "还箱"],
        "specialists": ["mantis-handling", "can-bus", "embedded-software", "scheduler-traffic", "vision-media"],
        "knowledge": "mantis-load-handling.md",
    },
    {
        "area": "ant.motion_localization",
        "needles": ["跑偏", "丢码", "地码", "DM code", "转角过大", "angle", "撞", "偏移"],
        "specialists": ["robot-motion", "embedded-software", "can-bus", "vision-media"],
        "knowledge": "ant-motion-localization.md",
    },
    {
        "area": "ant.network",
        "needles": ["断连", "MQTT", "ping", "AP", "EasyBox", "网卡", "Kafka", "RVS", "全库断连"],
        "specialists": ["network-infra", "embedded-software"],
        "knowledge": "ant-network.md",
    },
    {
        "area": "ant.load_handling",
        "needles": ["举升", "箱在位", "料箱", "取箱", "还箱", "接驳位", "工作台没有", "load sensor"],
        "specialists": ["embedded-software", "robot-motion", "scheduler-traffic", "vision-media"],
        "knowledge": "ant-load-handling.md",
    },
    {
        "area": "ant.power",
        "needles": ["重启", "关机", "低电", "充电", "蓝灯", "蜂鸣器", "under voltage", "UPTIME"],
        "specialists": ["embedded-software", "can-bus", "scheduler-traffic", "network-infra"],
        "knowledge": "ant-power.md",
    },
    {
        "area": "workstation_wled",
        "needles": ["WLED", "HLED", "灯带", "WS001", "WS002", "工作台"],
        "specialists": ["workstation"],
        "knowledge": None,
    },
]


def score(route, text):
    lowered = text.lower()
    total = 0
    hits = []
    for needle in route["needles"]:
        if needle.lower() in lowered:
            total += 1
            hits.append(needle)
    return total, hits


def main():
    parser = argparse.ArgumentParser(description="Route a C134 issue packet to Troubleshooter specialists.")
    parser.add_argument("packet", help="Path to a text or markdown issue packet.")
    args = parser.parse_args()

    path = pathlib.Path(args.packet)
    text = path.read_text(encoding="utf-8", errors="replace")
    ranked = []
    for route in ROUTES:
        route_score, hits = score(route, text)
        if route_score:
            ranked.append((route_score, hits, route))
    ranked.sort(key=lambda item: item[0], reverse=True)

    if ranked:
        best_score, hits, route = ranked[0]
        decision = {
            "decision": "diagnose",
            "area": route["area"],
            "matched_terms": hits,
            "specialists": route["specialists"],
            "knowledge": route["knowledge"],
        }
    else:
        decision = {
            "decision": "insufficient",
            "area": "unknown_needs_assets",
            "matched_terms": [],
            "specialists": ["leader"],
            "knowledge": None,
        }

    decision["asset_signals"] = sorted(set(re.findall(r"[\w./()（）-]+\\.(?:log|pcap|mp4|mov|jpg|jpeg|png|gz|7z)", text, re.I)))
    print(json.dumps(decision, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
