// Draws text containing ANSI color codes into a PNG, the way a terminal draws it.
//
// Usage: ansi-to-png <input> <output.png> <font-name> <font-size> <columns> <background> <foreground>
//
// The text is laid out on a grid of character cells. Each cell's background fills the whole cell,
// so neighboring backgrounds meet without seams. The Powerline glyphs U+E0B0, U+E0B2, U+E0B4, and
// U+E0B6 are drawn as shapes that fill their cell exactly, as iTerm2 does with "Draw Powerline
// Glyphs" turned on. Every other character is drawn by Core Text, which falls back to another font
// for a character the chosen font lacks.
//
// Only the SGR codes for 24-bit color, reverse video, and the resets are interpreted. Other escape
// sequences and the zsh prompt wrappers %{ and %} are removed. The image is drawn at twice the
// point size, for high-density displays.
import AppKit
import CoreText

/// One character cell: the character drawn in it and its colors.
struct Cell {
    var text: String
    var foreground: CGColor
    var background: CGColor?
}

/// Parses a color written as #RRGGBB.
func parseHex(_ hex: String) -> CGColor {
    let value = Int(hex.dropFirst(), radix: 16) ?? 0
    return CGColor(srgbRed: CGFloat((value >> 16) & 0xFF) / 255, green: CGFloat((value >> 8) & 0xFF) / 255,
                   blue: CGFloat(value & 0xFF) / 255, alpha: 1)
}

/// Splits ANSI text into lines of cells, applying the SGR codes it understands.
func parse(_ raw: String, defaultForeground: CGColor) -> [[Cell]] {
    var text = raw.replacingOccurrences(of: "%{", with: "").replacingOccurrences(of: "%}", with: "")
    text = text.replacingOccurrences(of: "\u{1B}\\][^\u{07}]*\u{07}", with: "", options: .regularExpression)
    var lines: [[Cell]] = [[]]
    var foreground: CGColor? = nil
    var background: CGColor? = nil
    var reverse = false
    let chars = Array(text)
    var i = 0
    while i < chars.count {
        let c = chars[i]
        if c == "\u{1B}" && i + 1 < chars.count && chars[i + 1] == "[" {
            // 1: Read one CSI sequence. Only SGR, which ends in "m", changes anything.
            var j = i + 2
            while j < chars.count && !(chars[j].isLetter) { j += 1 }
            if j < chars.count && chars[j] == "m" {
                let codes = String(chars[(i + 2)..<j]).split(separator: ";", omittingEmptySubsequences: false)
                    .map { Int($0) ?? 0 }
                var k = 0
                while k < codes.count {
                    switch codes[k] {
                    case 0: foreground = nil; background = nil; reverse = false
                    case 7: reverse = true
                    case 27: reverse = false
                    case 39: foreground = nil
                    case 49: background = nil
                    case 38, 48:
                        if k + 4 < codes.count && codes[k + 1] == 2 {
                            let color = CGColor(srgbRed: CGFloat(codes[k + 2]) / 255, green: CGFloat(codes[k + 3]) / 255,
                                                blue: CGFloat(codes[k + 4]) / 255, alpha: 1)
                            if codes[k] == 38 { foreground = color } else { background = color }
                            k += 4
                        }
                    default: break
                    }
                    k += 1
                }
            }
            i = j + 1
            continue
        }
        if c == "\n" {
            lines.append([])
        } else if c != "\r" {
            // 2: Reverse video swaps the colors, standing in the defaults for unset ones.
            var cell = Cell(text: String(c), foreground: foreground ?? defaultForeground, background: background)
            if reverse {
                cell = Cell(text: String(c), foreground: background ?? CGColor(gray: 0, alpha: 1),
                            background: foreground ?? defaultForeground)
            }
            lines[lines.count - 1].append(cell)
        }
        i += 1
    }
    return lines
}

/// Fills a Powerline glyph's shape into its cell, returning false for any other character.
func drawPowerline(_ text: String, in rect: CGRect, context: CGContext) -> Bool {
    guard let scalar = text.unicodeScalars.first, text.unicodeScalars.count == 1 else { return false }
    let path = CGMutablePath()
    switch scalar.value {
    case 0xE0B0:
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    case 0xE0B2:
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    case 0xE0B4:
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                      control1: CGPoint(x: rect.minX + rect.width * 1.33, y: rect.minY),
                      control2: CGPoint(x: rect.minX + rect.width * 1.33, y: rect.maxY))
    case 0xE0B6:
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX - rect.width * 1.33, y: rect.minY),
                      control2: CGPoint(x: rect.maxX - rect.width * 1.33, y: rect.maxY))
    default:
        return false
    }
    path.closeSubpath()
    context.addPath(path)
    context.fillPath()
    return true
}

let args = CommandLine.arguments
guard args.count == 8 else {
    FileHandle.standardError.write("usage: ansi-to-png <input> <output.png> <font-name> <font-size> <columns> <background> <foreground>\n".data(using: .utf8)!)
    exit(2)
}
let scale: CGFloat = 2
guard let font = CTFontCreateWithName(args[3] as CFString, CGFloat(Double(args[4])!) * scale, nil) as CTFont?,
      (CTFontCopyPostScriptName(font) as String) == args[3] else {
    FileHandle.standardError.write("font \(args[3]) is not installed\n".data(using: .utf8)!)
    exit(1)
}
let columns = Int(args[5])!
let pageBackground = parseHex(args[6])
let pageForeground = parseHex(args[7])
let lines = parse(try! String(contentsOfFile: args[1], encoding: .utf8), defaultForeground: pageForeground)

// 3: Size the cells as a terminal does, from the advance of "M" and the font's line metrics.
var glyph = CGGlyph(0)
var m: UniChar = 0x4D
CTFontGetGlyphsForCharacters(font, &m, &glyph, 1)
var advance = CGSize.zero
CTFontGetAdvancesForGlyphs(font, .horizontal, &glyph, &advance, 1)
let cellWidth = ceil(advance.width)
let cellHeight = ceil(CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font))
let baseline = ceil(CTFontGetDescent(font) + CTFontGetLeading(font) / 2)
let margin = cellWidth * 2
let width = Int(CGFloat(columns) * cellWidth + 2 * margin)
let height = Int(CGFloat(lines.count) * cellHeight + 2 * margin)

let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.setFillColor(pageBackground)
context.fill(CGRect(x: 0, y: 0, width: width, height: height))
context.setShouldAntialias(true)

for (row, line) in lines.enumerated() {
    let y = CGFloat(height) - margin - CGFloat(row + 1) * cellHeight
    // 4: Paint every background first, so a glyph that overhangs its cell is not covered.
    for (column, cell) in line.enumerated() where cell.background != nil {
        context.setFillColor(cell.background!)
        context.fill(CGRect(x: margin + CGFloat(column) * cellWidth, y: y, width: cellWidth, height: cellHeight))
    }
    for (column, cell) in line.enumerated() where cell.text != " " {
        let rect = CGRect(x: margin + CGFloat(column) * cellWidth, y: y, width: cellWidth, height: cellHeight)
        context.setFillColor(cell.foreground)
        if drawPowerline(cell.text, in: rect, context: context) { continue }
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): cell.foreground,
        ]
        let ctLine = CTLineCreateWithAttributedString(NSAttributedString(string: cell.text, attributes: attributes))
        context.textPosition = CGPoint(x: rect.minX, y: y + baseline)
        CTLineDraw(ctLine, context)
    }
}

let rep = NSBitmapImageRep(cgImage: context.makeImage()!)
rep.size = NSSize(width: CGFloat(width) / scale, height: CGFloat(height) / scale)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
