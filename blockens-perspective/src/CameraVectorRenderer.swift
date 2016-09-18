//
//  CameraVectorRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//


import Foundation
import MetalKit

class CameraVectorRenderer: Renderer {
    
    let renderUtils: RenderUtils
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var cameraVectorVertexBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var cameraVectorInfoBuffer: MTLBuffer! = nil
    
    init (utils: RenderUtils) {
        renderUtils = utils
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState(vertex: "cameraVectorVertex", fragment: "cameraVectorFragment", device: device, view: view)
        
        
        cameraVectorVertexBuffer = renderUtils.createCubeVertexBuffer(device: device, bufferLabel: "cameraVector vertices")
        
        
        colorBuffer = renderUtils.createColorBuffer(device: device, colors: renderUtils.vectorColors, label: "camera vector colors")
        
        cameraVectorInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "cameraVector rotation")
        
        cameraVectorInfoBuffer = device.makeBuffer(length: renderUtils.float3Size * 3, options: [])
        cameraVectorInfoBuffer.label = "camera vector buffer"
        
        print("loading cameraVector assets done")
    }
    
    func update(cameraRotation: [Float32]) {
        
        let pointer = cameraVectorInfoBuffer.contents()
        memcpy(pointer, cameraRotation, renderUtils.float3Size)
    }
    
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "cameraVector")
        renderUtils.setup3D(renderEncoder: renderEncoder)
        for (i, vertexBuffer) in [cameraVectorVertexBuffer, colorBuffer, cameraVectorInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())
        
    }
}
