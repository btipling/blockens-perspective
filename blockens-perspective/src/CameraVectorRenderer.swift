//
//  CameraVectorRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//


import Foundation
import MetalKit

class CameraVectorRenderer: Renderer, RenderController {
    
    var renderUtils: RenderUtils!
    
    var pipelineState: MTLRenderPipelineState? = nil
    
    var verticesBuffer: MTLBuffer? = nil
    
    let vectorVerticesData: [Float32] = [
        0.0, 0.0, 0.0,
        1.0, 0.0, 1.0,
    ]

    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState(vertex: "cameraVectorVertex", fragment: "cameraVectorFragment", device: device, view: view)
        
        verticesBuffer = createVerticesBuffer(device: device)
        
        print("loading camera vector assets done")
    }
    
    
    func createVerticesBuffer(device: MTLDevice) -> MTLBuffer {
        
        let bufferSize = vectorVerticesData.count * MemoryLayout.size(ofValue: vectorVerticesData[0])
        let buffer = device.makeBuffer(length: bufferSize, options: [])
        let pointer = buffer.contents()
        memcpy(pointer, vectorVerticesData, bufferSize)
        buffer.label = "vector vertices buffer"
        
        return buffer
    }
    
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        if let pipelineState = self.pipelineState {
            renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "cameraVector")
            renderUtils.setup3D(renderEncoder: renderEncoder)
            for (i, vertexBuffer) in [verticesBuffer].enumerated() {
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
            }
            
            renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: 6, instanceCount: 1)
            renderUtils.finishDrawing(renderEncoder: renderEncoder)
        }
        
    }
}
