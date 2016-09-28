//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class SkyRenderer: Renderer, RenderController {

    var renderUtils: RenderUtils!

    var pipelineState: MTLRenderPipelineState! = nil

    var skyVertexBuffer: MTLBuffer! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }
    
    func update() {
        // Do nothing.
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        pipelineState = renderUtils.createPipeLineState(vertex: "skyVertex", fragment: "skyFragment", device: device, view: view)
        skyVertexBuffer = renderUtils.createRectangleVertexBuffer(device: device, bufferLabel: "sky vertices")

        print("loading sky assets done")
    }

    func render(_ renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "sky")

        for (i, vertexBuffer) in [skyVertexBuffer].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())

    }
}
