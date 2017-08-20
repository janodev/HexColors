
import Cocoa
import XCTest
@testable import HexColors

class HexColorsTests: XCTestCase
{
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
        checkPrefixRange("#cafebabe",  "#cafeba")
        checkPrefixRange("#CAFEBABE",  "#CAFEBA")
        checkPrefixRange(" #CAFEBABE", " #CAFEBA")
    }
    
    func testPrefix_invalid()
    {
        checkPrefixRange("", nil)
        checkPrefixRange("CAFEBA", nil)
        checkPrefixRange("GGHHII", nil)
        checkPrefixRange("-123456", nil)
        checkPrefixRange("#CAFEB", nil)
    }
    
    func testHexDigits(){
        XCTAssertEqual(HexColors.hexDigits("#cafeba"),  "cafeba")
        XCTAssertEqual(HexColors.hexDigits("#CAFEBA"),  "CAFEBA")
        XCTAssertEqual(HexColors.hexDigits(" #CAFEBA"), "CAFEBA")
    }
    
    func testColor_rgbString(){
        let color = HexColors.color(rgb: "ff0000")
        XCTAssertTrue(isEqual(lhs: color, rhs: NSColor.red))
    }
    
    func testColorizeLine()
    {
        let prefix = "#ff0000"
        let text = "roses are red"
        let string = prefix + text
        
        let attributedString = NSAttributedString(string: string)
        let storage = NSTextStorage(attributedString: attributedString)
        let substring = storage.string
        let range = substring.startIndex..<substring.endIndex
        HexColors.colorizeLine(storage, substring, range)

        XCTAssertEqual(storage.string.characters.count, string.characters.count, "length should remain the same")

        var fullRange: NSRange = NSMakeRange(0, storage.string.characters.count)
        guard let color = storage.attribute(NSAttributedStringKey.foregroundColor, at: 0, effectiveRange: &fullRange) as? NSColor else {
            XCTFail("should be a NSColor"); return
        }
        XCTAssertTrue(isEqual(lhs: color, rhs: NSColor.red), "color should be red")
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


