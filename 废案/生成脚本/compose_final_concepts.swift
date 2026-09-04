import Foundation
import CoreGraphics
import CoreText
import ImageIO

let root = "/Users/runmeng.ma/Desktop/马润萌/portfolio-local-preview"
let approvedRole = root + "/design-assets/generated/approved/role-overview-horizontal-master-v1.png"
let approvedProjects = root + "/design-assets/generated/approved/works-open-fields-master-v1.png"
let desktopBase = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-base-v1.png"
let mobileBase = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-base-v1.png"
let desktopOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v1.png"
let mobileOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v1.png"

func loadImage(_ path: String) -> CGImage {
    let url = URL(fileURLWithPath: path) as CFURL
    let source = CGImageSourceCreateWithURL(url, nil)!
    return CGImageSourceCreateImageAtIndex(source, 0, nil)!
}

func makeContext(_ width: Int, _ height: Int) -> CGContext {
    CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
              bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}

func savePNG(_ image: CGImage, _ path: String) {
    let url = URL(fileURLWithPath: path) as CFURL
    let destination = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}

func topRect(_ canvasHeight: CGFloat, _ x: CGFloat, _ top: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    CGRect(x: x, y: canvasHeight - top - height, width: width, height: height)
}

func drawTopImage(_ ctx: CGContext, _ image: CGImage, _ canvasHeight: CGFloat, _ x: CGFloat, _ top: CGFloat, _ width: CGFloat, _ height: CGFloat) {
    ctx.draw(image, in: topRect(canvasHeight, x, top, width, height))
}

func drawTopCrop(_ ctx: CGContext, _ source: CGImage, _ canvasHeight: CGFloat, _ sourceRect: CGRect, _ x: CGFloat, _ top: CGFloat, _ width: CGFloat, _ height: CGFloat) {
    guard let crop = source.cropping(to: sourceRect) else { return }
    drawTopImage(ctx, crop, canvasHeight, x, top, width, height)
}

func drawTopRect(_ ctx: CGContext, _ canvasHeight: CGFloat, _ rect: CGRect, _ color: CGColor) {
    ctx.setFillColor(color)
    ctx.fill(topRect(canvasHeight, rect.minX, rect.minY, rect.width, rect.height))
}

func paperColor() -> CGColor { CGColor(red: 0.952, green: 0.938, blue: 0.895, alpha: 1) }
func blackColor(_ alpha: CGFloat = 1) -> CGColor { CGColor(red: 0.055, green: 0.052, blue: 0.047, alpha: alpha) }
func blueColor() -> CGColor { CGColor(red: 0.055, green: 0.27, blue: 0.78, alpha: 1) }

func font(_ size: CGFloat) -> CTFont {
    // Songti SC is preferred; the system falls back to the available Chinese serif face.
    CTFontCreateWithName("Songti SC" as CFString, size, nil)
}

func textWidth(_ string: String, _ size: CGFloat) -> CGFloat {
    let attrs: [NSAttributedString.Key: Any] = [kCTFontAttributeName as NSAttributedString.Key: font(size)]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: string, attributes: attrs))
    return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
}

func drawTextTop(_ ctx: CGContext, _ canvasHeight: CGFloat, _ string: String, _ x: CGFloat, _ top: CGFloat, _ size: CGFloat, _ color: CGColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        kCTFontAttributeName as NSAttributedString.Key: font(size),
        kCTForegroundColorAttributeName as NSAttributedString.Key: color
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: string, attributes: attrs))
    // Song-style fonts have a baseline around 0.82em below their top edge.
    ctx.textPosition = CGPoint(x: x, y: canvasHeight - top - size * 0.82)
    CTLineDraw(line, ctx)
}

func drawTopLine(_ ctx: CGContext, _ canvasHeight: CGFloat, _ points: [(CGFloat, CGFloat)], _ color: CGColor, _ width: CGFloat) {
    let path = CGMutablePath()
    for (index, point) in points.enumerated() {
        let converted = CGPoint(x: point.0, y: canvasHeight - point.1)
        if index == 0 { path.move(to: converted) } else { path.addLine(to: converted) }
    }
    ctx.saveGState()
    ctx.setStrokeColor(color)
    ctx.setLineWidth(width)
    ctx.setLineCap(.round)
    ctx.addPath(path)
    ctx.strokePath()
    ctx.restoreGState()
}

func drawTopBezier(_ ctx: CGContext, _ canvasHeight: CGFloat, _ start: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ end: CGPoint, _ color: CGColor, _ width: CGFloat) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: start.x, y: canvasHeight - start.y))
    path.addCurve(to: CGPoint(x: end.x, y: canvasHeight - end.y),
                  control1: CGPoint(x: c1.x, y: canvasHeight - c1.y),
                  control2: CGPoint(x: c2.x, y: canvasHeight - c2.y))
    ctx.saveGState()
    ctx.setStrokeColor(color)
    ctx.setLineWidth(width)
    ctx.setLineCap(.round)
    ctx.addPath(path)
    ctx.strokePath()
    ctx.restoreGState()
}

