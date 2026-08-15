import Foundation
import CoreGraphics
import CoreText
import ImageIO

let root = "/Users/runmeng.ma/Desktop/马润萌/portfolio-local-preview"
let v4Desktop = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v4.png"
let v4Mobile = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v4.png"
let noPerson = root + "/assets/illustrations/role/role-overview-artwork-no-person-v4.png"
let desktopOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-longpage-desktop-v5.png"
let mobileOut = root + "/design-assets/generated/styleframes/candidates/portfolio-final-key-sections-mobile-v5.png"

func load(_ path: String) -> CGImage {
    let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    return CGImageSourceCreateImageAtIndex(source, 0, nil)!
}

func makeContext(_ w: Int, _ h: Int) -> CGContext {
    CGContext(data:nil,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,
              space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
}

func paper() -> CGColor { CGColor(red:0.952,green:0.941,blue:0.907,alpha:1) }
func cobalt() -> CGColor { CGColor(red:0.184,green:0.388,blue:0.914,alpha:1) }
func ink(_ alpha: CGFloat = 1) -> CGColor { CGColor(red:0.055,green:0.052,blue:0.047,alpha:alpha) }
func topPoint(_ H: CGFloat, _ p: CGPoint) -> CGPoint { CGPoint(x:p.x,y:H-p.y) }
func topRect(_ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { CGRect(x:x,y:H-y-h,width:w,height:h) }

func save(_ image: CGImage, _ path: String) {
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath:path) as CFURL,"public.png" as CFString,1,nil)!
    CGImageDestinationAddImage(destination,image,nil); CGImageDestinationFinalize(destination)
}

func drawImageTop(_ ctx: CGContext, _ H: CGFloat, _ image: CGImage, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    ctx.draw(image,in:topRect(H,x,y,w,h))
}

func drawCropTop(_ ctx: CGContext, _ H: CGFloat, _ image: CGImage, _ source: CGRect, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    guard let crop = image.cropping(to:source) else { return }
    drawImageTop(ctx,H,crop,x,y,w,h)
}

func paperRect(_ ctx: CGContext, _ H: CGFloat, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
    ctx.saveGState();ctx.setFillColor(paper());ctx.fill(topRect(H,x,y,w,h));ctx.restoreGState()
}

func bezier(_ ctx: CGContext, _ H: CGFloat, _ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint, _ color: CGColor, _ width: CGFloat) {
    let path=CGMutablePath();path.move(to:topPoint(H,a));path.addCurve(to:topPoint(H,d),control1:topPoint(H,b),control2:topPoint(H,c))
    ctx.saveGState();ctx.setStrokeColor(color);ctx.setLineWidth(width);ctx.setLineCap(.round);ctx.addPath(path);ctx.strokePath();ctx.restoreGState()
}

func font(_ size: CGFloat) -> CTFont { CTFontCreateWithName("Songti SC" as CFString,size,nil) }
func line(_ text: String, _ size: CGFloat) -> CTLine {
    let attrs:[NSAttributedString.Key:Any]=[kCTFontAttributeName as NSAttributedString.Key:font(size)]
    return CTLineCreateWithAttributedString(NSAttributedString(string:text,attributes:attrs))
}

func textBox(_ text: String, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat) -> CGRect {
    let width=CGFloat(CTLineGetTypographicBounds(line(text,size),nil,nil,nil))
    return CGRect(x:x-12,y:y-8,width:width+24,height:size*1.25+16)
}

func restore(_ ctx: CGContext, _ H: CGFloat, _ snapshot: CGImage, _ boxes: [CGRect], _ W: CGFloat) {
    for box in boxes {
        ctx.saveGState();ctx.clip(to:topRect(H,box.minX,box.minY,box.width,box.height))
        ctx.draw(snapshot,in:CGRect(x:0,y:0,width:W,height:H));ctx.restoreGState()
    }
}

func eraseDesktopRoute(_ ctx: CGContext, _ H: CGFloat) {
    let p=paper();let w:CGFloat=10
    bezier(ctx,H,CGPoint(x:1498,y:447),CGPoint(x:1500,y:515),CGPoint(x:1470,y:610),CGPoint(x:1432,y:690),p,w)
    bezier(ctx,H,CGPoint(x:1432,y:690),CGPoint(x:1390,y:770),CGPoint(x:1335,y:820),CGPoint(x:1290,y:900),p,w)
    bezier(ctx,H,CGPoint(x:1290,y:900),CGPoint(x:1240,y:980),CGPoint(x:1250,y:1080),CGPoint(x:1235,y:1170),p,w)
    bezier(ctx,H,CGPoint(x:1235,y:1170),CGPoint(x:1215,y:1280),CGPoint(x:1240,y:1380),CGPoint(x:1205,y:1495),p,w)
    bezier(ctx,H,CGPoint(x:1205,y:1495),CGPoint(x:1175,y:1570),CGPoint(x:1170,y:1635),CGPoint(x:1155,y:1685),p,w)
}

