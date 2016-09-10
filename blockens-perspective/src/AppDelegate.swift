//
//  AppDelegate.swift
//  blockens-3d
//
//  Created by Bjorn Tipling on 8/19/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func getWindow() -> GameWindow {
        return window as! GameWindow
    }
}
