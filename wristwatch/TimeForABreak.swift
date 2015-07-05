//
//  TimeForABreak.swift
//  wristwatch
//
//  Created by Graham on 25/08/2014.
//  Copyright (c) 2014 Look On My Works Ltd. All rights reserved.
//

import Cocoa

class TimeForABreak: NSWindowController {
    override func windowDidLoad() {
        window?.level = Int(CGWindowLevelForKey(Int32(kCGScreenSaverWindowLevelKey)))
        super.windowDidLoad()
    }
}