func drawCircle(_ ctx: CGContext, _ canvasHeight: CGFloat, _ x: CGFloat, _ y: CGFloat, _ radius: CGFloat, _ color: CGColor, _ width: CGFloat) {
    ctx.saveGState()
    ctx.setStrokeColor(color)
    ctx.setLineWidth(width)
    ctx.strokeEllipse(in: topRect(canvasHeight, x - radius, y - radius, radius * 2, radius * 2))
    ctx.restoreGState()
}

func drawCross(_ ctx: CGContext, _ canvasHeight: CGFloat, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ color: CGColor, _ width: CGFloat) {
    drawTopLine(ctx, canvasHeight, [(x - size, y - size), (x + size, y + size)], color, width)
    drawTopLine(ctx, canvasHeight, [(x - size, y + size), (x + size, y - size)], color, width)
}

func drawDot(_ ctx: CGContext, _ canvasHeight: CGFloat, _ x: CGFloat, _ y: CGFloat, _ radius: CGFloat, _ color: CGColor) {
    drawTopRect(ctx, canvasHeight, CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2), color)
    ctx.saveGState()
    ctx.setFillColor(color)
    ctx.fillEllipse(in: topRect(canvasHeight, x - radius, y - radius, radius * 2, radius * 2))
    ctx.restoreGState()
}

func drawObservationField(_ ctx: CGContext, _ canvasHeight: CGFloat, _ scale: CGFloat, _ originX: CGFloat, _ originY: CGFloat) {
    let black = blackColor(0.68)
    let blue = blueColor()
    let circles: [(CGFloat, CGFloat)] = [(0,40),(70,0),(160,-20),(250,20),(290,90),(260,160),(200,230),(140,300)]
    let ticks: [(CGFloat, CGFloat)] = [(30,80),(120,10),(230,60),(280,130),(170,280),(110,350)]
    let crosses: [(CGFloat, CGFloat)] = [(90,70),(180,0),(270,60),(240,205),(180,330),(80,400)]
    for p in circles { drawCircle(ctx, canvasHeight, originX + p.0 * scale, originY + p.1 * scale, 7 * scale, black, 2 * scale) }
    for p in ticks { drawTopLine(ctx, canvasHeight, [(originX + (p.0 - 9) * scale, originY + (p.1 + 4) * scale), (originX + (p.0 + 9) * scale, originY + (p.1 - 4) * scale)], black, 2 * scale) }
    for p in crosses { drawCross(ctx, canvasHeight, originX + p.0 * scale, originY + p.1 * scale, 5 * scale, black, 1.8 * scale) }
    for p in [(200.0,50.0),(250.0,180.0),(150.0,320.0)] { drawDot(ctx, canvasHeight, originX + p.0 * scale, originY + p.1 * scale, 5 * scale, blue) }
}

func drawProjectTop(_ ctx: CGContext, _ canvasHeight: CGFloat, _ projects: CGImage, _ top: CGFloat, _ height: CGFloat, _ width: CGFloat) {
    let sourceHeight = CGFloat(projects.height) * (width / CGFloat(projects.width))
    ctx.saveGState()
    ctx.clip(to: topRect(canvasHeight, 0, top, width, height))
    drawTopImage(ctx, projects, canvasHeight, 0, top, width, sourceHeight)
    ctx.restoreGState()
}

