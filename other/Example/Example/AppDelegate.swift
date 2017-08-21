
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        logToConsole()
        return true 
    }
}

extension AppDelegate
{
    func logToConsole(){
        Log.trace("000110101010 BZZZZzzzzz 010")
        Log.debug("Too lazy to use breakpoints")
        Log.info("I’m making a sandwich")
        Log.warn("The situation is not ideal")
        Log.error("Go home Xcode, you're drunk")
    }
}
