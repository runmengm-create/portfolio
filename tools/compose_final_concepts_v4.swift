import Foundation
import CoreGraphics
import CoreText
import ImageIO

let root = "/Users/runmeng.ma/Desktop/马润萌/portfolio-local-preview"
let sourceArtworkPath = root + "/assets/illustrations/role/role-overview-artwork.png"
let noPersonPath = root + "/assets/illustrations/role/role-overview-artwork-no-person-v4.png"
let projectsPath = root + "/design-assets/generated/approved/works-open-fields-master-v1.png"
let desktopOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v4.png"
let mobileOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v4.png"

func image(_ path: String) -> CGImage {
    let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(source, 0, nil)!
}

func context(_ w: Int, _ h: Int, _ alpha: CGImageAlphaInfo = .premultipliedLast) -> CGContext {
    CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
              bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: alpha.rawValue)!
}

func save(_ image: CGImage, _ path: String) {
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}

func paper() -> CGColor { CGColor(red: 0.952, green: 0.941, blue: 0.907, alpha: 1) }
func ink(_ alpha: CGFloat = 1) -> CGColor { CGColor(red: 0.055, green: 0.052, blue: 0.047, alpha: alpha) }
func cobalt() -> CGColor { CGColor(red: 0.184, green: 0.388, blue: 0.914, alpha: 1) }

func topRect(_ H: CGFloat, _ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    CGRect(x: x, y: H - top - h, width: w, height: h)
}

func topPoint(_ H: CGFloat, _ p: CGPoint) -> CGPoint { CGPoint(x: p.x, y: H - p.y) }

func font(_ size: CGFloat) -> CTFont { CTFontCreateWithName("Songti SC" as CFString, size, nil) }

struct TextBox { let rect: CGRect }

func lineFor(_ text: String, _ size: CGFloat, _ color: CGColor) -> CTLine {
    let attributes: [NSAttributedString.Key: Any] = [
        kCTFontAttributeName as NSAttributedString.Key: font(size),
        kCTForegroundColorAttributeName as NSAttributedString.Key: color
    ]
    return CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
}

func drawText(_ ctx: CGContext, _ H: CGFloat, _ text: String, _ x: CGFloat, _ top: CGFloat, _ size: CGFloat, _ color: CGColor) -> TextBox {
    let line = lineFor(text, size, color)
    let measured = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    ctx.textPosition = CGPoint(x: x, y: H - top - size * 0.82)
    CTLineDraw(line, ctx)
    return TextBox(rect: CGRect(x: x - 12, y: top - 8, width: measured + 24, height: size * 1.25 + 16))
}

func textWidth(_ text: String, _ size: CGFloat) -> CGFloat {
    CGFloat(CTLineGetTypographicBounds(lineFor(text, size, ink()), nil, nil, nil))
}

func fill(_ ctx: CGContext, _ H: CGFloat, _ rect: CGRect, _ color: CGColor) {
    ctx.saveGState(); ctx.setFillColor(color); ctx.fill(topRect(H, rect.minX, rect.minY, rect.width, rect.height)); ctx.restoreGState()
}

func drawImageTop(_ ctx: CGContext, _ H: CGFloat, _ image: CGImage, _ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    ctx.draw(image, in: topRect(H, x, top, w, h))
}

func drawCropTop(_ ctx: CGContext, _ H: CGFloat, _ image: CGImage, _ source: CGRect, _ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    guard let crop = image.cropping(to: source) else { return }
    drawImageTop(ctx, H, crop, x, top, w, h)
}

func clearTopRect(_ ctx: CGContext, _ H: CGFloat, _ rect: CGRect) {
    ctx.saveGState(); ctx.setBlendMode(.clear); ctx.fill(topRect(H, rect.minX, rect.minY, rect.width, rect.height)); ctx.restoreGState()
}

func clearTopPolygon(_ ctx: CGContext, _ H: CGFloat, _ points: [CGPoint]) {
    let path = CGMutablePath(); path.move(to: topPoint(H, points[0]))
    for point in points.dropFirst() { path.addLine(to: topPoint(H, point)) }
    path.closeSubpath()
    ctx.saveGState(); ctx.setBlendMode(.clear); ctx.addPath(path); ctx.fillPath(); ctx.restoreGState()
}

