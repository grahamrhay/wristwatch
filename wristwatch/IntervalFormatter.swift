//
//  IntervalFormatter.swift
//  wristwatch
//
//  Created by Graham on 01/09/2014.
//  Copyright (c) 2014 Look On My Works Ltd. All rights reserved.
//

import Foundation

class IntervalFormatter {
    func format(totalSeconds: (Int)) -> NSString {
        var seconds = totalSeconds % 60
        var minutes = (totalSeconds / 60) % 60
        return NSString(format: "%02d:%02d", minutes, seconds)
    }
}
