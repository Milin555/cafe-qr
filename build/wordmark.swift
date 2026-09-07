// Simple typographic wordmark: swift build/wordmark.swift <out> <text> <sub> <font> <size> <r,g,b>
import AppKit
let a=CommandLine.arguments
let out=a[1], name=a[2], sub=a[3], fname=a[4]
let size=CGFloat(Double(a[5])!)
let parts=a[6].split(separator:",").map{ CGFloat(Double($0)!)/255 }
let ink=NSColor(red:parts[0],green:parts[1],blue:parts[2],alpha:1)
let f = NSFont(name: fname, size: size) ?? NSFont.boldSystemFont(ofSize: size)
let kern: CGFloat = 14
let at = NSAttributedString(string: name, attributes:[.font:f,.foregroundColor:ink,.kern:kern])
let sf = NSFont(name:"HelveticaNeue-Medium", size: size*0.26)!
let sat = NSAttributedString(string: sub, attributes:[.font:sf,.foregroundColor:ink.withAlphaComponent(0.72),.kern:size*0.14])
let W = max(at.size().width, sat.size().width) + 40
let H = at.size().height + sat.size().height + 34
let img=NSImage(size:NSSize(width:W,height:H)); img.lockFocus()
NSColor.clear.set(); NSRect(x:0,y:0,width:W,height:H).fill()
at.draw(at: NSPoint(x:(W-at.size().width)/2, y: sat.size().height+22))
sat.draw(at: NSPoint(x:(W-sat.size().width)/2, y: 8))
img.unlockFocus()
let rep=NSBitmapImageRep(data:img.tiffRepresentation!)!
try! rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:out))
print("wrote \(out) \(Int(W))x\(Int(H))")
