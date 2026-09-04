import Foundation
import CoreGraphics
import CoreText
import ImageIO

let root = "/Users/runmeng.ma/Desktop/马润萌/portfolio-local-preview"
let roleArtworkPath = root + "/assets/illustrations/role/role-overview-artwork.png"
let approvedProjectsPath = root + "/design-assets/generated/approved/works-open-fields-master-v1.png"
let desktopOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v2.png"
let mobileOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v2.png"

func loadImage(_ path: String) -> CGImage {
    let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(source, 0, nil)!
}

func makeContext(_ width: Int, _ height: Int) -> CGContext {
    CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
              bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}

func savePNG(_ image: CGImage, _ path: String) {
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}

func topRect(_ H: CGFloat, _ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    CGRect(x: x, y: H - top - h, width: w, height: h)
}

func paper() -> CGColor { CGColor(red: 0.952, green: 0.941, blue: 0.907, alpha: 1) }
func ink(_ a: CGFloat = 1) -> CGColor { CGColor(red: 0.055, green: 0.052, blue: 0.047, alpha: a) }
func cobalt() -> CGColor { CGColor(red: 0.184, green: 0.388, blue: 0.914, alpha: 1) }

func font(_ size: CGFloat) -> CTFont {
    CTFontCreateWithName("Songti SC" as CFString, size, nil)
}

func drawText(_ ctx: CGContext, _ H: CGFloat, _ text: String, _ x: CGFloat, _ top: CGFloat, _ size: CGFloat, _ color: CGColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        kCTFontAttributeName as NSAttributedString.Key: font(size),
        kCTForegroundColorAttributeName as NSAttributedString.Key: color
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    ctx.textPosition = CGPoint(x: x, y: H - top - size * 0.82)
    CTLineDraw(line, ctx)
}

func width(_ text: String, _ size: CGFloat) -> CGFloat {
    let attrs: [NSAttributedString.Key: Any] = [kCTFontAttributeName as NSAttributedString.Key: font(size)]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    return CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
}

func drawImageTop(_ ctx: CGContext, _ H: CGFloat, _ image: CGImage, _ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    ctx.draw(image, in: topRect(H, x, top, w, h))
}

func drawCropTop(_ ctx: CGContext, _ H: CGFloat, _ image: CGImage, _ source: CGRect, _ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    guard let crop = image.cropping(to: source) else { return }
    drawImageTop(ctx, H, crop, x, top, w, h)
}

func drawLine(_ ctx: CGContext, _ H: CGFloat, _ points: [(CGFloat, CGFloat)], _ color: CGColor, _ lineWidth: CGFloat) {
    let path = CGMutablePath()
    for (i, p) in points.enumerated() {
        let q = CGPoint(x: p.0, y: H - p.1)
        if i == 0 { path.move(to: q) } else { path.addLine(to: q) }
    }
    ctx.saveGState()
    ctx.setStrokeColor(color); ctx.setLineWidth(lineWidth); ctx.setLineCap(.round)
    ctx.addPath(path); ctx.strokePath(); ctx.restoreGState()
}

func drawBezier(_ ctx: CGContext, _ H: CGFloat, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint, _ color: CGColor, _ lineWidth: CGFloat) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: a.x, y: H - a.y))
    path.addCurve(to: CGPoint(x: d.x, y: H - d.y),
                  control1: CGPoint(x: b.x, y: H - b.y), control2: CGPoint(x: c.x, y: H - c.y))
    ctx.saveGState()
    ctx.setStrokeColor(color); ctx.setLineWidth(lineWidth); ctx.setLineCap(.round)
    ctx.addPath(path); ctx.strokePath(); ctx.restoreGState()
}

func drawProjectOpening(_ ctx: CGContext, _ H: CGFloat, _ projects: CGImage, _ top: CGFloat, _ h: CGFloat, _ w: CGFloat) {
    let cropH = CGFloat(projects.height) * w / CGFloat(projects.width)
    ctx.saveGState()
    ctx.clip(to: topRect(H, 0, top, w, h))
    drawImageTop(ctx, H, projects, 0, top, w, cropH)
    ctx.restoreGState()
}

func drawCircle(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: CGColor, _ stroke: CGFloat) {
    ctx.saveGState(); ctx.setStrokeColor(color); ctx.setLineWidth(stroke)
    ctx.strokeEllipse(in: topRect(H, x-r, y-r, r*2, r*2)); ctx.restoreGState()
}