func drawBezier(_ ctx: CGContext, _ H: CGFloat, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint, _ width: CGFloat = 2.6) {
    let path = CGMutablePath(); path.move(to: topPoint(H, a))
    path.addCurve(to: topPoint(H, d), control1: topPoint(H, b), control2: topPoint(H, c))
    ctx.saveGState(); ctx.setStrokeColor(cobalt()); ctx.setLineWidth(width); ctx.setLineCap(.round)
    ctx.addPath(path); ctx.strokePath(); ctx.restoreGState()
}

func drawLine(_ ctx: CGContext, _ H: CGFloat, _ points: [(CGFloat, CGFloat)], _ color: CGColor, _ width: CGFloat) {
    let path = CGMutablePath()
    for (index, p) in points.enumerated() {
        let point = topPoint(H, CGPoint(x: p.0, y: p.1))
        if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
    }
    ctx.saveGState(); ctx.setStrokeColor(color); ctx.setLineWidth(width); ctx.setLineCap(.round)
    ctx.addPath(path); ctx.strokePath(); ctx.restoreGState()
}

func restoreTextSnapshot(_ ctx: CGContext, _ H: CGFloat, _ snapshot: CGImage, _ boxes: [TextBox]) {
    for box in boxes {
        ctx.saveGState(); ctx.clip(to: topRect(H, box.rect.minX, box.rect.minY, box.rect.width, box.rect.height))
        ctx.draw(snapshot, in: CGRect(x: 0, y: 0, width: H == 3072 ? 1536 : 750, height: H))
        ctx.restoreGState()
    }
}

func projectOpening(_ ctx: CGContext, _ H: CGFloat, _ projects: CGImage, _ top: CGFloat, _ height: CGFloat, _ width: CGFloat) {
    let scaledHeight = CGFloat(projects.height) * width / CGFloat(projects.width)
    ctx.saveGState(); ctx.clip(to: topRect(H, 0, top, width, height))
    drawImageTop(ctx, H, projects, 0, top, width, scaledHeight)
    ctx.restoreGState()
}

func circle(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ radius: CGFloat, _ color: CGColor, _ stroke: CGFloat) {
    ctx.saveGState(); ctx.setStrokeColor(color); ctx.setLineWidth(stroke)
    ctx.strokeEllipse(in: topRect(H, x-radius, y-radius, radius*2, radius*2)); ctx.restoreGState()
}

func cross(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ color: CGColor) {
    drawLine(ctx,H,[(x-size,y-size),(x+size,y+size)],color,1.6)
    drawLine(ctx,H,[(x-size,y+size),(x+size,y-size)],color,1.6)
}

func dot(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ radius: CGFloat, _ color: CGColor) {
    ctx.saveGState(); ctx.setFillColor(color); ctx.fillEllipse(in: topRect(H,x-radius,y-radius,radius*2,radius*2)); ctx.restoreGState()
}

func observation(_ ctx: CGContext, _ H: CGFloat, _ scale: CGFloat, _ ox: CGFloat, _ oy: CGFloat) {
    let c = ink(0.62)
    let circles: [(CGFloat,CGFloat)] = [(0,40),(70,0),(160,-20),(250,20),(290,90),(260,160),(200,230),(140,300)]
    let ticks: [(CGFloat,CGFloat)] = [(30,80),(120,10),(230,60),(280,130),(170,280),(110,350)]
    let crosses: [(CGFloat,CGFloat)] = [(90,70),(180,0),(270,60),(240,205),(180,330),(80,400)]
    for p in circles { circle(ctx,H,ox+p.0*scale,oy+p.1*scale,7*scale,c,1.7*scale) }
    for p in ticks { drawLine(ctx,H,[(ox+(p.0-9)*scale,oy+(p.1+4)*scale),(ox+(p.0+9)*scale,oy+(p.1-4)*scale)],c,1.7*scale) }
    for p in crosses { cross(ctx,H,ox+p.0*scale,oy+p.1*scale,5*scale,c) }
    for p in [(200.0,50.0),(250.0,180.0),(150.0,320.0)] { dot(ctx,H,ox+p.0*scale,oy+p.1*scale,4.6*scale,cobalt()) }
}

