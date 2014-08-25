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
    
    var timer = NSTimer()

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func tick() {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ssZZZZZ"
        let timestamp = dateFormatter.stringFromDate(date)
        label1.stringValue = timestamp
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        timer.invalidate()
    }
}

