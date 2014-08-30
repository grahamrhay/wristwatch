//
//  TimeForABreak.swift
//  wristwatch
//
//  Created by Graham on 25/08/2014.
//  Copyright (c) 2014 Look On My Works Ltd. All rights reserved.
//

import Cocoa

class TimeForABreak: NSWindowController {
    
    convenience init(windowNibName: String!, title: String, duration: Int) {
        self.init(windowNibName: windowNibName)
        self.window.level = Int(CGWindowLevelForKey(Int32(kCGScreenSaverWindowLevelKey)))
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}