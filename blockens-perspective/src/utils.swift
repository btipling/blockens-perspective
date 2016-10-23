//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import Cocoa
import simd

let ROTATION_CHANGE_MODIFIER: Float32 = 0.1;
let POS_CHANGE_MODIFIER: Float32 = 0.1;
let ZOOM_CHANGE_MODIFIER: Float32 = 0.01;
let CAMERA_CHANGE_MODIFIER: Float32 = 0.1;

struct FrameInfo {
    var viewDimensions: float2
    var viewDiffRatio: Float32
    var cubeRotation: float3
    var cubePosition: float3
    var zoom: Float32
    var near: Float32
    var far: Float32
    var cameraRotation: float3
    var cameraTranslation: float3
    var useCamera: Bool
}

let A_KEY: UInt16 = 0
let S_KEY: UInt16 = 1
let D_KEY: UInt16 = 2
let F_KEY: UInt16 = 3
let Z_KEY: UInt16 = 6
let X_KEY: UInt16 = 7
let C_KEY: UInt16 = 8
let V_KEY: UInt16 = 9
let B_KEY: UInt16 = 11
let W_KEY: UInt16 = 13
let P_KEY: UInt16 = 35
let N_KEY: UInt16 = 45
let M_KEY: UInt16 = 46
let I_KEY: UInt16 = 34
let O_KEY: UInt16 = 31
let Q_KEY: UInt16 = 12
let E_KEY: UInt16 = 14
let SPACE_KEY: UInt16 = 49


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
let lightBlue = rgbaToNormalizedGPUColors(0, g: 159, b: 225);
let lightGreen = rgbaToNormalizedGPUColors(159, g: 250, b: 0);


let purple = rgbaToNormalizedGPUColors(233, g: 116, b: 223)
let orange = rgbaToNormalizedGPUColors(255, g: 191, b: 127)
let green = rgbaToNormalizedGPUColors(158, g: 236, b: 117)
let red = rgbaToNormalizedGPUColors(249, g: 82, b: 12)
let yellow = rgbaToNormalizedGPUColors(249, g: 237, b: 12)
let cherry = rgbaToNormalizedGPUColors(249, g: 0, b: 75)

let gray1 = rgbaToNormalizedGPUColors(101, g: 101, b: 101)
let gray2 = rgbaToNormalizedGPUColors(128, g: 128, b: 128)
let gray3 = rgbaToNormalizedGPUColors(139, g: 139, b: 139)
let gray4 = rgbaToNormalizedGPUColors(173, g: 173, b: 173)
let gray5 = rgbaToNormalizedGPUColors(214, g: 214, b: 214)
let blueGray = rgbaToNormalizedGPUColors(33, g: 85, b: 124)
let white = float4(1.0, 1.0, 1.0, 1.0)
let lightGray = float4(0.9, 0.9, 0.9, 0.9)


let groundGreen = rgbaToNormalizedGPUColors(78, g: 183, b: 2)

func rgbaToNormalizedGPUColors(_ r: Int, g: Int, b: Int, a: Int = 255) -> float4 {
    return float4(Float32(r)/255.0, Float32(g)/255.0, Float32(b)/255.0, Float32(a)/255.0)
}

func getRandomNum(_ n: Int32) -> Int32 {
    return Int32(arc4random_uniform(UInt32(n)))
}

func log_e(_ n: Double) -> Double {
    return log(n)/log(M_E)
}

func fix(image: NSImage, flip: Bool=false) -> NSImage {
    var imageBounds = NSZeroRect
    imageBounds.size = image.size
    var transform = AffineTransform.identity
    if flip {
        transform.translate(x: 0.0, y: imageBounds.height)
        transform.scale(x: 1.0, y: -1.0)
    }
    let flippedImage = NSImage(size: imageBounds.size)

    flippedImage.lockFocus()
    (transform as NSAffineTransform).concat()
    image.draw(in: imageBounds, from: NSZeroRect, operation: NSCompositingOperation.copy, fraction: 1.0)
    flippedImage.unlockFocus()

    return flippedImage
}
