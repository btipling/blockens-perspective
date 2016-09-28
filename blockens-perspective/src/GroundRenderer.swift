//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class GroundRenderer: Renderer, RenderController {
    
    var renderUtils: RenderUtils!
    
    var pipelineState: MTLRenderPipelineState! = nil
    var groundVertexBuffer: MTLBuffer! = nil
    var matrixBuffer: MTLBuffer! = nil
    var groundInfo: RenderUtils.Object3DInfo! = nil
    var depthStencilState: MTLDepthStencilState! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState(vertex: "GroundVertex", fragment: "GroundFragment", device: device, view: view)
        groundVertexBuffer = renderUtils.createRectangleVertexBuffer(device: device, bufferLabel: "Ground vertices")
        
        groundInfo = RenderUtils.Object3DInfo(
            rotation: [1.6, 0.0, 0.0],
            scale: [100.0, 100.0, 1.0],
            position: [0.0, -5.0, 1.0])
        
        matrixBuffer = renderUtils.createMatrixBuffer(device: device, label: "Ground matrix")
        
        update()
        
        print("loading Ground assets done")
    }
    
    func update() {
        renderUtils.updateMatrixBuffer(buffer: matrixBuffer, object3DInfo: groundInfo)
    }
    
    
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Ground")
        
        for (i, vertexBuffer) in [groundVertexBuffer, matrixBuffer].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())
        
    }
}