func drawCross(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ color: CGColor) {
    drawLine(ctx, H, [(x-s,y-s),(x+s,y+s)], color, 1.6)
    drawLine(ctx, H, [(x-s,y+s),(x+s,y-s)], color, 1.6)
}

func drawDot(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ color: CGColor) {
    ctx.saveGState(); ctx.setFillColor(color)
    ctx.fillEllipse(in: topRect(H, x-r, y-r, r*2, r*2)); ctx.restoreGState()
}

func drawObservation(_ ctx: CGContext, _ H: CGFloat, _ scale: CGFloat, _ ox: CGFloat, _ oy: CGFloat) {
    let c = ink(0.62)
    let circles: [(CGFloat,CGFloat)] = [(0,40),(70,0),(160,-20),(250,20),(290,90),(260,160),(200,230),(140,300)]
    let ticks: [(CGFloat,CGFloat)] = [(30,80),(120,10),(230,60),(280,130),(170,280),(110,350)]
    let crosses: [(CGFloat,CGFloat)] = [(90,70),(180,0),(270,60),(240,205),(180,330),(80,400)]
    for p in circles { drawCircle(ctx,H,ox+p.0*scale,oy+p.1*scale,7*scale,c,1.7*scale) }
    for p in ticks { drawLine(ctx,H,[(ox+(p.0-9)*scale,oy+(p.1+4)*scale),(ox+(p.0+9)*scale,oy+(p.1-4)*scale)],c,1.7*scale) }
    for p in crosses { drawCross(ctx,H,ox+p.0*scale,oy+p.1*scale,5*scale,c) }
    for p in [(200.0,50.0),(250.0,180.0),(150.0,320.0)] { drawDot(ctx,H,ox+p.0*scale,oy+p.1*scale,4.6*scale,cobalt()) }
}

func fill(_ ctx: CGContext, _ H: CGFloat, _ rect: CGRect, _ color: CGColor) {
    ctx.saveGState(); ctx.setFillColor(color); ctx.fill(topRect(H,rect.minX,rect.minY,rect.width,rect.height)); ctx.restoreGState()
}

func desktop() {
    let W: CGFloat = 1536, H: CGFloat = 3072
    let ctx = makeContext(Int(W),Int(H)); fill(ctx,H,CGRect(x:0,y:0,width:W,height:H),paper())
    let artwork = loadImage(roleArtworkPath), projects = loadImage(approvedProjectsPath)

    // Transparent approved-derived Role artwork. Crop before the old question mark.
    drawCropTop(ctx,H,artwork,CGRect(x:0,y:0,width:1380,height:430),0,145,W,498)
    drawText(ctx,H,"01",72,48,34,ink())
    drawText(ctx,H,"ROLE OVERVIEW / 角色概览",135,54,22,ink(0.66))
    drawText(ctx,H,"把问题拆开，再一起收口。",135,90,48,ink())
    drawText(ctx,H,"Dickies / 李宁",110,620,22,ink())
    drawText(ctx,H,"从用户与场景出发",110,652,20,ink(0.82))
    drawText(ctx,H,"查看经历 ↗",110,684,16,ink(0.58))
    drawText(ctx,H,"70mai",610,620,22,ink())
    drawText(ctx,H,"把体验拆进软硬件系统",610,652,20,ink(0.82))
    drawText(ctx,H,"查看经历 ↗",610,684,16,ink(0.58))
    drawText(ctx,H,"蔚来",1110,620,22,ink())
    drawText(ctx,H,"让规则在协作中落地",1110,652,20,ink(0.82))
    drawText(ctx,H,"查看经历 ↗",1110,684,16,ink(0.58))

    // One unified cobalt line: it starts at the cockpit's right edge and gently descends.
    drawBezier(ctx,H,CGPoint(x:1450,y:390),CGPoint(x:1490,y:500),CGPoint(x:1320,y:720),CGPoint(x:1240,y:860),cobalt(),2.6)
    drawBezier(ctx,H,CGPoint(x:1240,y:860),CGPoint(x:1090,y:1040),CGPoint(x:1100,y:1320),CGPoint(x:1040,y:1690),cobalt(),2.6)

    // Real About copy from index.html; no placeholder cards, rules, or fake body lines.
    drawText(ctx,H,"判断，如何落地？",110,930,50,ink())
    drawText(ctx,H,"让判断在真实世界里成立。",110,1015,66,ink())
    drawText(ctx,H,"工业设计训练了我观察，产品工作让我学会取舍。",110,1135,30,ink())
    drawText(ctx,H,"现在，我把用户、实物和系统放到同一张桌子上，",110,1205,22,ink(0.78))
    drawText(ctx,H,"从问题发生的地方开始，逐步把方案变成可以验证、",110,1242,22,ink(0.78))
    drawText(ctx,H,"可以交付的东西。",110,1279,22,ink(0.78))
    drawText(ctx,H,"我会关注",930,1125,24,ink())
    drawText(ctx,H,"用户与场景",930,1195,26,ink())
    drawText(ctx,H,"看见问题发生在哪里",930,1230,18,ink(0.7))
    drawText(ctx,H,"硬件与约束",930,1300,26,ink())
    drawText(ctx,H,"摊开限制，明确取舍",930,1335,18,ink(0.7))
    drawText(ctx,H,"规则与协作",930,1405,26,ink())
    drawText(ctx,H,"让方案可执行、可验证",930,1440,18,ink(0.7))

    drawProjectOpening(ctx,H,projects,1700,630,W)
    fill(ctx,H,CGRect(x:0,y:2330,width:W,height:96),paper())
    drawLine(ctx,H,[(110,2380),(1426,2380)],ink(0.18),1)
    fill(ctx,H,CGRect(x:0,y:2426,width:W,height:646),paper())
    drawText(ctx,H,"下一段经历，",130,2570,72,ink())
    let blue = "我们一起"; drawText(ctx,H,blue,130,2670,80,cobalt())
    drawText(ctx,H,"创造？",130+width(blue,80)+6,2670,80,ink())
    drawObservation(ctx,H,1.0,1120,2580)
    savePNG(ctx.makeImage()!,desktopOut)
}

