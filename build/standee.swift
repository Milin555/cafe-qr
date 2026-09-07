// Generates the QR and a print-ready A5 standee for one cafe.
// swift build/standee.swift <url> <logo.png> <outdir> <name> <line1> <line2> <hours>
import AppKit
import CoreImage

let a = CommandLine.arguments
guard a.count >= 8 else { print("bad args"); exit(1) }
let (url, logoPath, outDir, name) = (a[1], a[2], a[3], a[4])
let (line1, line2, hours) = (a[5], a[6], a[7])

let cream = NSColor(red:0.984, green:0.973, blue:0.945, alpha:1)
let navy  = NSColor(red:0.137, green:0.129, blue:0.314, alpha:1)
let brass = NSColor(red:0.588, green:0.455, blue:0.184, alpha:1)

// ---- QR, highest error correction so it survives a scuffed table card
func qr(_ s: String, scale: CGFloat) -> NSImage {
  let f = CIFilter(name: "CIQRCodeGenerator")!
  f.setValue(s.data(using: .utf8), forKey: "inputMessage")
  f.setValue("H", forKey: "inputCorrectionLevel")
  let out = f.outputImage!.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
  let rep = NSCIImageRep(ciImage: out)
  let img = NSImage(size: rep.size); img.addRepresentation(rep); return img
}
let qrImg = qr(url, scale: 14)

// standalone PNG for stickers, Instagram, WhatsApp
if let tiff = qrImg.tiffRepresentation, let r = NSBitmapImageRep(data: tiff),
   let png = r.representation(using: .png, properties: [:]) {
  try? png.write(to: URL(fileURLWithPath: outDir + "/qr.png"))
}

// ---- A5 standee
let W: CGFloat = 420, H: CGFloat = 595
var box = CGRect(x: 0, y: 0, width: W, height: H)
let pdf = CGContext(URL(fileURLWithPath: outDir + "/standee-a5.pdf") as CFURL, mediaBox: &box, nil)!
pdf.beginPDFPage(nil)
let ns = NSGraphicsContext(cgContext: pdf, flipped: false)
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns

cream.setFill(); box.fill()

func text(_ s: String, _ font: NSFont, _ color: NSColor, _ kern: CGFloat, centerY y: CGFloat) {
  let p = NSMutableParagraphStyle(); p.alignment = .center
  let at = NSAttributedString(string: s, attributes: [
    .font: font, .foregroundColor: color, .kern: kern, .paragraphStyle: p])
  at.draw(in: CGRect(x: 24, y: y, width: W - 48, height: font.pointSize * 1.6))
}

// logo
if let logo = NSImage(contentsOfFile: logoPath) {
  let lw: CGFloat = 210, lh = lw * (logo.size.height / logo.size.width)
  // the extracted mark is navy with alpha, so it drops straight onto cream
  logo.draw(in: CGRect(x: (W - lw)/2, y: H - 74 - lh, width: lw, height: lh))
}

text("SCAN FOR THE FULL MENU", NSFont(name: "HelveticaNeue-Medium", size: 9.5)!, brass, 3.2, centerY: H - 146)

// brass hairline with a centre diamond
brass.setStroke()
let rule = NSBezierPath(); rule.lineWidth = 0.6
rule.move(to: CGPoint(x: W/2 - 74, y: H - 176)); rule.line(to: CGPoint(x: W/2 - 8, y: H - 176))
rule.move(to: CGPoint(x: W/2 + 8, y: H - 176)); rule.line(to: CGPoint(x: W/2 + 74, y: H - 176))
rule.stroke()
brass.setFill()
let dia = NSBezierPath()
dia.move(to: CGPoint(x: W/2, y: H - 168)); dia.line(to: CGPoint(x: W/2 + 4.5, y: H - 172.5))
dia.line(to: CGPoint(x: W/2, y: H - 177)); dia.line(to: CGPoint(x: W/2 - 4.5, y: H - 172.5))
dia.close(); dia.fill()

// QR on a white card
let qs: CGFloat = 218, qx = (W - qs)/2, qy: CGFloat = 176
let card = CGRect(x: qx - 18, y: qy - 18, width: qs + 36, height: qs + 36)
NSColor.white.setFill()
NSBezierPath(roundedRect: card, xRadius: 10, yRadius: 10).fill()
brass.withAlphaComponent(0.45).setStroke()
let cb = NSBezierPath(roundedRect: card, xRadius: 10, yRadius: 10); cb.lineWidth = 0.8; cb.stroke()
NSGraphicsContext.current?.imageInterpolation = .none   // keep QR modules crisp
qrImg.draw(in: CGRect(x: qx, y: qy, width: qs, height: qs))
NSGraphicsContext.current?.imageInterpolation = .high

text(name, NSFont(name: "Georgia-Bold", size: 21)!, navy, 0.4, centerY: 108)
text(line1, NSFont(name: "HelveticaNeue", size: 9)!, navy.withAlphaComponent(0.72), 0.4, centerY: 84)
text(line2, NSFont(name: "HelveticaNeue", size: 9)!, navy.withAlphaComponent(0.72), 0.4, centerY: 68)
text(hours, NSFont(name: "HelveticaNeue-Medium", size: 8.5)!, brass, 1.9, centerY: 42)

NSGraphicsContext.restoreGraphicsState()
pdf.endPDFPage(); pdf.closePDF()
print("wrote \(outDir)/standee-a5.pdf and qr.png")
