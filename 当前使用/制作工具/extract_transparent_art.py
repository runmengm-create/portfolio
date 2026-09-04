"""Create transparent artwork layers from the approved visual masters.

The source masters are not edited or overwritten. Crops deliberately exclude
all baked text; the final page renders copy in HTML on top of a continuous CSS
paper background.
"""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]


SPECS = [
    # source, output, x, y, width, height
    (
        ROOT / "当前使用/视觉母版/works-open-fields-master-v1.png",
        ROOT / "assets/illustrations/works/project-01.png",
        72,
        244,
        388,
        354,
    ),
    (
        ROOT / "当前使用/视觉母版/works-open-fields-master-v1.png",
        ROOT / "assets/illustrations/works/project-02.png",
        430,
        570,
        414,
        372,
    ),
    (
        ROOT / "当前使用/视觉母版/works-open-fields-master-v1.png",
        ROOT / "assets/illustrations/works/project-03.png",
        78,
        942,
        405,
        358,
    ),
    (
        ROOT / "当前使用/视觉母版/works-open-fields-master-v1.png",
        ROOT / "assets/illustrations/works/project-04.png",
        410,
        1264,
        430,
        360,
    ),
    (
        ROOT / "当前使用/视觉母版/role-overview-horizontal-master-v1.png",
        ROOT / "当前使用/制作中间产物/role-overview-artwork.png",
        0,
        242,
        1671,
        430,
    ),
]


def transparent_crop(source: Path, output: Path, x: int, y: int, width: int, height: int) -> None:
    image = Image.open(source).convert("RGB").crop((x, y, x + width, y + height))
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for py in range(height):
        for px in range(width):
            red, green, blue, _ = pixels[px, py]
            luminance = (299 * red + 587 * green + 114 * blue) // 1000
            cobalt = blue > 135 and blue - max(red, green) > 24 and blue > green + 8
            strip_cobalt = "works-open-fields" in str(source)
            alpha = 0 if cobalt and strip_cobalt else (255 if cobalt else max(0, min(255, (218 - luminance) * 7)))
            if alpha < 10:
                pixels[px, py] = (0, 0, 0, 0)
            else:
                pixels[px, py] = (red, green, blue, alpha)
    output.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, mode="RGBA").save(output, optimize=True)
    print(f"wrote {output.relative_to(ROOT)} ({width}x{height})")


for spec in SPECS:
    transparent_crop(*spec)
