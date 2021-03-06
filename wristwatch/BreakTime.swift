//
//  BreakTime.swift
//  wristwatch
//
//  Created by Graham on 30/08/2014.
//  Copyright (c) 2014 Look On My Works Ltd. All rights reserved.
//

import Cocoa

class BreakTime: NSWindowController {
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    
    var breakTimer: NSTimer!
    var pauseTimer: NSTimer!
    var callback: (() -> Void)!
    
    var breakRemaining = 0
    
    var title: String!
    var duration: Int!
    var skipped = false
    
    var intervalFormatter = IntervalFormatter()
    
    convenience init(windowNibName: String!, title: String, duration: Int) {
        self.init(windowNibName: windowNibName)
        self.title = title
        self.duration = duration
        window?.level = Int(CGWindowLevelForKey(Int32(kCGScreenSaverWindowLevelKey)))
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.title = title
        breakRemaining = duration
        progressBar.maxValue = Double(breakRemaining)
        updateProgress()
    }
    
    func startBreak() {
        self.showWindow(nil)
        startBreakTimer()
    }
    
    func startBreakTimer() {
        if (skipped) {
            return
        }
        
        breakTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
    }
    
    func tick() {
        breakRemaining--
        updateProgress()
    }
    
    func updateProgress() {
        progressBar.incrementBy(Double(breakRemaining) - progressBar.doubleValue)
        progressLabel.stringValue = intervalFormatter.format(breakRemaining)
        
        if (breakRemaining == 0) {
            breakTimeOver()
        }
    }
    
    func breakTimeOver(cancelled: Bool = false) {
        breakTimer.invalidate()
        self.close()
        if (!cancelled && callback != nil) {
            callback()
        }
    }
    
    func pauseBreak() {
        if (breakTimer != nil) {
            breakTimer.invalidate()
        }
        if (pauseTimer != nil) {
            pauseTimer.invalidate()
        }
        pauseTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: Selector("startBreakTimer"),
            userInfo: nil,
            repeats: false)
    }
    
    func setCallback(cb: () -> Void) {
        callback = cb
    }
    
    @IBAction func skipButton(sender: AnyObject) {
        skipped = true
        breakTimeOver()
    }
    
    func cancel() {
        breakTimeOver(cancelled: true)
    }
}