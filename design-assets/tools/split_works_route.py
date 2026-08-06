"""Split the baked cobalt route from the approved Works runtime image.

This is a deterministic, same-resolution asset operation. It does not resize,
regenerate, sharpen, or globally filter the source image.
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets" / "works-background.png"
BASE_OUTPUT = ROOT / "assets" / "works-background-base.png"
ROUTE_OUTPUT = ROOT / "assets" / "works-route.png"


def connected_components(mask: np.ndarray):
    height, width = mask.shape
    seen = np.zeros_like(mask, dtype=bool)
    components = []

    for y in range(height):
        for x in range(width):
            if not mask[y, x] or seen[y, x]:
                continue

            stack = [(y, x)]
            seen[y, x] = True
            points = []

            while stack:
                current_y, current_x = stack.pop()
                points.append((current_y, current_x))

                for offset_y in (-1, 0, 1):
                    for offset_x in (-1, 0, 1):
                        if offset_x == 0 and offset_y == 0:
                            continue
                        next_y = current_y + offset_y
                        next_x = current_x + offset_x
                        if not (0 <= next_y < height and 0 <= next_x < width):
                            continue
                        if mask[next_y, next_x] and not seen[next_y, next_x]:
                            seen[next_y, next_x] = True
                            stack.append((next_y, next_x))

            components.append(points)

    return components


def fill_removed_route(rgb: np.ndarray, route_mask: np.ndarray) -> np.ndarray:
    """Fill only the thin removed route with nearby paper pixels."""

    result = rgb.copy()
    height, width = route_mask.shape
    route_y, route_x = np.where(route_mask)
    offsets = [(-72, 0), (72, 0), (-96, 3), (96, -3), (0, -42), (0, 42)]

    for y, x in zip(route_y, route_x):
        replacement = None

        for offset_x, offset_y in offsets:
            sample_x = x + offset_x
            sample_y = y + offset_y
            if not (0 <= sample_x < width and 0 <= sample_y < height):
                continue
            if route_mask[sample_y, sample_x]:
                continue
            sample = rgb[sample_y, sample_x]
            if int(sample.min()) > 170 and int(sample.max()) - int(sample.min()) < 32:
                replacement = sample
                break

        if replacement is not None:
            result[y, x] = replacement

    return result


def main():
    source_image = Image.open(SOURCE).convert("RGB")
    rgb = np.array(source_image)
    red = rgb[:, :, 0].astype(int)
    green = rgb[:, :, 1].astype(int)
    blue = rgb[:, :, 2].astype(int)

    cobalt_core = (blue > 135) & ((blue - red) > 35) & ((blue - green) > 8)
    components = connected_components(cobalt_core)
    route_components = [component for component in components if len(component) > 500]

    if len(route_components) != 3:
        raise RuntimeError(f"Expected 3 route segments, found {len(route_components)}")

    route_core = np.zeros_like(cobalt_core, dtype=np.uint8)
    for component in route_components:
        for y, x in component:
            route_core[y, x] = 255

    # Include the original anti-aliased edge pixels, but no card dots or crosses.
    route_mask_image = Image.fromarray(route_core, mode="L").filter(ImageFilter.MaxFilter(9))
    route_display_mask = np.array(route_mask_image) > 0
    channel_max = np.max(rgb, axis=2)
    channel_min = np.min(rgb, axis=2)
    preserve_dark_ink = (channel_max < 150) & ((channel_max - channel_min) < 35)
    route_remove_mask = route_display_mask & ~preserve_dark_ink

    base_rgb = fill_removed_route(rgb, route_remove_mask)
    Image.fromarray(base_rgb, mode="RGB").save(BASE_OUTPUT, optimize=True)

    route_rgb = np.where(route_display_mask[:, :, None], rgb, 0).astype(np.uint8)
    route_rgba = np.dstack((route_rgb, np.where(route_display_mask, 255, 0).astype(np.uint8)))
    Image.fromarray(route_rgba, mode="RGBA").save(ROUTE_OUTPUT, optimize=True)

    print(f"source={source_image.size[0]}x{source_image.size[1]}")
    print(f"route_components={sorted(len(component) for component in route_components)}")
    print(f"changed_pixels={int(route_remove_mask.sum())}")
    print(BASE_OUTPUT)
    print(ROUTE_OUTPUT)


if __name__ == "__main__":
    main()
