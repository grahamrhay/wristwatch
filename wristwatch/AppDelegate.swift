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
    
    var countdownToMicroBreak = 0
    var countdownToRestBreak = 60 * 45
    
    var statusItem: NSStatusItem! // need to keep a reference to this, or it gets removed from the menu bar
    var menuProgress: NSProgressIndicator!
    
    var timeForABreakWindow: NSWindow!
    var breakTime: BreakTime!
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        acquirePrivileges()
        listenForEvents()
        createStatusBarItem()
        resetMicrobreak()
        progressIndicator.maxValue = Double(countdownToMicroBreak)
        menuProgress.maxValue = Double(countdownToMicroBreak)
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
    
    func resetMicrobreak() {
        //countdownToMicroBreak = (60 * 3) + 30 // 3 mins & 30 seconds
        countdownToMicroBreak = 5
        updateProgress()
    }
    
    func acquirePrivileges() -> Bool {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted: true]
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
        if (countdownToMicroBreak == 0) {
            stopTimer()
            timeForABreak()
        }
        countdownToRestBreak--
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
            selector: Selector("stoppedTyping"),
            userInfo: nil,
            repeats: false)
    }
    
    func stoppedTyping() {
        timeForABreakWindow.close()
        startMicroBreak()
    }
    
    func startMicroBreak() {
        breakTime = BreakTime(windowNibName: "BreakTime")
        breakTime.setCallback(resetMicrobreak)
        breakTime.startBreak()
    }
    
    func updateProgress() {
        label1.stringValue = formatInterval(countdownToMicroBreak)
        restBreakLabel.stringValue = formatInterval(countdownToRestBreak)
        
        progressIndicator.incrementBy(Double(countdownToMicroBreak) - progressIndicator.doubleValue)
        menuProgress.incrementBy(Double(countdownToMicroBreak) - menuProgress.doubleValue)
        restBreakProgress.incrementBy(Double(countdownToRestBreak) - progressIndicator.doubleValue)
    }
    
    func formatInterval(totalSeconds: (Int)) -> NSString {
        var seconds = totalSeconds % 60
        var minutes = (totalSeconds / 60) % 60
        var hours = (totalSeconds / 3600)
        return NSString(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func handlerEvent(aEvent: (NSEvent!)) -> Void {
        if (countdownToMicroBreak > 0) {
            startTimer()
        } else {
            if (breakTime != nil) {
                breakTime.pauseBreak()
            } else {
                stillTyping()
            }
        }
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
            selector: Selector("stopTimer"),
            userInfo: nil,
            repeats: false)
    }
    
    func stopTimer() {
        if (mainTimer != nil) {
            mainTimer.invalidate()
            mainTimer = nil
        }
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        stopTimer()
    }
}