func makeNoPersonArtwork() {
    let source = image(sourceArtworkPath)
    let W = source.width, H = source.height
    let ctx = context(W,H)
    ctx.draw(source, in: CGRect(x:0,y:0,width:W,height:H))

    // Clear only the walking figure, bag, shoes and baseline. Other Role pixels remain untouched.
    clearTopPolygon(ctx,CGFloat(H),[CGPoint(x:824,y:42),CGPoint(x:870,y:48),CGPoint(x:891,y:145),CGPoint(x:886,y:242),CGPoint(x:842,y:276),CGPoint(x:792,y:248),CGPoint(x:792,y:128)])
    clearTopPolygon(ctx,CGFloat(H),[CGPoint(x:776,y:224),CGPoint(x:838,y:222),CGPoint(x:838,y:302),CGPoint(x:772,y:302)])
    clearTopPolygon(ctx,CGFloat(H),[CGPoint(x:803,y:245),CGPoint(x:840,y:252),CGPoint(x:806,y:389),CGPoint(x:770,y:390)])
    clearTopPolygon(ctx,CGFloat(H),[CGPoint(x:851,y:245),CGPoint(x:884,y:250),CGPoint(x:948,y:390),CGPoint(x:910,y:394)])
    clearTopPolygon(ctx,CGFloat(H),[CGPoint(x:752,y:378),CGPoint(x:824,y:378),CGPoint(x:850,y:420),CGPoint(x:744,y:420)])
    clearTopPolygon(ctx,CGFloat(H),[CGPoint(x:908,y:378),CGPoint(x:974,y:378),CGPoint(x:987,y:420),CGPoint(x:900,y:420)])
    clearTopRect(ctx,CGFloat(H),CGRect(x:740,y:416,width:250,height:18))

    // A final tight cleanup removes residual hair, fingers, straps, shoe fragments and baseline pixels.
    // It ends before the cockpit shell begins, so cloth/cat/yarn/cockpit pixels remain intact.
    clearTopRect(ctx,CGFloat(H),CGRect(x:740,y:30,width:225,height:405))
    // The source artwork's legacy right-hand route/question mark is outside the cockpit and is not part of V4.
    clearTopRect(ctx,CGFloat(H),CGRect(x:1275,y:0,width:396,height:430))

    // Remove old blue fragments at the cleared figure and rejoin yarn to cockpit with short, uneven Beziers.
    clearTopRect(ctx,CGFloat(H),CGRect(x:724,y:230,width:250,height:85))
    drawBezier(ctx,CGFloat(H),CGPoint(x:716,y:265),CGPoint(x:738,y:247),CGPoint(x:751,y:280),CGPoint(x:774,y:264),3.2)
    drawBezier(ctx,CGFloat(H),CGPoint(x:774,y:264),CGPoint(x:796,y:248),CGPoint(x:816,y:282),CGPoint(x:842,y:269),3.2)
    drawBezier(ctx,CGFloat(H),CGPoint(x:842,y:269),CGPoint(x:864,y:252),CGPoint(x:893,y:284),CGPoint(x:919,y:268),3.2)
    drawBezier(ctx,CGFloat(H),CGPoint(x:919,y:268),CGPoint(x:942,y:252),CGPoint(x:954,y:276),CGPoint(x:977,y:260),3.2)
    save(ctx.makeImage()!,noPersonPath)
}

