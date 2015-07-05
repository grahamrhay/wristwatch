//
//  AppDelegate.swift
//  wristwatch
//
//  Created by Graham on 24/08/2014.
//  Copyright (c) 2014 Look On My Works Ltd. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var restBreakLabel: NSTextField!
    @IBOutlet weak var restBreakProgress: NSProgressIndicator!
    
    var mainTimer: NSTimer!
    var waitTimer: NSTimer!
    var stopTypingTimer: NSTimer!
    var idleTimer: NSTimer!

    var timeTillMicroBreak = (3 * 60) + 30
    var countdownToMicroBreak = 0
    var microBreakDuration = 30

    var timeTillRestBreak = 45 * 60
    var countdownToRestBreak = 0
    var restBreakDuration = 10 * 60
    
    var lastActivity: NSDate!
    
    var statusItem: NSStatusItem! // need to keep a reference to this, or it gets removed from the menu bar
    var menuProgress: NSProgressIndicator!
    
    var timeForABreakWindow: NSWindow!
    var breakTime: BreakTime!
    var intervalFormatter = IntervalFormatter()
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        acquirePrivileges()
        listenForEvents()
        createStatusBarItem()
        progressIndicator.maxValue = Double(timeTillMicroBreak)
        menuProgress.maxValue = Double(timeTillMicroBreak)
        restBreakProgress.maxValue = Double(timeTillRestBreak)
        resetRestBreak()
    }
    
    func listenForEvents() {
        let mask = (NSEventMask.KeyDownMask | NSEventMask.MouseMovedMask)
        let eventMonitor: AnyObject! = NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handlerEvent)
    }
    
    func createStatusBarItem() {
        let statusBar = NSStatusBar.systemStatusBar()
        statusItem = statusBar.statusItemWithLength(-1) // NSVariableStatusItemLength
        let statusView = NSView(frame: NSMakeRect(0, 0, 40, 20))
        menuProgress = NSProgressIndicator(frame: NSMakeRect(0, 0, 40, 20))
        menuProgress.indeterminate = false
        menuProgress.controlTint = NSControlTint.BlueControlTint
        statusView.addSubview(menuProgress)
        statusItem.view = statusView
    }
    
    func resetMicroBreak() {
        countdownToMicroBreak = timeTillMicroBreak
        updateProgress()
    }
    
    func resetRestBreak() {
        countdownToRestBreak = timeTillRestBreak
        resetMicroBreak()
    }
    
    func acquirePrivileges() -> Bool {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)
        if accessEnabled != 1 {
            let alert = NSAlert()
            alert.messageText = "Enable Wristwatch"
            alert.informativeText = "Once you have enabled Wristwatch in System Preferences, click OK and restart the app"
            alert.beginSheetModalForWindow(self.window, completionHandler: { response in
                NSApplication.sharedApplication().terminate(self)
            })
        }
        return accessEnabled == 1
    }
    
    func tick() {
        countdownToMicroBreak--
        countdownToRestBreak--
        if (countdownToMicroBreak <= 0 || countdownToRestBreak <= 0) {
            stopForBreak()
            timeForABreak()
        }
        updateProgress()
    }
    
    func timeForABreak() {
        let tfab = TimeForABreak(windowNibName: "TimeForABreak")
        tfab.showWindow(nil)
        timeForABreakWindow = tfab.window
        stillTyping()
    }
    
    func stillTyping() {
        if (stopTypingTimer != nil) {
            stopTypingTimer.invalidate()
        }
        stopTypingTimer = NSTimer.scheduledTimerWithTimeInterval(3.0,
            target: self,
            selector: Selector("readyForBreak"),
            userInfo: nil,
            repeats: false)
    }
    
    func readyForBreak() {
        timeForABreakWindow.close()
        timeForABreakWindow = nil
        if (countdownToRestBreak <= 0) {
            startRestBreak()
        } else {
            startMicroBreak()
        }
    }
    
    func startMicroBreak() {
        startBreak("Micro-break", duration: microBreakDuration, resetMicroBreak)
    }
    
    func startRestBreak() {
        startBreak("Rest break", duration: restBreakDuration, resetRestBreak)
    }
    
    func startBreak(title: String, duration: Int, next: () -> Void) {
        stopIdleTimer()
        breakTime = BreakTime(windowNibName: "BreakTime", title: title, duration: duration)
        breakTime.setCallback({() -> Void in
            next()
            self.breakTime = nil
        })
        breakTime.startBreak()
    }
    
    func updateProgress() {
        label1.stringValue = intervalFormatter.format(countdownToMicroBreak)
        restBreakLabel.stringValue = intervalFormatter.format(countdownToRestBreak)
        
        progressIndicator.incrementBy(Double(countdownToMicroBreak) - progressIndicator.doubleValue)
        menuProgress.incrementBy(Double(countdownToMicroBreak) - menuProgress.doubleValue)
        restBreakProgress.incrementBy(Double(countdownToRestBreak) - restBreakProgress.doubleValue)
    }
    
    func handlerEvent(aEvent: (NSEvent!)) -> Void {
        lastActivity = NSDate()

        if (breakTime != nil) {
            breakTime.pauseBreak()
            return
        }
 
        if (timeForABreakWindow != nil) {
            stillTyping()
            return
        }

        startTimer()
    }
    
    func startTimer() {
        if (mainTimer == nil) {
            mainTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                target: self,
                selector: Selector("tick"),
                userInfo: nil,
                repeats: true)
        }
        
        if (waitTimer != nil) {
            waitTimer.invalidate()
        }
        waitTimer = NSTimer.scheduledTimerWithTimeInterval(3.0,
            target: self,
            selector: Selector("stoppedTyping"),
            userInfo: nil,
            repeats: false)
        
        stopIdleTimer()
    }
    
    func stopIdleTimer() {
        if (idleTimer != nil) {
            idleTimer.invalidate()
            idleTimer = nil
        }
    }
    
    func stoppedTyping() {
        stopTimer()
        idleTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("idleTick"),
            userInfo: nil,
            repeats: true)
    }
    
    func stopTimer() {
        if (mainTimer != nil) {
            mainTimer.invalidate()
            mainTimer = nil
        }
    }
    
    func stopForBreak() {
        stopIdleTimer()
        stopTimer()
        
        if (breakTime != nil) {
            breakTime.cancel()
        }
    }
    
    func idleTick() {
        var secondsIdle = secondsSinceLastActivity()
        if (secondsIdle > microBreakDuration && countdownToMicroBreak < timeTillMicroBreak) {
            resetMicroBreak()
        }
        if (secondsIdle > restBreakDuration) {
            resetRestBreak()
            stopIdleTimer()
        }
    }

    func secondsSinceLastActivity() -> Int {
        return Int(NSDate().timeIntervalSinceDate(lastActivity))
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        stopForBreak()
    }
    
    @IBAction func microButtonPressed(sender: AnyObject) {
        stopForBreak()
        startMicroBreak()
    }
    
    @IBAction func restButtonPressed(sender: AnyObject) {
        stopForBreak()
        startRestBreak()
    }
}

