//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class GroundRenderer: Renderer {
    
    let renderUtils: RenderUtils
    
    var pipelineState: MTLRenderPipelineState! = nil
    var GroundVertexBuffer: MTLBuffer! = nil
    var groundInfoBuffer: MTLBuffer! = nil
    var depthStencilState: MTLDepthStencilState! = nil

    var groundInfo: RenderUtils.Object3DInfo! = nil
    
    init (utils: RenderUtils) {
        renderUtils = utils
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState(vertex: "GroundVertex", fragment: "GroundFragment", device: device, view: view)
        GroundVertexBuffer = renderUtils.createRectangleVertexBuffer(device: device, bufferLabel: "Ground vertices")
        
        let groundInfo = RenderUtils.Object3DInfo(
            rotation: [1.4, 0.0, 0.0],
            scale: [100.0, 100.0, 1.0],
            position: [0.0, -5.0, 1.0])
        
        groundInfoBuffer = renderUtils.createObject3DInfoBuffer(device: device, label: "ground info buffer")
        
        print("FrameInfo: \(frameInfo)")
        
        renderUtils.updateObject3DInfoBuffer(object: groundInfo, buffer: groundInfoBuffer)
        
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
