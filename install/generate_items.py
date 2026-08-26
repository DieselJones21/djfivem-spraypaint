#!/usr/bin/env python3
"""Generate paints.lua and inventory item files for all 82 chameleon colours."""

from __future__ import annotations

from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
ICON = ROOT / "html" / "chameleonpaint.png"

# GTA5-Mods Chameleon Paint 2.0 (Wildbrick142): 62 Rockstar + 20 custom = 82
# Colour index == item number on gamebuild 2699+.
PAINTS = [
    # Anodized (Rockstar)
    (161, "ANOD_RED", "Anodized Red Pearl", "anodized"),
    (162, "ANOD_WINE", "Anodized Wine Pearl", "anodized"),
    (163, "ANOD_PURPLE", "Anodized Purple Pearl", "anodized"),
    (164, "ANOD_BLUE", "Anodized Blue Pearl", "anodized"),
    (165, "ANOD_GREEN", "Anodized Green Pearl", "anodized"),
    (166, "ANOD_LIME", "Anodized Lime Pearl", "anodized"),
    (167, "ANOD_COPPER", "Anodized Copper Pearl", "anodized"),
    (168, "ANOD_BRONZE", "Anodized Bronze Pearl", "anodized"),
    (169, "ANOD_CHAMPAGNE", "Anodized Champagne Pearl", "anodized"),
    (170, "ANOD_GOLD", "Anodized Gold Pearl", "anodized"),
    # Flip (Rockstar)
    (171, "GREEN_BLUE_FLIP", "Green/Blue Flip", "flip"),
    (172, "GREEN_RED_FLIP", "Green/Red Flip", "flip"),
    (173, "GREEN_BROW_FLIP", "Green/Brown Flip", "flip"),
    (174, "GREEN_TURQ_FLIP", "Green/Turquoise Flip", "flip"),
    (175, "GREEN_PURP_FLIP", "Green/Purple Flip", "flip"),
    (176, "TEAL_PURP_FLIP", "Teal/Purple Flip", "flip"),
    (177, "TURQ_RED_FLIP", "Turquoise/Red Flip", "flip"),
    (178, "TURQ_PURP_FLIP", "Turquoise/Purple Flip", "flip"),
    (179, "CYAN_PURP_FLIP", "Cyan/Purple Flip", "flip"),
    (180, "BLUE_PINK_FLIP", "Blue/Pink Flip", "flip"),
    (181, "BLUE_GREEN_FLIP", "Blue/Green Flip", "flip"),
    (182, "PURP_RED_FLIP", "Purple/Red Flip", "flip"),
    (183, "PURP_GREEN_FLIP", "Purple/Green Flip", "flip"),
    (184, "MAGEN_GREE_FLIP", "Magenta/Green Flip", "flip"),
    (185, "MAGEN_YELL_FLIP", "Magenta/Yellow Flip", "flip"),
    (186, "BURG_GREEN_FLIP", "Burgundy/Green Flip", "flip"),
    (187, "MAGEN_CYAN_FLIP", "Magenta/Cyan Flip", "flip"),
    (188, "COPPE_PURP_FLIP", "Copper/Purple Flip", "flip"),
    (189, "MAGEN_ORAN_FLIP", "Magenta/Orange Flip", "flip"),
    (190, "RED_ORANGE_FLIP", "Red/Orange Flip", "flip"),
    (191, "ORANG_PURP_FLIP", "Orange/Purple Flip", "flip"),
    (192, "ORANG_BLUE_FLIP", "Orange/Blue Flip", "flip"),
    (193, "WHITE_PURP_FLIP", "White/Purple Flip", "flip"),
    (194, "RED_RAINBO_FLIP", "Red/Rainbow Flip", "flip"),
    (195, "BLU_RAINBO_FLIP", "Blue/Rainbow Flip", "flip"),
    # Pearl (Rockstar)
    (196, "DARKGREENPEARL", "Dark Green Pearl", "pearl"),
    (197, "DARKTEALPEARL", "Dark Teal Pearl", "pearl"),
    (198, "DARKBLUEPEARL", "Dark Blue Pearl", "pearl"),
    (199, "DARKPURPLEPEARL", "Dark Purple Pearl", "pearl"),
    (200, "OIL_SLICK_PEARL", "Oil Slick Pearl", "pearl"),
    (201, "LIT_GREEN_PEARL", "Light Green Pearl", "pearl"),
    (202, "LIT_BLUE_PEARL", "Light Blue Pearl", "pearl"),
    (203, "LIT_PURP_PEARL", "Light Purple Pearl", "pearl"),
    (204, "LIT_PINK_PEARL", "Light Pink Pearl", "pearl"),
    (205, "OFFWHITE_PRISMA", "Off White Pearl", "pearl"),
    (206, "PINK_PEARL", "Pink Pearl", "pearl"),
    (207, "YELLOW_PEARL", "Yellow Pearl", "pearl"),
    (208, "GREEN_PEARL", "Green Pearl", "pearl"),
    (209, "BLUE_PEARL", "Blue Pearl", "pearl"),
    (210, "CREAM_PEARL", "Cream Pearl", "pearl"),
    # Prismatic / holo (Rockstar)
    (211, "WHITE_PRISMA", "White Prismatic Pearl", "prisma"),
    (212, "GRAPHITE_PRISMA", "Graphite Prismatic Pearl", "prisma"),
    (213, "DARKBLUEPRISMA", "Dark Blue Prismatic Pearl", "prisma"),
    (214, "DARKPURPPRISMA", "Dark Purple Prismatic Pearl", "prisma"),
    (215, "HOT_PINK_PRISMA", "Hot Pink Prismatic Pearl", "prisma"),
    (216, "RED_PRISMA", "Red Prismatic Pearl", "prisma"),
    (217, "GREEN_PRISMA", "Green Prismatic Pearl", "prisma"),
    (218, "BLACK_PRISMA", "Black Prismatic Pearl", "prisma"),
    (219, "OIL_SLIC_PRISMA", "Oil Spill Prismatic Pearl", "prisma"),
    (220, "RAINBOW_PRISMA", "Rainbow Prismatic Pearl", "prisma"),
    (221, "BLACK_HOLO", "Black Holographic Pearl", "holo"),
    (222, "WHITE_HOLO", "White Holographic Pearl", "holo"),
    # Custom YKTA (Wildbrick142) — these need streamed ramps
    (223, "YKTA_MONOCHROME", "Monochrome Spray", "ykta"),
    (224, "YKTA_NITE_DAY", "Night & Day Spray", "ykta"),
    (225, "YKTA_VERLIERER2", "The Verlierer Spray", "ykta"),
    (226, "YKTA_SPRUNK_EX", "Sprunk Extreme Spray", "ykta"),
    (227, "YKTA_VICE_CITY", "Vice City Spray", "ykta"),
    (228, "YKTA_SYNTHWAVE", "Synthwave Nights Spray", "ykta"),
    (229, "YKTA_FOUR_SEASO", "Four Seasons Spray", "ykta"),
    (230, "YKTA_M9_THROWBA", "Maisonette 9 Throwback Spray", "ykta"),
    (231, "YKTA_BUBBLEGUM", "Bubblegum Spray", "ykta"),
    (232, "YKTA_FULL_RBOW", "Full Rainbow Spray", "ykta"),
    (233, "YKTA_SUNSETS", "Sunset Spray", "ykta"),
    (234, "YKTA_THE_SEVEN", "The Seven Spray", "ykta"),
    (235, "YKTA_KAMENRIDER", "Kamen Rider Spray", "ykta"),
    (236, "YKTA_CHROMABERA", "Chromatic Aberration Spray", "ykta"),
    (237, "YKTA_CHRISTMAS", "Its Christmas! Spray", "ykta"),
    (238, "YKTA_TEMPERATUR", "Temperature Spray", "ykta"),
    (239, "YKTA_HSW", "HSW Badge Spray", "ykta"),
    (240, "YKTA_ELECTRO", "Anodized Lightning Spray", "ykta"),
    (241, "YKTA_MONIKA", "Emeralds Spray", "ykta"),
    (242, "YKTA_FUBUKI", "Fubuki Castle Spray", "ykta"),
]


