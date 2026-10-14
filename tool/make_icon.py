# Builds the launcher icon layers from the transparent art (fuchsbau indigo background).
# Run: python3 tool/make_icon.py assets/icon/launenfuchs_art.png assets/icon
# then: dart run flutter_launcher_icons
import sys
from PIL import Image, ImageDraw
src, out = sys.argv[1], sys.argv[2]
INDIGO = (0x85, 0x59, 0xD0, 255)
art = Image.open(src).convert('RGBA')
art = art.crop(art.getchannel('A').getbbox())
S = 1024

def place(scale_h, bottom_pad):
    """Art scaled to scale_h of the canvas height, centred, sitting bottom_pad above the edge."""
    h = int(S * scale_h); w = int(art.width * h / art.height)
    a = art.resize((w, h), Image.LANCZOS)
    c = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    c.alpha_composite(a, ((S - w) // 2, S - h - bottom_pad))
    return c

# adaptive foreground: art inside the 66 % safe zone, body running off the bottom
fg = place(0.60, 150)
fg.save(f'{out}/launenfuchs_fg.png')
# full icon (legacy Android + iOS): opaque indigo, a bit larger
full = Image.new('RGBA', (S, S), INDIGO)
full.alpha_composite(place(0.84, 0))
full.convert('RGB').save(f'{out}/launenfuchs.png')
