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
    var timer = NSTimer()

    @IBOutlet weak var sixtyMin: NSMenuItem!
    @IBOutlet weak var fortyFiveMin: NSMenuItem!
    @IBOutlet weak var thirtyMin: NSMenuItem!
    @IBOutlet weak var fifteenMin: NSMenuItem!

    
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
    
    
    
    @IBAction func quitClicked(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
        
    }
    @IBAction func startClicked(sender: AnyObject) {
        startTimer()
    }
    @IBAction func resetClicked(sender: AnyObject) {
        counter = timerTime;
        timer.invalidate()
        statusItem.title = menuText
    }
    @IBAction func sixtyClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[3])
    }
    @IBAction func fortyFiveClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[2])
    }
    @IBAction func thirtyClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[1])
    }
    @IBAction func fifteenClicked(sender: AnyObject) {
        resetClicked(sender);
        changeTimerTime(availableTimesInMinutes[0])
    }
    
    
    
    @IBAction func iTunesClicked(sender: AnyObject) {
        renewActiveCommand(iTunesString);
    }
    @IBAction func VLCClicked(sender: AnyObject) {
        renewActiveCommand(VLCString);
    }
    @IBAction func SafariClicked(sender: AnyObject) {
        renewActiveCommand(YouTubeString);
    }
    
    @IBAction func SoundCloudClicked(sender: AnyObject) {
        renewActiveCommand(SoundCloudString);
    }

    func renewActiveCommand(newActiveCommand: String){
        activeCommand = newActiveCommand;
        commandDisplay.title = activeCommand

    }
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem.title = menuText
        statusItem.menu = statusMenu
        timeDisplay.title = createTimeString(timerTime)
        addCommandScipts()
        activeCommand = iTunesString
        commandDisplay.title = activeCommand

        // set times in menu display
        initialiseMenuTimesDisplay()
        
        // start server
        createServer()
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func startTimer() {
        timer.invalidate();
        counter = timerTime;
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(AppDelegate.changeTitle), userInfo: nil, repeats: true)
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
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
                    print(output.stringValue)
            } else if (error != nil) {
                print("error: \(error)")
            }
        }
        
        print("paused " + activeCommand)
    }

    // creating a time string (min:sec) from a time in seconds
    func createTimeString(timeInSeconds: Int) -> String {
        
        let minutes = timeInSeconds / 60;
        let seconds = timeInSeconds % 60;
        
        var secondsString = String(seconds)
        
        if(secondsString.characters.count == 1){
            secondsString = "0" + secondsString;
        }
        
        return String(minutes) + ":" + secondsString;
    }

    // update the remaining time of the timer
    func changeTimerTime(newTime: Int) {
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
    
    func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    // create local server to listen for timer start
    func createServer(){
        
        backgroundThread(background: {
            // Your function here to run in the background
            
            let server:TCPServer = TCPServer(addr: "127.0.0.1", port: 8989)
            let (success, msg) = server.listen()
            if success {
                while true {
                    if server.accept() != nil {
                        print("command received")
                        dispatch_async(dispatch_get_main_queue()) {
                            // update some UI
                            self.startTimer()
                        }
                        
                    } else {
                        print("accept error")
                    }
                }
            } else {
                print(msg)
            }

        })
    }
}

