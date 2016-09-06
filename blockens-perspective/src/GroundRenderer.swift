//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct GroundInfo {
    var rotation: [Float32]
    var scale: [Float32]
    var position: [Float32]
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
        
        let groundInfo = GroundInfo(
            rotation: [0.5, 0.0, 0.0],
            scale: [3.5, 3.5, 1.0],
            position: [0.0, -1.0, 0.0])
        
        let floatSize = sizeof(Float)
        let float3Size = floatSize * 4
        let uniformsStructSize = float3Size * 3;
        
        groundInfoBuffer = device.newBufferWithLength(uniformsStructSize, options: [])
        groundInfoBuffer.label = "ground rotation"
        
        
        let pointer = groundInfoBuffer.contents()
        memcpy(pointer, groundInfo.rotation, float3Size)
        memcpy(pointer + float3Size, groundInfo.scale, float3Size)
        memcpy(pointer + (float3Size * 2), groundInfo.position, float3Size)
        
        
        print("loading Ground assets done")
    }
    
    
    func render(renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "Ground")
        renderUtils.setup3D(renderEncoder)
        
        for (i, vertexBuffer) in [GroundVertexBuffer, groundInfoBuffer, renderUtils.renderInfoBuffer()].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())
        
    }
}