def item_name(number: int) -> str:
    return f"chameleonpaint_{number}"


def write_paints_lua() -> None:
    lines = [
        "--[[",
        "    All 82 chameleon paints from the GTA5-Mods Chameleon Paint pack",
        "    (62 Rockstar official 161-222 + 20 Wildbrick custom 223-242).",
        "",
        "    item/number/color use the same GTA colour index on gamebuild 2699+.",
        "]]",
        "",
        "ChameleonPaints = {",
    ]
    for number, code, label, category in PAINTS:
        item = item_name(number)
        lines.append(
            "    { item = '%s', number = %s, color = %s, label = '%s', code = '%s', category = '%s' },"
            % (item, number, number, label.replace("'", "\\'"), code, category)
        )
    lines += [
        "}",
        "",
        "ChameleonPaintsByItem = {}",
        "ChameleonPaintsByNumber = {}",
        "",
        "for i = 1, #ChameleonPaints do",
        "    local paint = ChameleonPaints[i]",
        "    ChameleonPaintsByItem[paint.item] = paint",
        "    ChameleonPaintsByNumber[paint.number] = paint",
        "end",
        "",
        "function GetPaintByItem(itemName)",
        "    if type(itemName) ~= 'string' then return nil end",
        "    return ChameleonPaintsByItem[itemName]",
        "end",
        "",
        "function GetPaintByNumber(number)",
        "    return ChameleonPaintsByNumber[tonumber(number)]",
        "end",
        "",
        "function GetPaintColorIndex(paint)",
        "    if not paint then return nil end",
        "    return paint.color",
        "end",
        "",
    ]
    (ROOT / "shared" / "paints.lua").write_text("\n".join(lines), encoding="utf-8")


