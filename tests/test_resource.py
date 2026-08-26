#!/usr/bin/env python3
"""Validate chameleon paint catalog, items, assets, and persistence helpers."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def parse_paints() -> list[dict]:
    text = (ROOT / "shared" / "paints.lua").read_text(encoding="utf-8")
    pattern = re.compile(
        r"\{\s*item\s*=\s*'([^']+)'\s*,\s*number\s*=\s*(\d+)\s*,\s*color\s*=\s*(\d+)\s*,\s*label\s*=\s*'([^']+)'\s*,\s*code\s*=\s*'([^']+)'(?:\s*,\s*category\s*=\s*'([^']+)')?\s*\}",
        re.MULTILINE,
    )
    paints = []
    for item, number, color, label, code, category in pattern.findall(text):
        paints.append(
            {
                "item": item,
                "number": int(number),
                "color": int(color),
                "label": label,
                "code": code,
                "category": category or "",
            }
        )
    return paints


def trim_plate(plate: str | None) -> str:
    if plate is None:
        return ""
    return str(plate).strip()


def plate_key(plate: str | None) -> str:
    return re.sub(r"\s+", "", trim_plate(plate)).upper()


def display_item_label(paint: dict) -> str:
    return f"#{paint['number']} {paint['label']}"


def test_paint_catalog():
    paints = parse_paints()
    assert len(paints) == 82, f"expected 82 paints, got {len(paints)}"
    numbers = [p["number"] for p in paints]
    colors = [p["color"] for p in paints]
    items = [p["item"] for p in paints]
    assert numbers == list(range(161, 243))
    assert colors == numbers
    assert items == [f"chameleonpaint_{n}" for n in range(161, 243)]
    assert len(set(items)) == 82
    assert paints[0]["label"] == "Anodized Red Pearl"
    assert paints[0]["code"] == "ANOD_RED"
    assert paints[62]["number"] == 223
    assert paints[62]["label"] == "Monochrome Spray"
    assert paints[-1]["label"] == "Fubuki Castle Spray"
    assert paints[-1]["number"] == 242
    by_cat = {}
    for paint in paints:
        by_cat.setdefault(paint["category"], 0)
        by_cat[paint["category"]] += 1
    assert by_cat["anodized"] == 10
    assert by_cat["flip"] == 25
    assert by_cat["pearl"] == 15
    assert by_cat["prisma"] == 10
    assert by_cat["holo"] == 2
    assert by_cat["ykta"] == 20


def test_item_files_match_catalog():
    paints = parse_paints()
    ox = (ROOT / "install" / "ox_inventory_items.lua").read_text(encoding="utf-8")
    qb = (ROOT / "install" / "qb-core_items.lua").read_text(encoding="utf-8")
    esx = (ROOT / "install" / "esx_items.sql").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    catalog = (ROOT / "install" / "PAINTS.md").read_text(encoding="utf-8")
    for paint in paints:
        assert f"['{paint['item']}']" in ox
        assert paint["item"] in qb
        assert paint["item"] in esx
        assert paint["item"] in catalog
        image = ROOT / "install" / "ox_inventory_images" / f"{paint['item']}.png"
        assert image.is_file() and image.stat().st_size > 0
    assert "export = 'djfivem-spraypaint.chameleonpaint'" in ox
    assert "consume = 0" in ox
    assert "chameleonpaint_161" in readme
    assert "chameleonpaint_242" in readme
    assert "82" in readme


def test_stream_and_meta_assets():
    required = [
        ROOT / "data" / "carcols_gen9.meta",
        ROOT / "data" / "carmodcols_gen9.meta",
        ROOT / "data" / "carmodcols.ymt",
        ROOT / "stream" / "vehicle_paint_ramps.ytd",
        ROOT / "html" / "spraypaint.ogg",
        ROOT / "html" / "chameleonpaint.png",
        ROOT / "LICENSE",
        ROOT / "sql" / "install.sql",
    ]
    for path in required:
        assert path.is_file() and path.stat().st_size > 0, path

    carcols = (ROOT / "data" / "carcols_gen9.meta").read_text(encoding="utf-8")
    assert carcols.count("<rampTextureName>") == 20
    assert "vehicle_paint_ramp_fubuki001" in carcols
    assert "vehicle_paint_ramp_fubuki020" in carcols
    assert (ROOT / "stream" / "vehicle_paint_ramps.ytd").stat().st_size > 100000

    mods = (ROOT / "data" / "carmodcols_gen9.meta").read_text(encoding="utf-8")
    assert 'col value="223"' in mods
    assert 'col value="242"' in mods

    fx = (ROOT / "fxmanifest.lua").read_text(encoding="utf-8")
    for name in (
        "CARCOLS_GEN9_FILE",
        "CARMODCOLS_GEN9_FILE",
        "FIVEM_LOVES_YOU_447B37BE29496FA0",
        "shared/paints.lua",
        "client/apply.lua",
        "server/persist.lua",
        "html/index.html",
    ):
        assert name in fx


def test_plate_normalization():
    assert plate_key("abc 123 ") == "ABC123"
    assert plate_key("  ABC123  ") == "ABC123"
    assert plate_key("AB12CDEF") == "AB12CDEF"
    assert plate_key(None) == ""
    assert trim_plate("  ABC123 ") == "ABC123"


def test_color_mode_mapping():
    paints = parse_paints()
    paint = paints[0]
    assert paint["number"] == 161
    assert paint["color"] == 161
    mono = next(p for p in paints if p["number"] == 223)
    assert mono["color"] == 223
    assert mono["label"] == "Monochrome Spray"


def test_persistence_sql():
    sql = (ROOT / "sql" / "install.sql").read_text(encoding="utf-8")
    assert "chameleon_vehicle_paints" in sql
    assert "plate_key" in sql
    persist = (ROOT / "server" / "persist.lua").read_text(encoding="utf-8")
    assert "SaveChameleonPaint" in persist
    assert "player_vehicles" in persist
    assert "owned_vehicles" in persist
    assert "chameleonPaint" in persist
    apply = (ROOT / "client" / "apply.lua").read_text(encoding="utf-8")
    assert "ClearVehicleCustomPrimaryColour" in apply
    assert "SetVehicleColours" in apply
    client = (ROOT / "client" / "main.lua").read_text(encoding="utf-8")
    assert "AllowOutsideVehicle" in client
    assert "exports('chameleonpaint'" in client
    server = (ROOT / "server" / "main.lua").read_text(encoding="utf-8")
    assert "161-242" in server


def test_facing_math():
    import math

    def heading_dot(heading, from_x, from_y, to_x, to_y):
        rad = math.radians(heading)
        fx = -math.sin(rad)
        fy = math.cos(rad)
        dx, dy = to_x - from_x, to_y - from_y
        length = math.hypot(dx, dy)
        if length < 0.001:
            return 1.0
        return (fx * dx / length) + (fy * dy / length)

    def is_facing(heading, from_x, from_y, to_x, to_y, max_angle=70):
        return heading_dot(heading, from_x, from_y, to_x, to_y) >= math.cos(math.radians(max_angle))

    assert heading_dot(0, 0, 0, 0, 10) > 0.99
    assert abs(heading_dot(0, 0, 0, 10, 0)) < 0.01
    assert is_facing(0, 0, 0, 0, 10, 70) is True
    assert is_facing(0, 0, 0, 10, 0, 70) is False
    assert is_facing(180, 0, 10, 0, 0, 70) is True
    utils = (ROOT / "shared" / "utils.lua").read_text(encoding="utf-8")
    assert "function IsFacingTarget" in utils
    assert "function HeadingDotToTarget" in utils


def test_remover_and_outside_spray():
    ox = (ROOT / "install" / "ox_inventory_items.lua").read_text(encoding="utf-8")
    qb = (ROOT / "install" / "qb-core_items.lua").read_text(encoding="utf-8")
    esx = (ROOT / "install" / "esx_items.sql").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    config = (ROOT / "config.lua").read_text(encoding="utf-8")
    client = (ROOT / "client" / "main.lua").read_text(encoding="utf-8")
    persist = (ROOT / "server" / "persist.lua").read_text(encoding="utf-8")
    server = (ROOT / "server" / "main.lua").read_text(encoding="utf-8")
    assert ox.count("['dono_paint_remover']") == 1
    assert "djfivem-spraypaint.paintremover" in ox
    assert "dono_paint_remover" in qb
    assert "dono_paint_remover" in esx
    assert "dono_paint_remover" in readme
    image = ROOT / "install" / "ox_inventory_images" / "dono_paint_remover.png"
    assert image.is_file() and image.stat().st_size > 0
    assert "RequireFacingVehicle" in config
    assert "prop_cs_spray_can" in client
    assert "notFacing" in client
    assert "exports('paintremover'" in client
    assert "ClearChameleonPaint" in persist
    assert "djfivem-spraypaint:server:remove" in server
    assert "giveremover" in server


def test_labels():
    paints = parse_paints()
    assert display_item_label(paints[0]) == "#161 Anodized Red Pearl"
    full_rainbow = next(p for p in paints if p["number"] == 232)
    assert display_item_label(full_rainbow) == "#232 Full Rainbow Spray"


def main():
    tests = [
        test_paint_catalog,
        test_item_files_match_catalog,
        test_stream_and_meta_assets,
        test_plate_normalization,
        test_color_mode_mapping,
        test_persistence_sql,
        test_labels,
        test_facing_math,
        test_remover_and_outside_spray,
    ]
    for test in tests:
        test()
        print(f"PASS {test.__name__}")
    print(f"OK {len(tests)} tests")


if __name__ == "__main__":
    main()
