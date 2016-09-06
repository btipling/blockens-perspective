//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct GroundInfo {
    var xRotation: Float32
    var yRotation: Float32
    var zRotation: Float32
    var xScale: Float32
    var yScale: Float32
}

class GroundRenderer: Renderer {
    
    let renderUtils: RenderUtils
    
    var pipelineState: MTLRenderPipelineState! = nil
    var GroundVertexBuffer: MTLBuffer! = nil
    var groundInfoBuffer: MTLBuffer! = nil
    var depthStencilState: MTLDepthStencilState! = nil

    var groundInfo: GroundInfo! = nil
    
    init (utils: RenderUtils) {
        renderUtils = utils
    }
    
    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState("GroundVertex", fragment: "GroundFragment", device: device, view: view)
        GroundVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "Ground vertices")
        
        var groundInfo = GroundInfo(
            xRotation: 90.0,
            yRotation: 45.0,
            zRotation: 30.0,
            xScale: 1.0,
            yScale: 1.0)
        
        groundInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "ground rotation")
        let contents = groundInfoBuffer.contents()
        let pointer = UnsafeMutablePointer<GroundInfo>(contents)
        pointer.initializeFrom(&groundInfo, count: 1)
        
        
        print("loading Ground assets done")
    }
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "Ground")
        renderUtils.setup3D(renderEncoder)
        
        for (i, vertexBuffer) in [GroundVertexBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())
        
    }
}
