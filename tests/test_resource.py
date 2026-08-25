#!/usr/bin/env python3
"""Validate chameleon paint catalog, items, assets, and persistence helpers."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def parse_paints() -> list[dict]:
    text = (ROOT / "shared" / "paints.lua").read_text(encoding="utf-8")
    pattern = re.compile(
        r"\{\s*item\s*=\s*'([^']+)'\s*,\s*number\s*=\s*(\d+)\s*,\s*color\s*=\s*(\d+)\s*,\s*label\s*=\s*'([^']+)'\s*,\s*code\s*=\s*'([^']+)'\s*\}",
        re.MULTILINE,
    )
    paints = []
    for item, number, color, label, code in pattern.findall(text):
        paints.append(
            {
                "item": item,
                "number": int(number),
                "color": int(color),
                "label": label,
                "code": code,
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
    assert len(paints) == 16, f"expected 16 paints, got {len(paints)}"
    numbers = [p["number"] for p in paints]
    colors = [p["color"] for p in paints]
    items = [p["item"] for p in paints]
    assert numbers == list(range(161, 177))
    assert colors == list(range(223, 239))
    assert items == [f"chameleonpaint_{n}" for n in range(161, 177)]
    assert len(set(items)) == 16
    assert len(set(colors)) == 16
    assert paints[0]["label"] == "Monochrome Spray"
    assert paints[-1]["label"] == "Temperature Spray"
    assert paints[4]["label"] == "Vice City Spray"


def test_item_files_match_catalog():
    paints = parse_paints()
    ox = (ROOT / "install" / "ox_inventory_items.lua").read_text(encoding="utf-8")
    qb = (ROOT / "install" / "qb-core_items.lua").read_text(encoding="utf-8")
    esx = (ROOT / "install" / "esx_items.sql").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    for paint in paints:
        assert f"['{paint['item']}']" in ox
        assert f"export = 'djfivem-spraypaint.chameleonpaint'" in ox
        assert "consume = 0" in ox
        assert f"#{paint['number']}" in ox
        assert paint["item"] in qb
        assert paint["item"] in esx
        assert paint["item"] in readme
        image = ROOT / "install" / "ox_inventory_images" / f"{paint['item']}.png"
        assert image.is_file() and image.stat().st_size > 0


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
    assert carcols.count("<rampTextureName>") == 16
    assert "vehicle_paint_ramps_01" in carcols

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
    assert paint["color"] == 223
    # Config.UseLegacyIndexes = false -> 223; true -> 161
    assert paint["color"] != paint["number"]


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
    assert "AllowInsideVehicle" in client
    assert "exports('chameleonpaint'" in client


def test_labels():
    paints = parse_paints()
    assert display_item_label(paints[0]) == "#161 Monochrome Spray"
    assert display_item_label(paints[9]) == "#170 Full Rainbow Spray"


def main():
    tests = [
        test_paint_catalog,
        test_item_files_match_catalog,
        test_stream_and_meta_assets,
        test_plate_normalization,
        test_color_mode_mapping,
        test_persistence_sql,
        test_labels,
    ]
    for test in tests:
        test()
        print(f"PASS {test.__name__}")
    print(f"OK {len(tests)} tests")


if __name__ == "__main__":
    main()
