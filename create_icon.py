#!/usr/bin/env python3
"""
App icon generator for Books Tracker.
Run: python3 create_icon.py
Output: assets/icon/app_icon.png  (1024x1024 PNG)
"""
from PIL import Image, ImageDraw, ImageFilter
import math

S = 1024  # canvas size


def bilinear_gradient(tl, tr, bl, br):
    """Fast 4-corner gradient via PIL resize trick — no numpy needed."""
    tiny = Image.new("RGB", (2, 2))
    tiny.putpixel((0, 0), tl)
    tiny.putpixel((1, 0), tr)
    tiny.putpixel((0, 1), bl)
    tiny.putpixel((1, 1), br)
    return tiny.resize((S, S), Image.BILINEAR)


def rounded_mask(radius=230):
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, S - 1, S - 1], radius=radius, fill=255)
    return mask


def draw_sparkle(draw, cx, cy, size, color, points=4):
    """Draw an n-pointed sparkle star."""
    pts = []
    for i in range(points * 2):
        angle = math.radians(i * 180 / points - 90)
        r = size if i % 2 == 0 else size * 0.32
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(pts, fill=color)


def composite(base, overlay):
    return Image.alpha_composite(base, overlay)


def create_icon():
    # ── 1. Gradient background ───────────────────────────────────────────────
    # Rich purple (top-left)  →  violet (top-right)
    #        ↓                         ↓
    # deep purple (bot-left)  →  hot pink/magenta (bot-right)
    bg = bilinear_gradient(
        tl=(38, 20, 115),
        tr=(108, 28, 162),
        bl=(70, 16, 140),
        br=(218, 56, 138),
    )
    bg_rgba = bg.convert("RGBA")
    bg_rgba.putalpha(rounded_mask(230))

    canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    canvas = composite(canvas, bg_rgba)

    # Soft centre glow for depth
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [S // 2 - 320, S // 2 - 320, S // 2 + 320, S // 2 + 320],
        fill=(255, 255, 255, 20),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(90))
    canvas = composite(canvas, glow)

    # ── 2. Book geometry ─────────────────────────────────────────────────────
    cx    = S // 2          # 512  horizontal centre / spine
    top   = 242
    bot   = 792
    left  = 162
    right = 862
    sp    = 28              # spine half-width

    PAGE  = (255, 252, 228)   # warm cream
    SHADE = (218, 192, 142)   # page-edge shading strip
    SPINE = (165, 115, 40)    # golden brown
    LINE  = (198, 168, 108)   # muted-gold text lines

    # Drop shadow beneath the book
    shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse(
        [left + 70, bot + 5, right - 70, bot + 68],
        fill=(0, 0, 0, 110),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    canvas = composite(canvas, shadow)

    draw = ImageDraw.Draw(canvas)

    # ── Left page ────────────────────────────────────────────────────────────
    draw.polygon(
        [(left + 22, top + 10), (cx - sp, top), (cx - sp, bot), (left + 22, bot - 10)],
        fill=PAGE,
    )
    # Narrow shading strip along the outer edge for 3-D depth
    draw.polygon(
        [(left + 22, top + 10), (left + 54, top + 12),
         (left + 54, bot - 12), (left + 22, bot - 10)],
        fill=SHADE,
    )

    # ── Right page ───────────────────────────────────────────────────────────
    draw.polygon(
        [(cx + sp, top), (right - 22, top + 10), (right - 22, bot - 10), (cx + sp, bot)],
        fill=PAGE,
    )
    draw.polygon(
        [(right - 54, top + 12), (right - 22, top + 10),
         (right - 22, bot - 10), (right - 54, bot - 12)],
        fill=SHADE,
    )

    # ── Spine ────────────────────────────────────────────────────────────────
    draw.rectangle([cx - sp, top, cx + sp, bot], fill=SPINE)
    draw.rectangle([cx - sp,     top, cx - sp + 7, bot], fill=(198, 152, 62))  # highlight
    draw.rectangle([cx + sp - 7, top, cx + sp,     bot], fill=(112, 80, 22))   # shadow

    # ── Text lines — left page ───────────────────────────────────────────────
    lx1, lx2 = left + 68, cx - sp - 48
    for i in range(12):
        y = top + 88 + i * 44
        if y > bot - 72:
            break
        x2 = lx2 if i % 3 != 2 else lx2 - 78
        draw.line([(lx1, y), (x2, y)], fill=LINE, width=7)

    # ── Text lines — right page ──────────────────────────────────────────────
    rx1, rx2 = cx + sp + 48, right - 68
    for i in range(12):
        y = top + 88 + i * 44
        if y > bot - 72:
            break
        x2 = rx2 if i % 3 != 1 else rx2 - 82
        draw.line([(rx1, y), (x2, y)], fill=LINE, width=7)

    # ── 3. Bookmark ──────────────────────────────────────────────────────────
    bm_x1  = right - 150
    bm_x2  = right - 84
    bm_mid = (bm_x1 + bm_x2) // 2
    bm_t   = top - 22
    bm_len = 192
    notch  = 38
    BM     = (255, 98, 38)    # vivid orange

    draw.polygon(
        [(bm_x1, bm_t), (bm_x2, bm_t),
         (bm_x2, bm_t + bm_len),
         (bm_mid, bm_t + bm_len - notch),
         (bm_x1, bm_t + bm_len)],
        fill=BM,
    )
    # Bookmark shine
    draw.rectangle([bm_x1, bm_t, bm_x1 + 8, bm_t + bm_len - notch // 2],
                   fill=(255, 148, 98))

    # ── 4. Sparkle stars ─────────────────────────────────────────────────────
    GOLD  = (255, 214, 58)
    LGOLD = (255, 236, 145)

    for sx, sy, sr, sc in [
        (135, 175, 28, GOLD),
        (880, 198, 22, GOLD),
        (106, 616, 17, LGOLD),
        (918, 582, 19, GOLD),
        (188, 848, 20, GOLD),
        (848, 838, 16, LGOLD),
        (302, 135, 15, LGOLD),
        (768, 132, 19, GOLD),
        (928, 372, 13, LGOLD),
        ( 92, 395, 14, GOLD),
    ]:
        draw_sparkle(draw, sx, sy, sr, sc)

    # ── 5. Save ──────────────────────────────────────────────────────────────
    # Flatten alpha onto white before saving (iOS strips alpha anyway)
    final = Image.new("RGB", (S, S), (255, 255, 255))
    r, g, b, a = canvas.split()
    final.paste(Image.merge("RGB", (r, g, b)), mask=a)
    out = "assets/icon/app_icon.png"
    final.save(out, "PNG")
    print(f"Saved {out}  ({S}×{S})")


if __name__ == "__main__":
    create_icon()
