//
//  CrossHairsRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class CrossHairsRenderer: Renderer, RenderController {
    
    let crossHairsVertexData: [Float32] = [
        
        1.0, 0.0,
        -1.0, 0.0,
        
        0.0, 1.0,
        0.0, -1.0,
        
    ]
    
    var renderUtils: RenderUtils!
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var crossHairsVertexBuffer: MTLBuffer! = nil
    
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
        
        pipelineState = renderUtils.createPipeLineState(vertex: "crossHairsVertex", fragment: "crossHairsFragment", device: device, view: view)
        crossHairsVertexBuffer = createLinesBuffer(device: device)
        print("loading CrossHairs assets done")
    }
    
    func createLinesBuffer(device: MTLDevice) -> MTLBuffer {
        
        let bufferSize = crossHairsVertexData.count * MemoryLayout.size(ofValue: crossHairsVertexData[0])
        let buffer = device.makeBuffer(length: bufferSize, options: [])
        let pointer = buffer.contents()
        memcpy(pointer, crossHairsVertexData, bufferSize)
        buffer.label = "Cross hairs buffer"
        
        return buffer
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "CrossHairs")
        
        
        for (i, vertexBuffer) in [crossHairsVertexBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }
        
        
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: 4, instanceCount: 2)
        renderUtils.finishDrawing(renderEncoder: renderEncoder)
        
    }
}