func composeDesktop() {
    let W: CGFloat = 1536, H: CGFloat = 3072
    let ctx = makeContext(Int(W), Int(H))
    let base = loadImage(desktopBase), role = loadImage(approvedRole), projects = loadImage(approvedProjects)
    drawTopImage(ctx, base, H, 0, 0, W, H)

    // Approved Role crop, with the legacy right-side CTA masked before the new bridge.
    drawTopImage(ctx, role, H, 0, 0, W, 820)
    // Restore the generated paper field over the legacy CTA/Q area so no hard mask edge is visible.
    drawTopCrop(ctx, base, H, CGRect(x: 1180, y: 250, width: 356, height: 570), 1180, 250, 356, 570)
    drawTopBezier(ctx, H, CGPoint(x: 1250, y: 770), CGPoint(x: 1310, y: 850), CGPoint(x: 1180, y: 980), CGPoint(x: 1040, y: 1130), blueColor(), 5)
    drawTopBezier(ctx, H, CGPoint(x: 1040, y: 1130), CGPoint(x: 830, y: 1300), CGPoint(x: 900, y: 1540), CGPoint(x: 875, y: 1690), blueColor(), 5)

    // About section: controlled editorial placeholders, no device frames.
    drawTextTop(ctx, H, "判断，如何落地？", 110, 930, 56, blackColor())
    drawTextTop(ctx, H, "让判断在真实世界里成立。", 110, 1030, 70, blackColor())
    let rule = blackColor(0.25)
    drawTopLine(ctx, H, [(110, 1160), (690, 1160)], rule, 2)
    drawTopLine(ctx, H, [(110, 1200), (620, 1200)], rule, 2)
    drawTopLine(ctx, H, [(110, 1240), (550, 1240)], rule, 2)
    drawTopLine(ctx, H, [(850, 1160), (1430, 1160)], rule, 2)
    drawTopLine(ctx, H, [(850, 1200), (1360, 1200)], rule, 2)
    drawTopLine(ctx, H, [(850, 1240), (1290, 1240)], rule, 2)
    drawTopLine(ctx, H, [(850, 1320), (1430, 1320)], rule, 2)
    drawTopLine(ctx, H, [(850, 1360), (1360, 1360)], rule, 2)

    // Approved Projects entrance begins only after About.
    drawProjectTop(ctx, H, projects, 1700, 630, W)
    drawTopRect(ctx, H, CGRect(x: 0, y: 2330, width: W, height: 96), paperColor())
    drawTopLine(ctx, H, [(110, 2378), (1426, 2378)], blackColor(0.22), 1.5)

    // Final invitation: exact text is rendered here, independent of image-gen text.
    drawTopRect(ctx, H, CGRect(x: 0, y: 2426, width: W, height: 646), paperColor())
    drawTextTop(ctx, H, "下一段经历，", 130, 2570, 72, blackColor())
    let blueText = "我们一起"
    drawTextTop(ctx, H, blueText, 130, 2670, 80, blueColor())
    drawTextTop(ctx, H, "创造？", 130 + textWidth(blueText, 80) + 6, 2670, 80, blackColor())
    drawObservationField(ctx, H, 1.0, 1120, 2580)
    savePNG(ctx.makeImage()!, desktopOut)
}

func composeMobile() {
    let W: CGFloat = 750, H: CGFloat = 2400
    let ctx = makeContext(Int(W), Int(H))
    let base = loadImage(mobileBase), role = loadImage(approvedRole), projects = loadImage(approvedProjects)
    drawTopImage(ctx, base, H, 0, 0, W, H)

    // Mobile Role ending: a crop of the approved person / cockpit / NIO area.
    let roleCrop = role.cropping(to: CGRect(x: 720, y: 170, width: 951, height: 771))!
    drawTopImage(ctx, roleCrop, H, 0, 0, W, 620)
    // The mobile crop also contains the legacy right-side CTA; replace only that edge with the paper base.
    drawTopCrop(ctx, base, H, CGRect(x: 330, y: 0, width: 420, height: 620), 330, 0, 420, 620)

    drawTextTop(ctx, H, "判断，如何落地？", 50, 700, 34, blackColor())
    drawTextTop(ctx, H, "让判断在真实世界里成立。", 50, 770, 42, blackColor())
    drawTopLine(ctx, H, [(50, 900), (310, 900)], blackColor(0.23), 1.5)
    drawTopLine(ctx, H, [(50, 935), (280, 935)], blackColor(0.23), 1.5)
    drawTopLine(ctx, H, [(420, 900), (700, 900)], blackColor(0.23), 1.5)
    drawTopLine(ctx, H, [(420, 935), (660, 935)], blackColor(0.23), 1.5)
    drawTopBezier(ctx, H, CGPoint(x: 565, y: 650), CGPoint(x: 620, y: 780), CGPoint(x: 420, y: 920), CGPoint(x: 500, y: 1110), blueColor(), 4)
    drawTopBezier(ctx, H, CGPoint(x: 500, y: 1110), CGPoint(x: 560, y: 1240), CGPoint(x: 455, y: 1330), CGPoint(x: 500, y: 1415), blueColor(), 4)

    drawProjectTop(ctx, H, projects, 1420, 390, W)
    drawTopRect(ctx, H, CGRect(x: 0, y: 1810, width: W, height: 60), paperColor())
    drawTopLine(ctx, H, [(50, 1840), (700, 1840)], blackColor(0.22), 1.2)

    // Final invitation keeps the mark field below the copy on mobile.
    drawTopRect(ctx, H, CGRect(x: 0, y: 1870, width: W, height: 530), paperColor())
    drawTextTop(ctx, H, "下一段经历，", 55, 1930, 43, blackColor())
    let blueText = "我们一起"
    drawTextTop(ctx, H, blueText, 55, 1995, 48, blueColor())
    drawTextTop(ctx, H, "创造？", 55 + textWidth(blueText, 48) + 4, 1995, 48, blackColor())
    drawObservationField(ctx, H, 0.68, 90, 2140)
    savePNG(ctx.makeImage()!, mobileOut)
}

composeDesktop()
composeMobile()
