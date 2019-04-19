//
// Created by Bjorn Tipling on 7/23/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa

typealias Callback = (NSEvent?) -> ()

class GameWindow: NSWindow {

    var keyDownEventListeners = Array<Callback>()
    var keyUpEventListeners = Array<Callback>()

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) {
            super.keyDown(with: event)
            return
        }
        for callback in keyDownEventListeners {
            callback(event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        for callback in keyUpEventListeners {
            callback(event)
        }
    }

    func addKeyDownEventCallback(_ callback: @escaping Callback) {
        keyDownEventListeners.append(callback)
    }
    
    func addKeyUpEventCallback(_ callback: @escaping Callback) {
        keyUpEventListeners.append(callback)
    }


}
