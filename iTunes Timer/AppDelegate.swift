//
//  AppDelegate.swift
//  iTunes and Media Timer
//
//  Created by Daniel Zuerrer on 02.06.15.
//  Copyright (c) 2012 Daniel Zuerrer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let menuText = "iTimer"
    var error: NSDictionary?

    var commandScripts = [String: String]()
    var activeCommand = ""
    
    let iTunesString = "iTunes"
    let VLCString = "VLC"
    let YouTubeString = "YouTube"
    let SoundCloudString = "SoundCloud"
    
    
    @IBOutlet weak var timeDisplay: NSMenuItem!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var commandDisplay: NSMenuItem!

    //times

    var availableTimesInMinutes = [15,30,45,60]

    var timerTime = 60 * 30
    var counter = 0;
    var timer = Timer()

    @IBOutlet weak var sixtyMin: NSMenuItem!
    @IBOutlet weak var fortyFiveMin: NSMenuItem!
    @IBOutlet weak var thirtyMin: NSMenuItem!
    @IBOutlet weak var fifteenMin: NSMenuItem!

    
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -1) // NSVariableStatusItemLength
    
    
    
    @IBAction func quitClicked(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
        
    }
    @IBAction func startClicked(_ sender: AnyObject) {
        startTimer()
    }
    @IBAction func resetClicked(_ sender: AnyObject) {
        counter = timerTime;
        timer.invalidate()
        statusItem.title = menuText
    }
    @IBAction func sixtyClicked(_ sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[3])
    }
    @IBAction func fortyFiveClicked(_ sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[2])
    }
    @IBAction func thirtyClicked(_ sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[1])
    }
    @IBAction func fifteenClicked(_ sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[0])
    }
    
    
    
    @IBAction func iTunesClicked(_ sender: AnyObject) {
        renewActiveCommand(iTunesString);
    }
    @IBAction func VLCClicked(_ sender: AnyObject) {
        renewActiveCommand(VLCString);
    }
    @IBAction func SafariClicked(_ sender: AnyObject) {
        renewActiveCommand(YouTubeString);
    }
    
    @IBAction func SoundCloudClicked(_ sender: AnyObject) {
        renewActiveCommand(SoundCloudString);
    }

    func renewActiveCommand(_ newActiveCommand: String){
        activeCommand = newActiveCommand;
        commandDisplay.title = activeCommand

    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        statusItem.title = menuText
        statusItem.menu = statusMenu
        timeDisplay.title = createTimeString(timerTime)
        addCommandScipts()
        activeCommand = iTunesString
        commandDisplay.title = activeCommand

        // set times in menu display
        initialiseMenuTimesDisplay()
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func startTimer() {
        timer.invalidate();
        counter = timerTime;
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(AppDelegate.changeTitle), userInfo: nil, repeats: true)
    }

    // update menu bar title with current remaining time
    func changeTitle() {
        let minutes = counter / 60;
        let seconds = counter % 60;
        counter -= 1;
        
        
        if (minutes == 0 && seconds == 0) {
            pausePlayback()
            statusItem.title = menuText
            counter = timerTime;
            timer.invalidate()
            return;
        }
        
        statusItem.title = "Remaining: " + createTimeString(counter)
    }

    // pause playback of selected application
    func pausePlayback() {
        if let scriptObject = NSAppleScript(source: commandScripts[activeCommand]!) {
            scriptObject.executeAndReturnError(&error)
        }
        
        print("paused " + activeCommand)
    }

    // creating a time string (min:sec) from a time in seconds
    func createTimeString(_ timeInSeconds: Int) -> String {
        
        let minutes = timeInSeconds / 60;
        let seconds = timeInSeconds % 60;
        
        var secondsString = String(seconds)
        
        if(secondsString.characters.count == 1){
            secondsString = "0" + secondsString;
        }
        
        return String(minutes) + ":" + secondsString;
    }

    // update the remaining time of the timer
    func changeTimerTime(_ newTime: Int) {
        timerTime = 60 * newTime;
        timeDisplay.title = createTimeString(timerTime)

    }

    // add apple scripts to pause various apps
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
        commandScripts[SoundCloudString] = "tell application \"System Events\"" + "\n" +
            "tell application \"Safari\" to activate" + "\n" +
            "keystroke space" + "\n" +
            "end tell"
    }

    // initialize menu time list with correct values
    func initialiseMenuTimesDisplay(){
        fifteenMin.title = createTimeString(availableTimesInMinutes[0] * 60)
        thirtyMin.title = createTimeString(availableTimesInMinutes[1] * 60)
        fortyFiveMin.title = createTimeString(availableTimesInMinutes[2] * 60)
        sixtyMin.title = createTimeString(availableTimesInMinutes[3] * 60)
    }
    
   
    
}

