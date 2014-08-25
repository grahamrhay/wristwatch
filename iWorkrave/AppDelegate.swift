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
    @IBOutlet weak var label1: NSTextField!
    
    var mainTimer: NSTimer!
    var waitTimer: NSTimer!

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        let mask = (NSEventMask.KeyDownMask | NSEventMask.MouseMovedMask)
        let eventMonitor: AnyObject! = NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handlerEvent)
    }
    
    func tick() {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ssZZZZZ"
        let timestamp = dateFormatter.stringFromDate(date)
        label1.stringValue = timestamp
    }
    
    func handlerEvent(aEvent: (NSEvent!)) -> Void {
        startTimer()
    }
    
    func startTimer() {
        tick()
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