func mobile() {
    let W: CGFloat = 750, H: CGFloat = 2400
    let ctx = makeContext(Int(W),Int(H)); fill(ctx,H,CGRect(x:0,y:0,width:W,height:H),paper())
    let artwork = loadImage(roleArtworkPath), projects = loadImage(approvedProjectsPath)

    // Approved-derived mobile Role ending, cropped before the source question mark.
    drawCropTop(ctx,H,artwork,CGRect(x:700,y:0,width:660,height:430),0,42,W,487)
    drawText(ctx,H,"蔚来",50,545,22,ink())
    drawText(ctx,H,"让规则在协作中落地",110,545,18,ink(0.78))

    drawText(ctx,H,"判断，如何落地？",50,700,34,ink())
    drawText(ctx,H,"让判断在真实世界里成立。",50,770,42,ink())
    drawText(ctx,H,"工业设计训练了我观察，产品工作让我学会取舍。",50,850,23,ink())
    drawText(ctx,H,"现在，我把用户、实物和系统放到同一张桌子上，",50,915,18,ink(0.76))
    drawText(ctx,H,"从问题发生的地方开始，逐步把方案变成可以验证、",50,946,18,ink(0.76))
    drawText(ctx,H,"可以交付的东西。",50,977,18,ink(0.76))
    drawText(ctx,H,"用户与场景",50,1060,22,ink())
    drawText(ctx,H,"硬件与约束",50,1135,22,ink())
    drawText(ctx,H,"规则与协作",50,1210,22,ink())
    drawText(ctx,H,"看见问题发生在哪里 · 摊开限制，明确取舍 · 让方案可执行、可验证",50,1260,16,ink(0.68))
    drawBezier(ctx,H,CGPoint(x:690,y:470),CGPoint(x:720,y:620),CGPoint(x:560,y:790),CGPoint(x:610,y:990),cobalt(),2.5)
    drawBezier(ctx,H,CGPoint(x:610,y:990),CGPoint(x:650,y:1130),CGPoint(x:540,y:1270),CGPoint(x:610,y:1420),cobalt(),2.5)

    drawProjectOpening(ctx,H,projects,1420,390,W)
    fill(ctx,H,CGRect(x:0,y:1810,width:W,height:60),paper())
    drawLine(ctx,H,[(50,1840),(700,1840)],ink(0.18),1)
    fill(ctx,H,CGRect(x:0,y:1870,width:W,height:530),paper())
    drawText(ctx,H,"下一段经历，",55,1930,43,ink())
    let blue = "我们一起"; drawText(ctx,H,blue,55,1995,48,cobalt())
    drawText(ctx,H,"创造？",55+width(blue,48)+4,1995,48,ink())
    drawObservation(ctx,H,0.68,90,2140)
    savePNG(ctx.makeImage()!,mobileOut)
}

desktop()
mobile()