func drawDesktopV5() {
    let W:CGFloat=1536,H:CGFloat=3072;let ctx=makeContext(Int(W),Int(H));ctx.draw(load(v4Desktop),in:CGRect(x:0,y:0,width:W,height:H))
    eraseDesktopRoute(ctx,H)
    let snapshot=ctx.makeImage()!
    let boxes=[
        textBox("我会关注",930,1125,24), textBox("用户与场景",930,1195,26), textBox("看见问题发生在哪里",930,1230,18),
        textBox("硬件与约束",930,1300,26), textBox("摊开限制，明确取舍",930,1335,18),
        textBox("规则与协作",930,1405,26), textBox("让方案可执行、可验证",930,1440,18)
    ]
    let blue=cobalt();let w:CGFloat=2.55
    // A: three short, unequal relaxed waves leaving the cockpit anchor.
    bezier(ctx,H,CGPoint(x:1498,y:447),CGPoint(x:1490,y:470),CGPoint(x:1470,y:500),CGPoint(x:1460,y:535),blue,w)
    bezier(ctx,H,CGPoint(x:1460,y:535),CGPoint(x:1455,y:555),CGPoint(x:1470,y:585),CGPoint(x:1480,y:610),blue,w)
    bezier(ctx,H,CGPoint(x:1480,y:610),CGPoint(x:1490,y:630),CGPoint(x:1455,y:675),CGPoint(x:1425,y:700),blue,w)
    // B: one broad, natural left-down sweep.
    bezier(ctx,H,CGPoint(x:1425,y:700),CGPoint(x:1390,y:740),CGPoint(x:1390,y:770),CGPoint(x:1350,y:790),blue,w)
    bezier(ctx,H,CGPoint(x:1350,y:790),CGPoint(x:1310,y:820),CGPoint(x:1315,y:870),CGPoint(x:1285,y:900),blue,w)
    bezier(ctx,H,CGPoint(x:1285,y:900),CGPoint(x:1250,y:930),CGPoint(x:1240,y:990),CGPoint(x:1210,y:1010),blue,w)
    // C: cross the focus column; the exact CTLine bounds are restored from the pre-route snapshot.
    bezier(ctx,H,CGPoint(x:1210,y:1010),CGPoint(x:1160,y:1050),CGPoint(x:1175,y:1090),CGPoint(x:1110,y:1120),blue,w)
    bezier(ctx,H,CGPoint(x:1110,y:1120),CGPoint(x:1040,y:1160),CGPoint(x:1060,y:1230),CGPoint(x:980,y:1260),blue,w)
    bezier(ctx,H,CGPoint(x:980,y:1260),CGPoint(x:930,y:1300),CGPoint(x:960,y:1360),CGPoint(x:900,y:1390),blue,w)
    bezier(ctx,H,CGPoint(x:900,y:1390),CGPoint(x:880,y:1430),CGPoint(x:930,y:1470),CGPoint(x:1010,y:1490),blue,w)
    restore(ctx,H,snapshot,boxes,W)
    // D: reappear below the focus copy and drift left in three small waves before Projects covers it.
    bezier(ctx,H,CGPoint(x:1010,y:1490),CGPoint(x:1070,y:1495),CGPoint(x:1100,y:1505),CGPoint(x:1120,y:1510),blue,w)
    bezier(ctx,H,CGPoint(x:1120,y:1510),CGPoint(x:1160,y:1530),CGPoint(x:1145,y:1550),CGPoint(x:1110,y:1560),blue,w)
    bezier(ctx,H,CGPoint(x:1110,y:1560),CGPoint(x:1080,y:1570),CGPoint(x:1040,y:1595),CGPoint(x:1010,y:1600),blue,w)
    bezier(ctx,H,CGPoint(x:1010,y:1600),CGPoint(x:960,y:1610),CGPoint(x:940,y:1650),CGPoint(x:880,y:1685),blue,w)
    save(ctx.makeImage()!,desktopOut)
}