def write_ox_items() -> None:
    chunks = [
        "-- Paste these entries inside ox_inventory/data/items.lua (inside the return { ... } table).",
        "-- Then copy install/ox_inventory_images/*.png into ox_inventory/web/images/",
        "",
    ]
    for number, _code, label, _category in PAINTS:
        item = item_name(number)
        chunks.append(
            "\n".join(
                [
                    f"	['{item}'] = {{",
                    f"		label = '#{number} {label}',",
                    "		weight = 1,",
                    "		stack = true,",
                    "		close = true,",
                    "		consume = 0,",
                    f"		description = 'Chameleon spray #{number}. Use in a vehicle to paint it. Paint is saved.',",
                    "		client = {",
                    f"			image = '{item}.png',",
                    "			export = 'djfivem-spraypaint.chameleonpaint',",
                    "		},",
                    "	},",
                ]
            )
        )
    (ROOT / "install" / "ox_inventory_items.lua").write_text("\n".join(chunks) + "\n", encoding="utf-8")


def write_qb_items() -> None:
    lines = [
        "-- Paste these into qb-core/shared/items.lua (or your items file)",
        "-- Copy install/ox_inventory_images/*.png into your inventory images folder",
        "",
        "QBShared = QBShared or {}",
        "QBShared.Items = QBShared.Items or {}",
        "",
        "local chameleonItems = {",
    ]
    for number, _code, label, _category in PAINTS:
        item = item_name(number)
        lines.append(
            f"    {item} = {{ name = '{item}', label = '#{number} {label}', weight = 1, type = 'item', image = '{item}.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #{number}. Use in a vehicle to paint it. Paint is saved.' }},"
        )
    lines += [
        "}",
        "",
        "for name, item in pairs(chameleonItems) do",
        "    QBShared.Items[name] = item",
        "end",
        "",
    ]
    (ROOT / "install" / "qb-core_items.lua").write_text("\n".join(lines), encoding="utf-8")


def write_esx_sql() -> None:
    rows = []
    for number, _code, label, _category in PAINTS:
        item = item_name(number)
        rows.append(f"('{item}', '#{number} {label}', 1, 0, 1)")
    text = (
        "-- ESX item rows (skip this if you use ox_inventory — use ox_inventory_items.lua instead)\n\n"
        "INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES\n"
        + ",\n".join(rows)
        + "\nON DUPLICATE KEY UPDATE `label` = VALUES(`label`);\n"
    )
    (ROOT / "install" / "esx_items.sql").write_text(text, encoding="utf-8")


def write_paints_md() -> None:
    groups = {
        "anodized": "Anodized (161–170)",
        "flip": "Flip (171–195)",
        "pearl": "Pearl (196–210)",
        "prisma": "Prismatic (211–220)",
        "holo": "Holographic (221–222)",
        "ykta": "Custom YKTA / Fubuki (223–242)",
    }
    by_cat: dict[str, list] = {k: [] for k in groups}
    for number, code, label, category in PAINTS:
        by_cat[category].append((number, code, label))
    lines = ["# All 82 chameleon paints", ""]
    for key, title in groups.items():
        lines += [f"## {title}", "", "| # | Item | Name |", "| --- | --- | --- |"]
        for number, code, label in by_cat[key]:
            lines.append(f"| {number} | `chameleonpaint_{number}` | {label} |")
        lines.append("")
    (ROOT / "install" / "PAINTS.md").write_text("\n".join(lines), encoding="utf-8")


def copy_icons() -> None:
    dest_dir = ROOT / "install" / "ox_inventory_images"
    dest_dir.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ICON, dest_dir / "chameleonpaint.png")
    for number, *_ in PAINTS:
        shutil.copyfile(ICON, dest_dir / f"{item_name(number)}.png")


def main() -> None:
    assert len(PAINTS) == 82, len(PAINTS)
    assert [p[0] for p in PAINTS] == list(range(161, 243))
    write_paints_lua()
    write_ox_items()
    write_qb_items()
    write_esx_sql()
    write_paints_md()
    copy_icons()
    print(f"generated {len(PAINTS)} paints")


if __name__ == "__main__":
    main()
