#!/usr/bin/env python3
"""Draw unique ox_inventory icons that show each chameleon colour."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "install" / "ox_inventory_images"
SIZE = 256

# Two or more RGB stops. Flips read left→right; pearls get a bright sheen.
STOPS: dict[int, list[tuple[int, int, int]]] = {
    161: [(190, 28, 36), (95, 10, 18), (220, 70, 55)],
    162: [(120, 22, 48), (58, 8, 24), (160, 45, 70)],
    163: [(130, 42, 190), (55, 16, 95), (175, 90, 230)],
    164: [(28, 72, 200), (10, 28, 95), (70, 130, 240)],
    165: [(18, 150, 72), (8, 60, 32), (50, 200, 110)],
    166: [(150, 220, 40), (70, 140, 18), (210, 245, 90)],
    167: [(196, 96, 42), (110, 48, 18), (230, 150, 80)],
    168: [(158, 104, 48), (86, 52, 20), (200, 150, 85)],
    169: [(228, 198, 148), (168, 132, 88), (250, 230, 190)],
    170: [(236, 188, 48), (150, 108, 18), (255, 230, 120)],
    171: [(18, 165, 72), (28, 78, 205)],
    172: [(18, 165, 72), (198, 28, 40)],
    173: [(18, 150, 70), (128, 72, 32)],
    174: [(18, 150, 70), (28, 198, 185)],
    175: [(18, 150, 70), (145, 42, 185)],
    176: [(18, 145, 155), (145, 42, 185)],
    177: [(28, 198, 185), (198, 28, 40)],
    178: [(28, 198, 185), (145, 42, 185)],
    179: [(36, 214, 224), (145, 42, 185)],
    180: [(28, 78, 205), (236, 92, 175)],
    181: [(28, 78, 205), (18, 165, 72)],
    182: [(145, 42, 185), (198, 28, 40)],
    183: [(145, 42, 185), (18, 165, 72)],
    184: [(214, 38, 150), (18, 165, 72)],
    185: [(214, 38, 150), (236, 206, 40)],
    186: [(128, 22, 48), (18, 150, 70)],
    187: [(214, 38, 150), (36, 214, 224)],
    188: [(196, 96, 42), (145, 42, 185)],
    189: [(214, 38, 150), (236, 124, 28)],
    190: [(198, 28, 40), (236, 124, 28)],
    191: [(236, 124, 28), (145, 42, 185)],
    192: [(236, 124, 28), (28, 78, 205)],
    193: [(245, 245, 250), (145, 42, 185)],
    194: [(198, 28, 40), (236, 124, 28), (236, 206, 40), (18, 165, 72), (28, 78, 205)],
    195: [(28, 78, 205), (36, 214, 224), (18, 165, 72), (236, 206, 40), (198, 28, 40)],
    196: [(12, 48, 26), (36, 110, 58)],
    197: [(8, 48, 54), (22, 118, 128)],
    198: [(8, 20, 62), (28, 58, 150)],
    199: [(38, 12, 60), (92, 36, 140)],
    200: [(12, 18, 16), (20, 90, 70), (90, 40, 140), (140, 90, 20)],
    201: [(96, 220, 128), (40, 160, 82)],
    202: [(96, 176, 236), (40, 108, 190)],
    203: [(186, 136, 236), (118, 72, 186)],
    204: [(255, 176, 206), (226, 104, 156)],
    205: [(248, 244, 232), (214, 204, 188)],
    206: [(240, 96, 156), (204, 48, 112)],
    207: [(246, 216, 58), (204, 164, 28)],
    208: [(48, 196, 92), (18, 132, 56)],
    209: [(48, 112, 226), (22, 62, 176)],
    210: [(250, 230, 186), (224, 194, 142)],
    211: [(250, 250, 255), (210, 230, 255), (255, 220, 240)],
    212: [(58, 62, 68), (90, 110, 140), (70, 70, 80)],
    213: [(10, 24, 70), (40, 90, 190), (20, 40, 110)],
    214: [(40, 12, 70), (120, 50, 180), (60, 20, 100)],
    215: [(255, 70, 170), (255, 140, 210), (200, 30, 130)],
    216: [(210, 24, 36), (255, 90, 80), (140, 10, 20)],
    217: [(20, 170, 70), (80, 230, 130), (10, 90, 40)],
    218: [(12, 12, 14), (50, 60, 80), (20, 20, 24)],
    219: [(8, 10, 12), (20, 90, 70), (90, 40, 150), (160, 100, 20), (20, 40, 90)],
    220: [(220, 30, 40), (240, 140, 20), (240, 210, 40), (30, 180, 70), (30, 80, 210), (140, 40, 200)],
    221: [(8, 8, 10), (40, 80, 160), (160, 40, 140), (20, 20, 24)],
    222: [(250, 250, 255), (180, 220, 255), (255, 190, 230), (230, 255, 230)],
    223: [(12, 12, 14), (180, 180, 185), (40, 40, 44)],
    224: [(8, 16, 48), (250, 230, 170)],
    225: [(70, 78, 88), (200, 40, 55)],
    226: [(40, 190, 55), (210, 240, 40)],
    227: [(236, 40, 150), (40, 210, 230), (90, 40, 180)],
    228: [(40, 10, 80), (220, 40, 160), (40, 80, 220)],
    229: [(30, 140, 70), (230, 160, 40), (140, 70, 30), (80, 160, 210)],
    230: [(180, 140, 40), (80, 40, 120), (220, 180, 70)],
    231: [(255, 120, 190), (255, 190, 220), (240, 70, 160)],
    232: [(220, 30, 40), (240, 140, 20), (240, 210, 40), (30, 180, 70), (30, 80, 210), (140, 40, 200)],
    233: [(255, 90, 40), (255, 160, 70), (180, 50, 120), (50, 20, 80)],
    234: [(20, 40, 110), (200, 170, 50), (10, 16, 50)],
    235: [(190, 20, 30), (220, 180, 50), (20, 20, 22)],
    236: [(230, 20, 50), (20, 220, 240)],
    237: [(200, 20, 30), (20, 140, 50), (250, 240, 230)],
    238: [(30, 90, 220), (240, 240, 245), (220, 40, 40)],
    239: [(240, 110, 20), (20, 20, 22), (255, 180, 40)],
    240: [(40, 180, 255), (240, 230, 40), (20, 80, 180)],
    241: [(10, 120, 70), (80, 230, 140), (20, 60, 40)],
    242: [(230, 240, 255), (70, 130, 200), (20, 40, 90)],
}

RAINBOW = [
    (220, 30, 40),
    (240, 140, 20),
    (240, 210, 40),
    (30, 180, 70),
    (30, 80, 210),
    (140, 40, 200),
]


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def mix(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def sample_stops(stops: list[tuple[int, int, int]], t: float) -> tuple[int, int, int]:
    if len(stops) == 1:
        return stops[0]
    t = max(0.0, min(1.0, t))
    scaled = t * (len(stops) - 1)
    i = min(int(scaled), len(stops) - 2)
    local = scaled - i
    return mix(stops[i], stops[i + 1], local)


def load_font(size: int) -> ImageFont.ImageFont:
    for path in (
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    ):
        if Path(path).is_file():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def rounded_mask(size: tuple[int, int], box: tuple[int, int, int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius=radius, fill=255)
    return mask


def sheen_overlay(size: tuple[int, int], box: tuple[int, int, int, int], radius: int) -> Image.Image:
    overlay = Image.new("RGBA", size, (0, 0, 0, 0))
    x0, y0, x1, y1 = box
    for x in range(x0, x1):
        t = (x - x0) / max(1, x1 - x0)
        # Specular stripe on the left-center of the can.
        shine = math.exp(-((t - 0.28) ** 2) / 0.012)
        alpha = int(90 * shine)
        if alpha <= 0:
            continue
        ImageDraw.Draw(overlay).line([(x, y0), (x, y1)], fill=(255, 255, 255, alpha))
    mask = rounded_mask(size, box, radius)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    out.paste(overlay, mask=mask)
    return out


def fill_box_with_gradient(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    stops: list[tuple[int, int, int]],
    radius: int,
    horizontal: bool = True,
) -> None:
    x0, y0, x1, y1 = box
    w, h = max(1, x1 - x0), max(1, y1 - y0)
    grad = Image.new("RGBA", (w, h))
    px = grad.load()
    for y in range(h):
        for x in range(w):
            t = x / (w - 1) if horizontal else y / (h - 1)
            # Slight vertical darkening so the can looks cylindrical.
            shade = 0.78 + 0.22 * math.sin(math.pi * (x / (w - 1)))
            r, g, b = sample_stops(stops, t)
            px[x, y] = (
                min(255, int(r * shade)),
                min(255, int(g * shade)),
                min(255, int(b * shade)),
                255,
            )
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.paste(grad, (x0, y0))
    mask = rounded_mask(canvas.size, box, radius)
    canvas.paste(layer, mask=mask)


def sparkles(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], count: int, seed: int) -> None:
    x0, y0, x1, y1 = box
    for i in range(count):
        n = (seed * 1103515245 + i * 12345) & 0x7FFFFFFF
        x = x0 + 8 + (n % max(1, x1 - x0 - 16))
        y = y0 + 8 + ((n // 97) % max(1, y1 - y0 - 16))
        s = 1 + (n % 3)
        draw.ellipse((x, y, x + s, y + s), fill=(255, 255, 255, 180))


def draw_can(stops: list[tuple[int, int, int]], number: int, category: str) -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")

    body = (84, 78, 172, 228)
    cap = (100, 34, 156, 84)
    nozzle = (118, 22, 138, 38)
    lip = (92, 70, 164, 86)

    # Soft drop shadow
    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((body[0] + 6, body[1] + 10, body[2] + 6, body[3] + 10), 28, fill=(0, 0, 0, 90))
    img = Image.alpha_composite(img, shadow.filter(ImageFilter.GaussianBlur(6)))
    draw = ImageDraw.Draw(img, "RGBA")

    fill_box_with_gradient(img, body, stops, 26, horizontal=True)
    img = Image.alpha_composite(img, sheen_overlay(img.size, body, 26))
    draw = ImageDraw.Draw(img, "RGBA")

    fill_box_with_gradient(img, cap, stops, 14, horizontal=True)
    draw.rounded_rectangle(lip, 8, fill=(30, 30, 34, 255))
    draw.rounded_rectangle(nozzle, 4, fill=(210, 210, 215, 255))
    draw.rectangle((122, 16, 134, 24), fill=(170, 170, 175, 255))

    if category in {"pearl", "prisma", "holo"}:
        sparkles(draw, body, 14 if category == "holo" else 8, number)

    # Number badge
    badge = (96, 196, 160, 222)
    draw.rounded_rectangle(badge, 8, fill=(12, 12, 16, 210))
    font = load_font(22)
    text = str(number)
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(
        ((badge[0] + badge[2] - tw) / 2, (badge[1] + badge[3] - th) / 2 - 2),
        text,
        font=font,
        fill=(255, 255, 255, 255),
    )
    return img


def draw_remover() -> Image.Image:
    stops = [(230, 230, 235), (180, 180, 188), (120, 20, 28)]
    img = draw_can(stops, 0, "anodized")
    draw = ImageDraw.Draw(img, "RGBA")
    draw.line((96, 100, 160, 190), fill=(200, 30, 40, 230), width=10)
    draw.line((160, 100, 96, 190), fill=(200, 30, 40, 230), width=10)
    font = load_font(16)
    draw.rounded_rectangle((78, 196, 178, 222), 8, fill=(12, 12, 16, 220))
    draw.text((86, 198), "REMOVE", font=font, fill=(255, 255, 255, 255))
    return img


def contact_sheet(images: list[tuple[str, Image.Image]], cols: int = 10) -> Image.Image:
    thumb = 96
    pad = 8
    rows = math.ceil(len(images) / cols)
    sheet = Image.new("RGBA", (cols * (thumb + pad) + pad, rows * (thumb + pad) + pad), (24, 24, 28, 255))
    for i, (_name, im) in enumerate(images):
        r, c = divmod(i, cols)
        tile = im.resize((thumb, thumb), Image.Resampling.LANCZOS)
        sheet.paste(tile, (pad + c * (thumb + pad), pad + r * (thumb + pad)), tile)
    return sheet


def category_for(number: int) -> str:
    if number <= 170:
        return "anodized"
    if number <= 195:
        return "flip"
    if number <= 210:
        return "pearl"
    if number <= 220:
        return "prisma"
    if number <= 222:
        return "holo"
    return "ykta"


def generate() -> list[Path]:
    OUT.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    preview: list[tuple[str, Image.Image]] = []

    missing = [n for n in range(161, 243) if n not in STOPS]
    if missing:
        raise SystemExit(f"missing colour stops for {missing}")

    for number in range(161, 243):
        im = draw_can(STOPS[number], number, category_for(number))
        path = OUT / f"chameleonpaint_{number}.png"
        im.save(path, "PNG", optimize=True)
        written.append(path)
        preview.append((str(number), im))

    remover = draw_remover()
    rpath = OUT / "dono_paint_remover.png"
    remover.save(rpath, "PNG", optimize=True)
    written.append(rpath)
    preview.append(("R", remover))

    generic = draw_can(RAINBOW, 0, "ykta")
    generic.save(OUT / "chameleonpaint.png", "PNG", optimize=True)
    written.append(OUT / "chameleonpaint.png")

    sheet = contact_sheet(preview)
    sheet_path = ROOT / "install" / "icon_sheet.png"
    sheet.save(sheet_path, "PNG", optimize=True)
    written.append(sheet_path)
    return written


if __name__ == "__main__":
    paths = generate()
    print(f"wrote {len(paths)} icon files")
