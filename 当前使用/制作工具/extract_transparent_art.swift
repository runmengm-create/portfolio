import Foundation
import CoreGraphics
import ImageIO

struct CropSpec {
    let source: String
    let output: String
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

func loadImage(_ path: String) -> CGImage? {
    let url = root.appendingPathComponent(path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(source, 0, nil)
}

func clamp(_ value: Int) -> UInt8 {
    UInt8(max(0, min(255, value)))
}

func makeTransparentCrop(_ spec: CropSpec) throws {
    guard let source = loadImage(spec.source) else {
        throw NSError(domain: "ExtractArt", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load \(spec.source)"])
    }
    guard let cropped = source.cropping(to: CGRect(x: spec.x, y: spec.y, width: spec.width, height: spec.height)) else {
        throw NSError(domain: "ExtractArt", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not crop \(spec.output)"])
    }

    let width = cropped.width
    let height = cropped.height
    let bytesPerRow = width * 4
    var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "ExtractArt", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not create bitmap context"])
    }
    context.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: height))
    let stripCobalt = spec.source.contains("works-open-fields")

    for y in 0..<height {
        for x in 0..<width {
            let index = y * bytesPerRow + x * 4
            let red = Int(pixels[index])
            let green = Int(pixels[index + 1])
            let blue = Int(pixels[index + 2])
            let luminance = (299 * red + 587 * green + 114 * blue) / 1000
            let blueDelta = blue - max(red, green)
            let isCobalt = blue > 135 && blueDelta > 24 && blue > green + 8
            let inkAlpha = max(0, min(255, (218 - luminance) * 7))
            let alpha = isCobalt ? (stripCobalt ? 0 : 255) : inkAlpha

            if alpha < 10 {
                pixels[index] = 0
                pixels[index + 1] = 0
                pixels[index + 2] = 0
                pixels[index + 3] = 0
            } else {
                pixels[index + 3] = UInt8(alpha)
            }
        }
    }

    guard let outputContext = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ), let outputImage = outputContext.makeImage() else {
        throw NSError(domain: "ExtractArt", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not create output image"])
    }

    let outputURL = root.appendingPathComponent(spec.output)
    let directory = outputURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, "public.png" as CFString, 1, nil) else {
        throw NSError(domain: "ExtractArt", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not create PNG destination"])
    }
    CGImageDestinationAddImage(destination, outputImage, [kCGImagePropertyPNGDictionary: [kCGImagePropertyPNGInterlaceType: 0]] as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
        throw NSError(domain: "ExtractArt", code: 6, userInfo: [NSLocalizedDescriptionKey: "Could not write \(spec.output)"])
    }
    print("wrote \(spec.output) (\(width)x\(height))")
}

let specs = [
    // New Works: crop only the black/cobalt open-field forms; all labels stay HTML.
    CropSpec(source: "当前使用/视觉母版/works-open-fields-master-v1.png", output: "assets/illustrations/works/project-01.png", x: 72, y: 244, width: 388, height: 354),
    CropSpec(source: "当前使用/视觉母版/works-open-fields-master-v1.png", output: "assets/illustrations/works/project-02.png", x: 430, y: 570, width: 414, height: 372),
    CropSpec(source: "当前使用/视觉母版/works-open-fields-master-v1.png", output: "assets/illustrations/works/project-03.png", x: 78, y: 942, width: 405, height: 358),
    CropSpec(source: "当前使用/视觉母版/works-open-fields-master-v1.png", output: "assets/illustrations/works/project-04.png", x: 410, y: 1264, width: 430, height: 360),

    // Role overview: the upper visual journey is one transparent artwork strip; labels stay HTML.
    CropSpec(source: "当前使用/视觉母版/role-overview-horizontal-master-v1.png", output: "当前使用/制作中间产物/role-overview-artwork.png", x: 0, y: 242, width: 1671, height: 430),
]

for spec in specs {
    try makeTransparentCrop(spec)
}
