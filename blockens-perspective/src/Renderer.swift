//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

protocol Renderer {
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo)
    func update()
    func render(_ renderEncoder: MTLRenderCommandEncoder)
}
