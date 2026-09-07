// Square tab icon: the cafe's initial on its own ground.
import AppKit
let a=CommandLine.arguments
let out=a[1], letter=a[2], fontName=a[3]
func col(_ s:String)->NSColor{ let p=s.split(separator:",").map{CGFloat(Double($0)!)/255}
  return NSColor(red:p[0],green:p[1],blue:p[2],alpha:1) }
let bg=col(a[4]), ink=col(a[5])
let S: CGFloat = 512
let img=NSImage(size:NSSize(width:S,height:S)); img.lockFocus()
bg.setFill(); NSBezierPath(roundedRect:NSRect(x:0,y:0,width:S,height:S),xRadius:96,yRadius:96).fill()
let f=NSFont(name:fontName,size:300) ?? NSFont.boldSystemFont(ofSize:300)
let at=NSAttributedString(string:letter,attributes:[.font:f,.foregroundColor:ink])
let sz=at.size()
at.draw(at:NSPoint(x:(S-sz.width)/2, y:(S-sz.height)/2 - 8))
img.unlockFocus()
let r=NSBitmapImageRep(data:img.tiffRepresentation!)!
try! r.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:out))
print("wrote \(out)")
