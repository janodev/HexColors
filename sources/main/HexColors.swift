
import Cocoa

public class HexColors: NSObject
{
    private static let nonHexCharacters = CharacterSet(charactersIn: "1234567890ABCDEFabcdef").inverted
    
    @objc static func colorize(_ storage: NSTextStorage)
    {
        let string = storage.string
        let fullRange = string.startIndex..<string.endIndex
        string.enumerateSubstrings(in: fullRange, options: String.EnumerationOptions.byLines) { (_ substring: String?, _ substringRange: Range<String.Index>, _ enclosingRange: Range<String.Index>, _ stop: inout Bool) in
            colorizeLine(storage, substring, substringRange)
        }
    }
    
    static func colorizeLine(_ storage: NSTextStorage, _ substring: String?, _ substringRange: Range<String.Index>)
    {
        if let line = substring, let prefixRange = HexColors.prefixRange(line)
        {
            let prefix = String(line[prefixRange])
            let rgbString = HexColors.hexDigits(prefix)
            let color = HexColors.color(rgb: rgbString)
            storage.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(substringRange, in: storage.string))
            
            var replacement = String(line.suffix(from: prefix.endIndex))
            replacement = replacement + repeatElement(" ", count: line.characters.count - replacement.characters.count)
            storage.replaceCharacters(in: NSRange(substringRange, in: storage.string), with: replacement)
        }
    }
    
    /// Range of the prefix containing the hex color.
    /// - returns: a range matching "^\\s*#([A-Fa-f0-9]{6})" or nil.
    static func prefixRange(_ string: String) -> Range<String.Index>? {
        return string.range(of: "^\\s*#([A-Fa-f0-9]{6})", options: .regularExpression)
    }
    
    /// Removes blank space and the character #.
    static func hexDigits(_ string: String) -> String {
        return string.trimmingCharacters(in: nonHexCharacters)
    }
    
    /// Returns the NSColor for the given RGB string. Alpha will be 1.
    static func color(rgb: String) -> NSColor {
        let scanner = Scanner(string: rgb)
        var rgbUInt: UInt32 = 0
        scanner.scanHexInt32(&rgbUInt)
        return _color(rgb: rgbUInt)
    }
    
    /// Returns the NSColor for the given RGB string. Alpha will be 1.
    private static func _color(rgb: UInt32) -> NSColor {
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat((rgb >> 0)  & 0xFF) / 255.0
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