func desktop() {
    let W: CGFloat = 1536, H: CGFloat = 3072
    let ctx = context(Int(W),Int(H)); fill(ctx,H,CGRect(x:0,y:0,width:W,height:H),paper())
    let artwork = image(noPersonPath), projects = image(projectsPath)
    drawCropTop(ctx,H,artwork,CGRect(x:0,y:0,width:1275,height:430),0,145,W,517)
    var boxes:[TextBox] = []
    boxes.append(drawText(ctx,H,"01",72,48,34,ink()))
    boxes.append(drawText(ctx,H,"ROLE OVERVIEW / 角色概览",135,54,22,ink(0.66)))
    boxes.append(drawText(ctx,H,"把问题拆开，再一起收口。",135,90,48,ink()))
    boxes.append(drawText(ctx,H,"Dickies / 李宁",110,620,22,ink()))
    boxes.append(drawText(ctx,H,"从用户与场景出发",110,652,20,ink(0.82)))
    boxes.append(drawText(ctx,H,"查看经历 ↗",110,684,16,ink(0.58)))
    boxes.append(drawText(ctx,H,"70mai",610,620,22,ink()))
    boxes.append(drawText(ctx,H,"把体验拆进软硬件系统",610,652,20,ink(0.82)))
    boxes.append(drawText(ctx,H,"查看经历 ↗",610,684,16,ink(0.58)))
    boxes.append(drawText(ctx,H,"蔚来",1110,620,22,ink()))
    boxes.append(drawText(ctx,H,"让规则在协作中落地",1110,652,20,ink(0.82)))
    boxes.append(drawText(ctx,H,"查看经历 ↗",1110,684,16,ink(0.58)))

    boxes.append(drawText(ctx,H,"判断，如何落地？",110,930,50,ink()))
    boxes.append(drawText(ctx,H,"让判断在真实世界里成立。",110,1015,66,ink()))
    boxes.append(drawText(ctx,H,"工业设计训练了我观察，产品工作让我学会取舍。",110,1135,30,ink()))
    boxes.append(drawText(ctx,H,"现在，我把用户、实物和系统放到同一张桌子上，",110,1205,22,ink(0.78)))
    boxes.append(drawText(ctx,H,"从问题发生的地方开始，逐步把方案变成可以验证、",110,1242,22,ink(0.78)))
    boxes.append(drawText(ctx,H,"可以交付的东西。",110,1279,22,ink(0.78)))
    boxes.append(drawText(ctx,H,"我会关注",930,1125,24,ink()))
    boxes.append(drawText(ctx,H,"用户与场景",930,1195,26,ink()))
    boxes.append(drawText(ctx,H,"看见问题发生在哪里",930,1230,18,ink(0.7)))
    boxes.append(drawText(ctx,H,"硬件与约束",930,1300,26,ink()))
    boxes.append(drawText(ctx,H,"摊开限制，明确取舍",930,1335,18,ink(0.7)))
    boxes.append(drawText(ctx,H,"规则与协作",930,1405,26,ink()))
    boxes.append(drawText(ctx,H,"让方案可执行、可验证",930,1440,18,ink(0.7)))
    let snapshot = ctx.makeImage()!

    // Relaxed low-frequency cross-section route; it ends before Projects and never enters its pixels.
    drawBezier(ctx,H,CGPoint(x:1498,y:447),CGPoint(x:1500,y:515),CGPoint(x:1470,y:610),CGPoint(x:1432,y:690),2.6)
    drawBezier(ctx,H,CGPoint(x:1432,y:690),CGPoint(x:1390,y:770),CGPoint(x:1335,y:820),CGPoint(x:1290,y:900),2.6)
    drawBezier(ctx,H,CGPoint(x:1290,y:900),CGPoint(x:1240,y:980),CGPoint(x:1250,y:1080),CGPoint(x:1235,y:1170),2.6)
    drawBezier(ctx,H,CGPoint(x:1235,y:1170),CGPoint(x:1215,y:1280),CGPoint(x:1240,y:1380),CGPoint(x:1205,y:1495),2.6)
    drawBezier(ctx,H,CGPoint(x:1205,y:1495),CGPoint(x:1175,y:1570),CGPoint(x:1170,y:1635),CGPoint(x:1155,y:1685),2.6)
    restoreTextSnapshot(ctx,H,snapshot,boxes)

    // Approved Projects is the final overlay for this section.
    projectOpening(ctx,H,projects,1700,630,W)
    fill(ctx,H,CGRect(x:0,y:2330,width:W,height:96),paper())
    drawLine(ctx,H,[(110,2380),(1426,2380)],ink(0.18),1)
    fill(ctx,H,CGRect(x:0,y:2426,width:W,height:646),paper())
    drawText(ctx,H,"下一段经历，",130,2570,72,ink())
    let blue="我们一起"; drawText(ctx,H,blue,130,2670,80,cobalt()); drawText(ctx,H,"创造？",130+textWidth(blue,80)+6,2670,80,ink())
    observation(ctx,H,1.0,1120,2580)
    save(ctx.makeImage()!,desktopOut)
}

