//
//  main.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 13-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import Foundation
import UIKit

// Your initialization code here

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(MDTimerApp.self),
    NSStringFromClass(AppDelegate.self)
)
