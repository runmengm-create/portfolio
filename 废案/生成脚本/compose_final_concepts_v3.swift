import Foundation
import CoreGraphics
import ImageIO

let root = "/Users/runmeng.ma/Desktop/马润萌/portfolio-local-preview"
let desktopIn = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v2.png"
let mobileIn = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v2.png"
let desktopOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v3.png"
let mobileOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v3.png"

func load(_ path: String) -> CGImage {
    let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(source, 0, nil)!
}

func context(_ w: Int, _ h: Int) -> CGContext {
    CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
              bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}

func save(_ image: CGImage, _ path: String) {
    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
}

func cobalt() -> CGColor { CGColor(red: 0.184, green: 0.388, blue: 0.914, alpha: 1) }

func bezier(_ ctx: CGContext, _ H: CGFloat, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: a.x, y: H - a.y))
    path.addCurve(to: CGPoint(x: d.x, y: H - d.y),
                  control1: CGPoint(x: b.x, y: H - b.y),
                  control2: CGPoint(x: c.x, y: H - c.y))
    ctx.saveGState()
    ctx.setStrokeColor(cobalt()); ctx.setLineWidth(2.6); ctx.setLineCap(.round)
    ctx.addPath(path); ctx.strokePath(); ctx.restoreGState()
}

func composeDesktop() {
    let W: CGFloat = 1536, H: CGFloat = 3072
    let ctx = context(Int(W), Int(H)); ctx.draw(load(desktopIn), in: CGRect(x: 0, y: 0, width: W, height: H))
    // Continue exactly from the V2 About endpoint (1040,1690) to the first approved Projects route node.
    // The final curve stays in the Project header whitespace and meets the existing node at (108,2038).
    bezier(ctx,H,CGPoint(x:1040,y:1690),CGPoint(x:1080,y:1750),CGPoint(x:920,y:1860),CGPoint(x:720,y:1930))
    bezier(ctx,H,CGPoint(x:720,y:1930),CGPoint(x:500,y:1980),CGPoint(x:220,y:1985),CGPoint(x:108,y:2038))
    save(ctx.makeImage()!, desktopOut)
}

func composeMobile() {
    let W: CGFloat = 750, H: CGFloat = 2400
    let ctx = context(Int(W), Int(H)); ctx.draw(load(mobileIn), in: CGRect(x: 0, y: 0, width: W, height: H))
    // Continue from the V2 About endpoint (610,1420), mostly downward, then left into the approved node.
    bezier(ctx,H,CGPoint(x:610,y:1420),CGPoint(x:640,y:1460),CGPoint(x:590,y:1500),CGPoint(x:500,y:1530))
    bezier(ctx,H,CGPoint(x:500,y:1530),CGPoint(x:350,y:1570),CGPoint(x:150,y:1570),CGPoint(x:53,y:1585))
    save(ctx.makeImage()!, mobileOut)
}

composeDesktop()
composeMobile()
