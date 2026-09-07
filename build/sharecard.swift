// swift build/sharecard.swift <out> <logo.png> <r,g,b bg> <r,g,b accent> <name> <tagline>
import AppKit
let a=CommandLine.arguments
func col(_ s:String)->NSColor{let p=s.split(separator:",").map{CGFloat(Double($0)!)/255}
  return NSColor(red:p[0],green:p[1],blue:p[2],alpha:1)}
let out=a[1], logoPath=a[2], bg=col(a[3]), accent=col(a[4]), tagline=a[6]
let W:CGFloat=1200, H:CGFloat=630
let img=NSImage(size:NSSize(width:W,height:H)); img.lockFocus()
bg.setFill(); NSRect(x:0,y:0,width:W,height:H).fill()
// same soft ground glow the pages use
if let g=NSGradient(colors:[NSColor(white:1,alpha:0.06),NSColor(white:1,alpha:0)]) {
  g.draw(in:NSRect(x:-200,y:120,width:1600,height:900), relativeCenterPosition:.zero)
}
if let logo=NSImage(contentsOfFile:logoPath) {
  let lw:CGFloat=560, lh=lw*(logo.size.height/logo.size.width)
  NSGraphicsContext.current?.imageInterpolation = .high
  // the marks are dark-ink with alpha; draw them white on the dark card
  let tinted=NSImage(size:NSSize(width:lw,height:lh))
  tinted.lockFocus()
  logo.draw(in:NSRect(x:0,y:0,width:lw,height:lh))
  NSColor.white.set()
  NSRect(x:0,y:0,width:lw,height:lh).fill(using:.sourceAtop)
  tinted.unlockFocus()
  tinted.draw(in:NSRect(x:(W-lw)/2, y:H/2-lh/2+40, width:lw, height:lh))
}
let p=NSMutableParagraphStyle(); p.alignment = .center
NSAttributedString(string:tagline,attributes:[
  .font:NSFont(name:"HelveticaNeue",size:30)!,
  .foregroundColor:accent,.kern:4,.paragraphStyle:p])
  .draw(in:NSRect(x:80,y:H/2-140,width:W-160,height:60))
img.unlockFocus()
let rep=NSBitmapImageRep(data:img.tiffRepresentation!)!
try! rep.representation(using:.jpeg,properties:[.compressionFactor:0.86])!
  .write(to:URL(fileURLWithPath:out))
print("wrote \(out)")
