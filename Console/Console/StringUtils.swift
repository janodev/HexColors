
import Foundation

public struct StringUtils
{
    public static func padLeft(string: String, toLength newLength: Int, withPad character: Character = " ") -> String {
        return pad(.left, string: string, toLength: newLength, withPad: character)
    }
    
    public static func padRight(string: String, toLength newLength: Int, withPad character: Character = " ") -> String {
        return pad(.right, string: string, toLength: newLength, withPad: character)
    }
    
    public static func replaceLastCharacter(string: String, character: Character) -> String {
        return replaceCharacter(string: string, character: character, side: Side.right)
    }

    public static func truncateTail(string: String, toLength newLength: Int) -> String {
        return truncate(.right, string: string, toLength: newLength)
    }
    
    fileprivate enum Side { case left, right }
    
    fileprivate static func pad(_ side: Side, string: String, toLength newLength: Int, withPad character: Character = " ") -> String
    {
        let length = string.characters.count
        guard newLength > length else {
            return string
        }
        let spaces = String(repeatElement(character, count: newLength - length))
        return side == .left ? spaces + string : string + spaces
    }
    
    fileprivate static func truncate(_ dropSide: Side, string: String, toLength newLength: Int) -> String
    {
        let length = string.characters.count
        guard newLength < length else {
            return string
        }
        if dropSide == .left {
            let offset = -1 * newLength + 1
            let index = string.index(string.endIndex, offsetBy: offset)
            return "…" + String(string.suffix(from: index))
        } else {
            let offset = newLength - 1
            let index = string.index(string.startIndex, offsetBy: offset)
            return String(string.prefix(upTo: index)) + "…"
        }
    }
    
    fileprivate static func replaceCharacter(string: String, character: Character, side: Side) -> String
    {
        guard string.characters.count > 1 else {
            return string
        }
        var s = string
        switch side {
        case .left:
            s.remove(at: s.startIndex)
            return "\(character)\(s)"
        case .right:
            s.remove(at: s.index(before: s.endIndex))
            return "\(s)\(character)"
        }
    }
    
}
