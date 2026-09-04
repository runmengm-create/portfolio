"""Prepare a static line-art layer for the Role Overview artwork.

The approved role artwork is a transparent RGBA PNG with the cobalt route
painted into the same layer as the black illustration. This small, dependency-
free PNG pass removes the cobalt pixels and the rejected brush texture at the
far-right endpoint so the route can be rendered as a coordinate-locked SVG.
"""

from pathlib import Path
import struct
import zlib


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "当前使用/制作中间产物/role-overview-artwork.png"
OUTPUT = ROOT / "assets/illustrations/role/role-overview-artwork-static.png"


def read_png(path: Path):
    raw = path.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("expected a PNG file")
    position = 8
    width = height = None
    bit_depth = color_type = None
    compressed = bytearray()
    while position < len(raw):
        length = struct.unpack(">I", raw[position:position + 4])[0]
        kind = raw[position + 4:position + 8]
        payload = raw[position + 8:position + 8 + length]
        position += 12 + length
        if kind == b"IHDR":
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", payload)
            if bit_depth != 8 or color_type != 6 or interlace != 0:
                raise ValueError("only non-interlaced 8-bit RGBA PNGs are supported")
        elif kind == b"IDAT":
            compressed.extend(payload)
        elif kind == b"IEND":
            break
    decoded = zlib.decompress(bytes(compressed))
    stride = width * 4
    rows = []
    cursor = 0
    previous = bytearray(stride)
    for _ in range(height):
        filter_type = decoded[cursor]
        cursor += 1
        current = bytearray(decoded[cursor:cursor + stride])
        cursor += stride
        for index in range(stride):
            left = current[index - 4] if index >= 4 else 0
            above = previous[index]
            upper_left = previous[index - 4] if index >= 4 else 0
            if filter_type == 1:
                current[index] = (current[index] + left) & 255
            elif filter_type == 2:
                current[index] = (current[index] + above) & 255
            elif filter_type == 3:
                current[index] = (current[index] + ((left + above) // 2)) & 255
            elif filter_type == 4:
                estimate = left + above - upper_left
                distances = (abs(estimate - left), abs(estimate - above), abs(estimate - upper_left))
                predictor = (left, above, upper_left)[distances.index(min(distances))]
                current[index] = (current[index] + predictor) & 255
            elif filter_type != 0:
                raise ValueError(f"unsupported PNG filter {filter_type}")
        rows.append(current)
        previous = current
    return width, height, rows


def chunk(kind: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF)


def write_png(path: Path, width: int, height: int, rows):
    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    scanlines = b"".join(b"\x00" + bytes(row) for row in rows)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(scanlines, 9)) + chunk(b"IEND", b"")
    path.write_bytes(data)


def is_cobalt(red: int, green: int, blue: int) -> bool:
    return blue > red + 2 and blue > green + 2


def main():
    width, height, rows = read_png(SOURCE)
    for y, row in enumerate(rows):
        for x in range(width):
            index = x * 4
            red, green, blue, alpha = row[index:index + 4]
            # The rejected endpoint is a separate visual zone. Clear it
            # completely; the replacement route and node are drawn in SVG.
            endpoint_brush = x > 1360 and y > 270
            if is_cobalt(red, green, blue) or endpoint_brush:
                row[index:index + 4] = b"\x00\x00\x00\x00"
    write_png(OUTPUT, width, height, rows)
    print(f"wrote {OUTPUT.relative_to(ROOT)} ({width}x{height})")


if __name__ == "__main__":
    main()
