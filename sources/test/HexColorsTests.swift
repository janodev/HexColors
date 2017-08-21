
import Cocoa
import XCTest
@testable import HexColors

class HexColorsTests: XCTestCase
{
    // note: a "valid prefix" is "^\\s*#([A-Fa-f0-9]{6})"
    
    // check the identified prefix in the first parameter is equal to the string passed in the second
    private let checkPrefixRange: (String, String?)->() = { line, expected in
        guard let range = HexColors.prefixRange(line) else {
            XCTAssertEqual(expected, nil);
            return
        }
        let prefix = line[range]
        XCTAssertEqual(String(prefix), expected)
    }
    
    func testPrefix_valid()
    {
        // when passing a string with a valid prefix, the range should match the prefix
        checkPrefixRange("#cafebabe",  "#cafeba")
        checkPrefixRange("#CAFEBABE",  "#CAFEBA")
        checkPrefixRange(" #CAFEBABE", " #CAFEBA")
    }
    
    func testPrefix_invalid()
    {
        // when passing a string with an invalid prefix, the range should be nil
        checkPrefixRange("", nil)
        checkPrefixRange("CAFEBA", nil)
        checkPrefixRange("GGHHII", nil)
        checkPrefixRange("-123456", nil)
        checkPrefixRange("#CAFEB", nil)
    }
    
    func testHexDigits(){
        // when passing a valid prefix, it returns the hex digits
        XCTAssertEqual(HexColors.hexDigits("#cafeba"),  "cafeba")
        XCTAssertEqual(HexColors.hexDigits("#CAFEBA"),  "CAFEBA")
        XCTAssertEqual(HexColors.hexDigits(" #CAFEBA"), "CAFEBA")
    }
    
    func testColor_rgbString(){
        // when passing six hex digits, it returns the color
        let color = HexColors.color(rgb: "ff0000")
        XCTAssertTrue(isEqual(lhs: color, rhs: NSColor.red))
    }
    
    func testColorizeLine()
    {
        _testColorizeLine("#ff0000", "roses are red", NSColor.red)
        _testColorizeLine("#ff0000", "😀", NSColor.red)
    }
    
    func _testColorizeLine(_ prefix: String, _ text: String, _ color: NSColor)
    {
        let string = prefix + text
        
        // when colorizing a line
        let attributedString = NSAttributedString(string: string)
        let storage = NSTextStorage(attributedString: attributedString)
        HexColors.colorizeLine(storage, string, (string.startIndex..<string.endIndex))
        
        // it has the same length
        XCTAssertEqual(storage.string.characters.count, string.characters.count, "length should remain the same")
        
        // it has a color attribute matching the one in the prefix
        var fullRange: NSRange = NSMakeRange(0, storage.string.characters.count)
        guard let color = storage.attribute(NSAttributedStringKey.foregroundColor, at: 0, effectiveRange: &fullRange) as? NSColor else {
            XCTFail("should be a NSColor"); return
        }
        XCTAssertTrue(isEqual(lhs: color, rhs: color), "color should be red")
    }
    
    // -
    
    private func isEqual(lhs: NSColor, rhs: NSColor) -> Bool
    {
        let tolerance: CGFloat = 0.0
        
        var lhsR: CGFloat = 0
        var lhsG: CGFloat = 0
        var lhsB: CGFloat = 0
        var lhsA: CGFloat = 0
        var rhsR: CGFloat = 0
        var rhsG: CGFloat = 0
        var rhsB: CGFloat = 0
        var rhsA: CGFloat = 0
        
        lhs.getRed(&lhsR, green: &lhsG, blue: &lhsB, alpha: &lhsA)
        rhs.getRed(&rhsR, green: &rhsG, blue: &rhsB, alpha: &rhsA)
        
        let redDiff   = fabs(lhsR - rhsR)
        let greenDiff = fabs(lhsG - rhsG)
        let blueDiff  = fabs(lhsB - rhsB)
        let alphaDiff = fabs(lhsA - rhsA)
        
        return
            redDiff <= tolerance
            && greenDiff <= tolerance
            && blueDiff <= tolerance
            && alphaDiff <= tolerance
    }
}


