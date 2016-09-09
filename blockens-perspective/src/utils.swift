//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import Cocoa

let ROTATION_CHANGE_MODIFIER: Float32 = 0.1;
let POS_CHANGE_MODIFIER: Float32 = 0.1;
let ZOOM_CHANGE_MODIFIER: Float32 = 0.01;

struct FrameInfo {
    var viewWidth: Int32
    var viewHeight: Int32
    var viewDiffRatio: Float32
    var rotateX: Float32
    var rotateY: Float32
    var rotateZ: Float32
    var xPos: Float32
    var yPos: Float32
    var zPos: Float32
    var zoom: Float32
    var near: Float32
    var far: Float32
}

let A_KEY: UInt16 = 0
let S_KEY: UInt16 = 1
let D_KEY: UInt16 = 2
let F_KEY: UInt16 = 3
let B_KEY: UInt16 = 11
let W_KEY: UInt16 = 13
let P_KEY: UInt16 = 35
let N_KEY: UInt16 = 45
let I_KEY: UInt16 = 34
let O_KEY: UInt16 = 31


let PLUS_KEY: UInt16 = 24
let MINUS_KEY: UInt16 = 27

let OPEN_BRACKET_KEY: UInt16 = 33
let CLOSE_BRACKET_KEY: UInt16 = 30

let OPEN_ALL_KEY: UInt16 = 43
let CLOSE_ALL_KEY: UInt16 = 47

let LEFT_KEY: UInt16 = 123
let RIGHT_KEY: UInt16 = 124
let UP_KEY: UInt16 = 126
let DOWN_KEY: UInt16 = 125

let skyBlue = rgbaToNormalizedGPUColors(116, g:184, b:223);

let purple = rgbaToNormalizedGPUColors(233, g: 116, b: 223)
let orange = rgbaToNormalizedGPUColors(255, g: 191, b: 127)
let green = rgbaToNormalizedGPUColors(158, g: 236, b: 117)
let red = rgbaToNormalizedGPUColors(249, g: 82, b: 12)
let yellow = rgbaToNormalizedGPUColors(249, g: 237, b: 12)
let cherry = rgbaToNormalizedGPUColors(249, g: 0, b: 75)

func rgbaToNormalizedGPUColors(r: Int, g: Int, b: Int, a: Int = 255) -> [Float32] {
    return [Float32(r)/255.0, Float32(g)/255.0, Float32(b)/255.0, Float32(a)/255.0]
}

func getRandomNum(n: Int32) -> Int32 {
    return Int32(arc4random_uniform(UInt32(n)))
}

func log_e(n: Double) -> Double {
    return log(n)/log(M_E)
}

func flipImage(image: NSImage) -> NSImage {
    var imageBounds = NSZeroRect
    imageBounds.size = image.size
    let transform = NSAffineTransform()
    transform.translateXBy(0.0, yBy: imageBounds.height)
    transform.scaleXBy(1, yBy: -1)
    let flippedImage = NSImage(size: imageBounds.size)

    flippedImage.lockFocus()
    transform.concat()
    image.drawInRect(imageBounds, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)
    flippedImage.unlockFocus()

    return flippedImage
}