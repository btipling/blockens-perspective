//
// Created by Bjorn Tipling on 7/23/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa

typealias Callback = (NSEvent) -> ()

class GameWindow: NSWindow {

    var keyEventListeners = Array<Callback>()

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(NSEventModifierFlags.command) {
            super.keyDown(with: event)
            return
        }
        for callback in keyEventListeners {
            callback(event)
        }
    }

    func addKeyEventCallback(_ callback: @escaping Callback) {
        keyEventListeners.append(callback)
    }


}