func mobile() {
    let W: CGFloat = 750, H: CGFloat = 2400
    let ctx = context(Int(W),Int(H)); fill(ctx,H,CGRect(x:0,y:0,width:W,height:H),paper())
    let artwork = image(noPersonPath), projects = image(projectsPath)
    drawCropTop(ctx,H,artwork,CGRect(x:700,y:0,width:580,height:430),0,20,W,556)
    var boxes:[TextBox] = []
    boxes.append(drawText(ctx,H,"蔚来",50,545,22,ink()))
    boxes.append(drawText(ctx,H,"让规则在协作中落地",110,545,18,ink(0.78)))
    boxes.append(drawText(ctx,H,"判断，如何落地？",50,700,34,ink()))
    boxes.append(drawText(ctx,H,"让判断在真实世界里成立。",50,770,42,ink()))
    boxes.append(drawText(ctx,H,"工业设计训练了我观察，产品工作让我学会取舍。",50,850,23,ink()))
    boxes.append(drawText(ctx,H,"现在，我把用户、实物和系统放到同一张桌子上，",50,915,18,ink(0.76)))
    boxes.append(drawText(ctx,H,"从问题发生的地方开始，逐步把方案变成可以验证、",50,946,18,ink(0.76)))
    boxes.append(drawText(ctx,H,"可以交付的东西。",50,977,18,ink(0.76)))
    boxes.append(drawText(ctx,H,"用户与场景",50,1060,22,ink()))
    boxes.append(drawText(ctx,H,"硬件与约束",50,1135,22,ink()))
    boxes.append(drawText(ctx,H,"规则与协作",50,1210,22,ink()))
    boxes.append(drawText(ctx,H,"看见问题发生在哪里 · 摊开限制，明确取舍 · 让方案可执行、可验证",50,1260,16,ink(0.68)))
    let snapshot = ctx.makeImage()!

    drawBezier(ctx,H,CGPoint(x:735,y:370),CGPoint(x:737,y:470),CGPoint(x:720,y:560),CGPoint(x:700,y:670),2.5)
    drawBezier(ctx,H,CGPoint(x:700,y:670),CGPoint(x:680,y:790),CGPoint(x:710,y:920),CGPoint(x:690,y:1050),2.5)
    drawBezier(ctx,H,CGPoint(x:690,y:1050),CGPoint(x:670,y:1170),CGPoint(x:690,y:1300),CGPoint(x:660,y:1410),2.5)
    restoreTextSnapshot(ctx,H,snapshot,boxes)

    projectOpening(ctx,H,projects,1420,390,W)
    fill(ctx,H,CGRect(x:0,y:1810,width:W,height:60),paper())
    drawLine(ctx,H,[(50,1840),(700,1840)],ink(0.18),1)
    fill(ctx,H,CGRect(x:0,y:1870,width:W,height:530),paper())
    drawText(ctx,H,"下一段经历，",55,1930,43,ink())
    let blue="我们一起"; drawText(ctx,H,blue,55,1995,48,cobalt()); drawText(ctx,H,"创造？",55+textWidth(blue,48)+4,1995,48,ink())
    observation(ctx,H,0.68,90,2140)
    save(ctx.makeImage()!,mobileOut)
}

makeNoPersonArtwork()
desktop()
mobile()
