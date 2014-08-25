//
//  AppDelegate.swift
//  iWorkrave
//
//  Created by Graham on 24/08/2014.
//  Copyright (c) 2014 Look On My Works Ltd. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var label1: NSTextField!
    
    var mainTimer: NSTimer!
    var waitTimer: NSTimer!
    
    var currentSlice = 0
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        let mask = (NSEventMask.KeyDownMask | NSEventMask.MouseMovedMask)
        let eventMonitor: AnyObject! = NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handlerEvent)
        progressIndicator.maxValue = 210
    }
    
    func tick() {
        currentSlice++
        updateProgress()
    }
    
    func updateProgress() {
        var seconds = currentSlice % 60;
        var minutes = (currentSlice / 60) % 60;
        var hours = (currentSlice / 3600);
        label1.stringValue = NSString(format: "%02d:%02d:%02d", hours, minutes, seconds)
        progressIndicator.incrementBy(Double(currentSlice) - progressIndicator.doubleValue)
    }
    
    func handlerEvent(aEvent: (NSEvent!)) -> Void {
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
            selector: Selector("stopTimer"),
            userInfo: nil,
            repeats: false)
    }
    
    func stopTimer() {
        mainTimer.invalidate()
        mainTimer = nil
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        stopTimer()
    }
}

