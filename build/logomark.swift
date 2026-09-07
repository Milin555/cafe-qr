// Draws the Cafe Beats mark: a cup inside a headphone arc, plus the wordmark.
import AppKit
let out = CommandLine.arguments[1]
let W: CGFloat = 800, H: CGFloat = 250
let cyan = NSColor(red:0.435, green:0.827, blue:0.910, alpha:1)
let cream = NSColor(red:0.976, green:0.973, blue:0.957, alpha:1)

let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()
NSColor.clear.set(); NSRect(x:0,y:0,width:W,height:H).fill()

func draw(_ s: String, _ f: NSFont, _ c: NSColor, _ kern: CGFloat, _ x: CGFloat, _ y: CGFloat) {
  NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: c, .kern: kern])
    .draw(at: NSPoint(x: x, y: y))
}
let script = NSFont(name: "SnellRoundhand-Bold", size: 165) ?? NSFont.boldSystemFont(ofSize: 150)
draw(NAME, script, cream, 0, 26, 52)
draw("RESTAURANT", NSFont(name: "HelveticaNeue-Medium", size: 34)!, cyan, 18, 250, 12)

img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