func eraseMobileRoute(_ ctx: CGContext, _ H: CGFloat) {
    let p=paper();let w:CGFloat=10
    bezier(ctx,H,CGPoint(x:735,y:370),CGPoint(x:737,y:470),CGPoint(x:720,y:560),CGPoint(x:700,y:670),p,w)
    bezier(ctx,H,CGPoint(x:700,y:670),CGPoint(x:680,y:790),CGPoint(x:710,y:920),CGPoint(x:690,y:1050),p,w)
    bezier(ctx,H,CGPoint(x:690,y:1050),CGPoint(x:670,y:1170),CGPoint(x:690,y:1300),CGPoint(x:660,y:1410),p,w)
}

func drawMobileV5() {
    let W:CGFloat=750,H:CGFloat=2400;let ctx=makeContext(Int(W),Int(H));ctx.draw(load(v4Mobile),in:CGRect(x:0,y:0,width:W,height:H))
    // Rebuild only the mobile Role crop; this brings the complete yarn ball into view without the person.
    paperRect(ctx,H,0,0,W,620)
    drawCropTop(ctx,H,load(noPerson),CGRect(x:590,y:0,width:690,height:430),0,20,W,467)
    let attrs:[NSAttributedString.Key:Any]=[kCTFontAttributeName as NSAttributedString.Key:font(22),kCTForegroundColorAttributeName as NSAttributedString.Key:ink()]
    let nio=CTLineCreateWithAttributedString(NSAttributedString(string:"蔚来",attributes:attrs));ctx.textPosition=CGPoint(x:50,y:H-545-22*0.82);CTLineDraw(nio,ctx)
    let subAttrs:[NSAttributedString.Key:Any]=[kCTFontAttributeName as NSAttributedString.Key:font(18),kCTForegroundColorAttributeName as NSAttributedString.Key:ink(0.78)]
    let sub=CTLineCreateWithAttributedString(NSAttributedString(string:"让规则在协作中落地",attributes:subAttrs));ctx.textPosition=CGPoint(x:110,y:H-545-18*0.82);CTLineDraw(sub,ctx)
    eraseMobileRoute(ctx,H)
    let snapshot=ctx.makeImage()!
    let boxes=[
        textBox("现在，我把用户、实物和系统放到同一张桌子上，",50,915,18),
        textBox("从问题发生的地方开始，逐步把方案变成可以验证、",50,946,18),
        textBox("可以交付的东西。",50,977,18),
        textBox("看见问题发生在哪里 · 摊开限制，明确取舍 · 让方案可执行、可验证",50,1260,16)
    ]
    let blue=cobalt();let w:CGFloat=2.55
    // Small, mostly vertical waves; each lateral move stays under 70px.
    bezier(ctx,H,CGPoint(x:720,y:300),CGPoint(x:720,y:340),CGPoint(x:710,y:370),CGPoint(x:700,y:410),blue,w)
    bezier(ctx,H,CGPoint(x:700,y:410),CGPoint(x:690,y:450),CGPoint(x:715,y:490),CGPoint(x:690,y:540),blue,w)
    bezier(ctx,H,CGPoint(x:690,y:540),CGPoint(x:670,y:650),CGPoint(x:690,y:740),CGPoint(x:640,y:800),blue,w)
    bezier(ctx,H,CGPoint(x:640,y:800),CGPoint(x:600,y:850),CGPoint(x:560,y:880),CGPoint(x:530,y:900),blue,w)
    bezier(ctx,H,CGPoint(x:530,y:900),CGPoint(x:500,y:920),CGPoint(x:470,y:945),CGPoint(x:420,y:960),blue,w)
    bezier(ctx,H,CGPoint(x:420,y:960),CGPoint(x:400,y:990),CGPoint(x:430,y:1020),CGPoint(x:450,y:1040),blue,w)
    bezier(ctx,H,CGPoint(x:450,y:1040),CGPoint(x:430,y:1110),CGPoint(x:450,y:1160),CGPoint(x:430,y:1210),blue,w)
    bezier(ctx,H,CGPoint(x:430,y:1210),CGPoint(x:410,y:1270),CGPoint(x:450,y:1320),CGPoint(x:460,y:1410),blue,w)
    restore(ctx,H,snapshot,boxes,W)
    save(ctx.makeImage()!,mobileOut)
}

drawDesktopV5()
drawMobileV5()
