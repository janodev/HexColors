
import UIKit

/// Log level.
public enum LLogLevel: Int, CustomStringConvertible
{
    case trace = 0, debug = 1, info = 2, warn = 3, error = 4, none = 5
    
    public var description: String {
        get {
            switch(self){
            case .debug: return "[DEBUG]"
            case .error: return "[ERROR]"
            case .info:  return " [INFO]"
            case .none:  return ""
            case .trace: return "[TRACE]"
            case .warn : return " [WARN]"
            }
        }
    }
}

public func <(lhs: LLogLevel, rhs: LLogLevel) -> Bool { return lhs.rawValue < rhs.rawValue }
public func >(lhs: LLogLevel, rhs: LLogLevel) -> Bool { return lhs.rawValue > rhs.rawValue }
public func <=(lhs: LLogLevel, rhs: LLogLevel) -> Bool { return lhs.rawValue <= rhs.rawValue }
public func >=(lhs: LLogLevel, rhs: LLogLevel) -> Bool { return lhs.rawValue >= rhs.rawValue }

/// Logger protocol.
public protocol StaticLoggerType
{
    static var threshold: LLogLevel { get set }
    static func trace(_ m: @autoclosure ()->String, _ file: Any?, _ f: String, _ line: UInt)
    static func debug(_ m: @autoclosure ()->String, _ file: Any?, _ f: String, _ line: UInt)
    static func  info(_ m: @autoclosure ()->String, _ file: Any?, _ f: String, _ line: UInt)
    static func  warn(_ m: @autoclosure ()->String, _ file: Any?, _ f: String, _ line: UInt)
    static func error(_ m: @autoclosure ()->String, _ file: Any?, _ f: String, _ line: UInt)
}

/// StaticLoggerType implementation.
public struct Log: StaticLoggerType
{
    public static var threshold = LLogLevel.trace
    
    public static func trace(_ m: @autoclosure ()->String, _ file: Any? = #file, _ f: String = #function, _ line: UInt = #line) {
        if isLoggable(level: .trace) {
            LoggerFormatter.log(m, .trace, file, f, line)
        }
    }
    public static func debug(_ m: @autoclosure ()->String, _ file: Any? = #file, _ f: String = #function, _ line: UInt = #line) {
        if isLoggable(level: .debug) {
            LoggerFormatter.log(m, .debug, file, f, line)
        }
    }
    public static func info(_ m: @autoclosure ()->String, _ file: Any? = #file, _ f: String = #function, _ line: UInt = #line) {
        if isLoggable(level: .info) {
            LoggerFormatter.log(m, .info,  file, f, line)
        }
    }
    public static func warn(_ m: @autoclosure ()->String, _ file: Any? = #file, _ f: String = #function, _ line: UInt = #line) {
        if isLoggable(level: .warn) {
            LoggerFormatter.log(m, .warn,  file, f, line)
        }
    }
    public static func error(_ m: @autoclosure ()->String, _ file: Any? = #file, _ f: String = #function, _ line: UInt = #line) {
        if isLoggable(level: .error) {
            LoggerFormatter.log(m, .error, file, f, line)
        }
    }
    private static func isLoggable(level: LLogLevel)->Bool {
        return threshold.rawValue <= level.rawValue
    }
}

struct LoggerFormatter
{
    fileprivate static var isColorEnabled = true
    
    fileprivate static func log(
        _ message: @autoclosure ()->String,
        _ logLevel: LLogLevel = .debug,
        _ classOrigin: Any? = #file ,
        _ functionOrigin: String = #function,
        _ line: UInt = #line)
    {
        let location = originOf(classOrigin: classOrigin) + "." + functionOrigin
        var msg = ""
        msg = msg + logLevel.description
        msg = msg + " "
        msg = msg + resizeString(string: location, newLength: 40)
        msg = msg + ":"
        msg = msg + StringUtils.padRight(string: "\(line)", toLength: 3)
        msg = msg + " - "
        msg = msg + message()
        
        guard isColorEnabled else {
            print(msg)
            return
        }
        
        colorizedPrint(msg: msg, level: logLevel)
    }
    
    fileprivate static func colorizedPrint(msg: String, level: LLogLevel){
        switch(level){
        case .none: ()
        case .trace: ColorizedPrint.gray(object: msg)
        case .debug: ColorizedPrint.white(object: msg)
        case .info:  ColorizedPrint.green(object: msg)
        case .warn : ColorizedPrint.yellow(object: msg)
        case .error: ColorizedPrint.red(object: msg)
        }
    }
    
    fileprivate static func originOf(classOrigin: Any?) -> String
    {
        var origin: String?
        if let classOrigin = classOrigin as? String {
            origin = NSURL(fileURLWithPath: classOrigin).deletingPathExtension!.lastPathComponent
        } else if let any = classOrigin {
            if let clazz = object_getClass(any as AnyObject) {
                let className = NSStringFromClass(clazz)
                origin = (className as NSString).components(separatedBy: ".").last
            } else {
                origin = ""
            }
        }
        return origin!
    }
    
    fileprivate static func resizeString(string: String, newLength: Int) -> String
    {
        let length = string.characters.count
        if length < newLength {
            return StringUtils.padLeft(string: string, toLength: newLength)
        } else {
            let s = StringUtils.truncateTail(string: string, toLength: newLength)
            return StringUtils.replaceLastCharacter(string: s, character: "…")
        }
    }
}


struct ColorizedPrint
{   
    static func red<T>(object: T) {
        print("#ff0000\(object)")
    }
    
    static func yellow<T>(object: T) {
        print("#ffff00\(object)")
    }
    
    static func green<T>(object: T) {
        print("#00ff00\(object)")
    }
    
    static func white<T>(object: T) {
        print("#ffffff\(object)")
    }
    
    static func gray<T>(object: T) {
        print("#646464\(object)")
    }
}
