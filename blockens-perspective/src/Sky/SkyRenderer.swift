//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct SkyInfo {
    var tickCount: Int32
    var viewDiffRatio : Float32
}

class SkyRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var skyVertexBuffer: MTLBuffer! = nil

    init (utils: RenderUtils) {
        renderUtils = utils
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        pipelineState = renderUtils.createPipeLineState("skyVertex", fragment: "skyFragment", device: device, view: view)
        skyVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "sky vertices")

        print("loading sky assets done")
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "sky")

        for (i, vertexBuffer) in [skyVertexBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())

    }
}
