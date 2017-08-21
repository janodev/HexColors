
Xcode plugin to colorize the console output.

![console](https://github.com/j4n0/HexColors/blob/master/sources/docs/console.png?raw=true)

Note that this is not a Xcode extension, but an unofficial plugin. It will only work if you unsign Xcode.

Table of Contents
=================

  * [Usage](#usage)
  * [Installation](#installation)
    * [Unsign Xcode](#unsign-xcode)
    * [Why do I have to unsign Xcode?](#why-do-i-have-to-unsign-xcode)
  * [Troubleshooting](#troubleshooting)
    * [Xcode update](#xcode-update)
    * [Reset Load Bundle](#reset-load-bundle)
  * [How does it work](#how-does-it-work)
    * [The code](#the-code)
    * [How to write a plugin](#how-to-write-a-plugin)
      * [Template](#template)
      * [Spelunking](#spelunking)
      * [Swizzling](#swizzling)
  * [References](#how-does-it-work)

# Usage

To colorize your logs, add a six digit hexadecimal color preffix like this:

```swift
print("#ff0000 a red rose")
print("#00ff00 in the green grass")
```
Or if you need a minimal logging tool to produce the logs you saw at the top, I included [one](https://github.com/j4n0/HexColors/blob/master/Console/Console/Logger.swift) in the example project.

# Installation

**To install it** 
  - Download and compile. The plug-in will copy itself to `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/`.
  - Unsign Xcode (see [how](#unsign-xcode)).
  - Run Xcode. You will be greeted with a dialog warning you of an unofficial plug-in. Choose “Load Bundle”.

**To remove it**
  - Remove the file `~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/HexColors.xcplugin`.


## Unsign Xcode

Clone https://github.com/steakknife/unsign, run make, put the unsign command in the path, close Xcode and do this:
```swift
cd /Applications/Xcode-beta.app/Contents/MacOS
sudo unsign Xcode
sudo mv Xcode Xcode.signed
sudo ln -sf Xcode.unsigned Xcode
```

Because Xcode is no longer signed, Gatekeeper will prevent it from running. There are three ways to solve this:

  - *Disable Gatekeeper*. Go to Security & Privacy > General and click _Allow Apps downloaded from: Anywhere_. If 'Anywhere' doesn’t appear as an option, run `sudo spctl --master-disable` from a terminal and relaunch System Preferences.
  - Or *Open Anyway*. Double click the app, then go to Security & Privacy > General and click Open Anyway.
  - Or *Add an exception*. 
	  - Tag Xcode with an arbitrary string: `spctl --add --label "Unsigned Xcode" /Applications/Xcode-beta.app`
    - Approve all apps with that arbitrary string: `spctl --enable --label "Approved"`

If you ever want to revert to a signed Xcode (don’t do it now!), just change the symbolic link that you created before:
```swift
cd /Applications/Xcode-beta.app/Contents/MacOS
sudo ln -sf Xcode.signed Xcode
```

## Why do I have to unsign Xcode?

This plug-in wouldn’t be possible otherwise.

Official Xcode plug-ins are called “Xcode extensions”. An extension has the following restrictions:

  - It can only work with the file open in the editor.
  - It only has access to the user’s text when invoked by the user.
  - It is sandboxed, signed, and has session entitlements.
  - It runs in its own process.

Why Apple doesn’t provide a real plug-in API? Maybe Xcode is too in flux, or they don’t have the developer resources, or they don’t want you to be distracted with plug-ins. Anyway, it’s disappointing. I love the simplicity of Xcode, but things like console colors are sorely missing.

Another reason for Xcode being signed is that in september 2015 some Chinese sites distributed a Xcode version infected with malware. The next version released was digitally signed to prevent tampering. Since then, third party plug-ins won’t work in the signed Xcode.

# Troubleshooting

## Xcode update

After each update you have to do two things to restore third party plug-ins:
  1. Unsign the new Xcode.
  2. Update the DVTPlugInCompatibilityUUID.

The later is a setting inside the plug-in that says: “this plugin is compatible with the Xcode identified by the given UUID”. Because every Xcode has a new UUID, you can wait for me to update the plug-in, or run the following command in your console yourself:
```
XCODEUUID=`defaults read /Applications/Xcode-beta.app/Contents/Info DVTPlugInCompatibilityUUID`; for f in ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/*; do defaults write "$f/Contents/Info" DVTPlugInCompatibilityUUIDs -array-add $XCODEUUID; done
```

This will update the UUID in all plug-ins installed. Note that I’m using Xcode-beta.app (because I’m nearly always using a beta). Change it to Xcode.app if you are using the official version.

# Reset Load Bundle

When you first start Xcode you are offered to “Load Bundle”: 

![load bundle](https://github.com/j4n0/HexColors/blob/master/sources/docs/load-bundle.png?raw=true)<br/>
If you click Cancel the plug-in won’t load and you won’t be asked again. To reset the dialog, close Xcode and run: 
```bash
xcode=`defaults read com.apple.dt.Xcode | grep PlugIns | tail -1 | awk -F\" '{ print $2 }'`; defaults delete com.apple.dt.Xcode $xcode
```

# How does it work

## The code

This plugin swizzles fixAttributesInRange: to parse an hex color at the beginning and colorize the rest of the line with it. The code is really simple:

  - [HexColorsPlugin.h/m](https://github.com/j4n0/HexColors/blob/master/sources/main/HexColorsPlugin.m) invokes the swizzling.
  - [Swizzle.h/m](https://github.com/j4n0/HexColors/blob/master/sources/main/Swizzle.m) performs the swizzling.
  - [HexColors.swift](https://github.com/j4n0/HexColors/blob/master/sources/main/HexColors.swift) parses the hex color and add it as an attributed string color.
	
## How to write a plugin

The procedure to write a plugin is 
  1. Create a blank plugin using a template.
	2. Once your plugin is running, use it to log all Xcode notifications and explore the view hierarchy.
	3. Once you know what to target, swizzle a class method to add your behaviour.

In this plug-in, I’m swizzling `fixAttributesInRange:` [when DVTTextStorage is inside an IDEConsoleTextView](https://github.com/j4n0/HexColors/blob/master/sources/main/Swizzle.m#L15) to inject my formatting code.

### Template

Most plug-ins are written using [this template](https://github.com/kattrali/Xcode-Plugin-Template). It replicates the private Xcode plugins inside the Xcode package. The code in the template registers an observer for didFinishLaunching, and then runs the code. However, the app lifecycle is irrelevant for this plug-in, so instead, my code rans from the Objective-C [+load method](https://github.com/j4n0/HexColors/blob/master/sources/main/HexPlugin.m#L7). 

Here is the plist. As far as I know you need everything here. 

![console](https://github.com/j4n0/HexColors/blob/master/sources/docs/info-plist.png?raw=true)

### Spelunking

Once your plug-in is working, register for all notifications. I used this code:
```swift
var notificationNames = Set<String>()

func subscribeToAllNotifications(){
    NotificationCenter.default.addObserver(self, selector: #selector(logNotification), name: nil, object: nil)
}

func logNotification(notification: Notification){
    let name = notification.name.rawValue
    if !notificationNames.contains(name){
        notificationNames.insert(name)
        let type = type(of:notification.object)
        NSLog("> NAME: \(name), TYPE: \(type)")
    }
}
```

Now do whatever business you are interested in, and watch the console. Because I’m interested in logging, I log a simple message: NSLog("hello") and watch the notifications. The following seems to be of interest:
```
DVTTextStorageDidEndEditingNotification
NSTextStorageWillProcessEditingNotification
NSTextStorageDidProcessEditingNotification 
NSTextViewDidChangeSelectionNotification
NSTextDidChangeNotification             
NSTextDidEndEditingNotification
```
The name DVTTextStorage suggests it is a subclass of NSTextStorage. Looking up the notification names, it seems that every time I log a message there is a call to NSTextStorage.processEditing. 

After some poking around I see the hierarchy:
```
NSObject
  NSResponder
    NSView
      NSText
        NSTextView
          DVTTextView
            DVTCompletingTextView
              IDEConsoleTextView
```

Surprise, the console is not really a terminal console but a NSTextView. 

### Swizzling

I know what class to target (IDEConsoleTextView), now I have to customize its behaviour. There are several methods I can swizzle to add my code to the original implementation. Long story short: I got it working by swizzling DVTTextStorage, but turns out that the same class is also used in the source code editor. For performance reasons, and because it was royally screwing up syntax highlightning, I needed to target the specific console pane (IDEConsoleTextView). I used this code to gather information:
```swift
func logWindowHierarchy(){
    if let contentView = NSApplication.shared().mainWindow?.contentView {
        logViewHierarchy(view: contentView)
    }
}

func logViewHierarchy(view: NSView){
    NSLog("%@", view.className)
    for v in view.subviews {
        logViewHierarchy(view: v)
    }
}
```

I got 315 hits. Filtering with `| sort | uniq` returned 90 unique view classes. One of them was IDEConsoleTextView. Note that I can’t swizzle instances because method tables are per class, not per instance. Fortunately, it’s possible to check NSTextStorage’s _associatedTextViews to see when it is being used in the console.

```swift
/// Returns true if this attributed string is being printed in the Xcode console.
+(BOOL)isConsole:(id)instance
{
    SEL selector = NSSelectorFromString(@"_associatedTextViews");
    IMP imp = [instance methodForSelector:selector];
    NSMutableArray* (*_associatedTextViews)(id, SEL) = (void *)imp;
    NSMutableArray* array = _associatedTextViews(instance, selector);
    return ([array count] > 0 && [[array[0] className] isEqual: @"IDEConsoleTextView"]);
}
```

References
----------

I learned from these articles:

  - How To Create an Xcode Plugin [1](https://www.raywenderlich.com/94020/creating-an-xcode-plugin-part-1), [2](https://www.raywenderlich.com/97756/creating-an-xcode-plugin-part-2), [3](https://www.raywenderlich.com/104479/creating-an-xcode-plugin-part-3)
  - [Creating an Xcode plugin](https://github.com/zolomatok/Creating-an-Xcode-plugin)
	
I empathize with the images in the second. Dear mother of god indeed. I knew it would take me longer than expected, but it _still_ took me longer than expected. 
