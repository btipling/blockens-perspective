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
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState(vertex: "GroundVertex", fragment: "GroundFragment", device: device, view: view)
        GroundVertexBuffer = renderUtils.createRectangleVertexBuffer(device: device, bufferLabel: "Ground vertices")
        
        let groundInfo = GroundInfo(
            rotation: [1.4, 0.0, 0.0],
            scale: [100.0, 100.0, 1.0],
            position: [0.0, -5.0, 1.0])
        
        let floatSize = MemoryLayout<Float>.size
        let float3Size = floatSize * 4
        let uniformsStructSize = float3Size * 3;
        
        groundInfoBuffer = device.makeBuffer(length: uniformsStructSize, options: [])
        groundInfoBuffer.label = "ground rotation"
        
        print("FrameInfo: \(frameInfo)")
        
        let pointer = groundInfoBuffer.contents()
        memcpy(pointer, groundInfo.rotation, float3Size)
        memcpy(pointer + float3Size, groundInfo.scale, float3Size)
        memcpy(pointer + (float3Size * 2), groundInfo.position, float3Size)
        
        
        print("loading Ground assets done")
    }
    
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Ground")
        
        for (i, vertexBuffer) in [GroundVertexBuffer, groundInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())
        
    }
}
