//
// Created by Bjorn Tipling on 7/23/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa

typealias Callback = (NSEvent) -> ()

class GameWindow: NSWindow {

    var keyEventListeners = Array<Callback>()

    override func keyDown(event: NSEvent) {
        if event.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
            super.keyDown(event)
            return
        }
        for callback in keyEventListeners {
            callback(event)
        }
    }

    func addKeyEventCallback(callback: Callback) {
        keyEventListeners.append(callback)
    }


}
