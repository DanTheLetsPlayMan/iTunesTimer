//
//  AppDelegate.swift
//  iTunes Timer
//
//  Created by Daniel Zürrer on 02.06.15.
//  Copyright (c) 2015 Daniel Zuerrer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let menuText = "iTimer"
    var error: NSDictionary?
    
    var timerTime = 60 * 30;
    var counter = 0;
    var timer = NSTimer()
    
    var commandScripts = [String: String]()
    var activeCommand = ""
    
    let iTunesString = "iTunes"
    let VLCString = "VLC"
    let YouTubeString = "YouTube"
    
    
    @IBOutlet weak var timeDisplay: NSMenuItem!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var commandDisplay: NSMenuItem!
    
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
    
    
    
    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
        
    }
    @IBAction func startClicked(sender: AnyObject) {
        timer.invalidate();
        counter = timerTime;
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("changeTitle"), userInfo: nil, repeats: true)
    }
    @IBAction func resetClicked(sender: AnyObject) {
        counter = timerTime;
        timer.invalidate()
        statusItem.title = menuText
    }
    @IBAction func sixtyClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(60)
    }
    @IBAction func fortyFiveClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(45)
    }
    @IBAction func thirtyClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(30)
    }
    @IBAction func fifteenClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(15)
    }
    
    
    
    @IBAction func iTunesClicked(sender: AnyObject) {
        activeCommand = iTunesString
        commandDisplay.title = iTunesString
    }
    @IBAction func VLCClicked(sender: AnyObject) {
        activeCommand = VLCString
        commandDisplay.title = VLCString
    }
    @IBAction func SafariClicked(sender: AnyObject) {
        activeCommand = YouTubeString
        commandDisplay.title = YouTubeString
    }
    
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem.title = menuText
        statusItem.menu = statusMenu
        timeDisplay.title = createTimeString(timerTime)
        addCommandScipts()
        activeCommand = iTunesString
        commandDisplay.title = activeCommand
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func changeTitle() {
        let minutes = counter / 60;
        let seconds = counter-- % 60;
        
        
        if (minutes == 0 && seconds == 0) {
            pausePlayback()
            statusItem.title = menuText
            counter = timerTime;
            timer.invalidate()
            return;
        }
        
        statusItem.title = "Remaining: " + createTimeString(counter)
    }
    
    func pausePlayback() {
        if let scriptObject = NSAppleScript(source: commandScripts[activeCommand]!) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                    print(output.stringValue)
            } else if (error != nil) {
                print("error: \(error)")
            }
        }
        
        print("paused " + activeCommand)
    }
    
    func createTimeString(timeInSeconds: Int) -> String {
        
        let minutes = timeInSeconds / 60;
        let seconds = timeInSeconds % 60;
        
        var secondsString = String(seconds)
        
        if(secondsString.characters.count == 1){
            secondsString = "0" + secondsString;
        }
        
        return String(minutes) + ":" + secondsString;
    }
    
    func changeTimerTime(newTime: Int) {
        timerTime = 60 * newTime;
        timeDisplay.title = createTimeString(timerTime)

    }
    
    func addCommandScipts() {
        commandScripts[iTunesString] = "tell application \"iTunes\" to pause"
        commandScripts[VLCString] = "tell application \"System Events\"" + "\n" +
            "tell application \"VLC\" to activate" + "\n" +
            "key code 47 using {command down}" + "\n" +
            "end tell"
        commandScripts[YouTubeString] =  "tell application \"System Events\"" + "\n" +
            "tell application \"Safari\" to activate" + "\n" +
            "key code 40" + "\n" +
            "end tell"
    }
    
    
}

