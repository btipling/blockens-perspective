//
//  CameraVectorRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//


import Foundation
import MetalKit

struct CameraVectorInfo {
    var xRotation: Float32
    var yRotation: Float32
    var zRotation: Float32
    var xPos: Float32
    var yPos: Float32
    var zPos: Float32
}

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
        
        
        let floatSize = MemoryLayout<Float>.size
        let bufferSize = floatSize * renderUtils.cubeColors.count
        colorBuffer = device.makeBuffer(length: bufferSize, options: [])
        colorBuffer.label = "cameraVector colors"
        // put renderUtils.cameraVectorColors into colorBuffer
        let pointer = colorBuffer.contents()
        memcpy(pointer, renderUtils.cubeColors, bufferSize)
        
        cameraVectorInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "cameraVector rotation")
        
        updatecameraVectorRotation(frameInfo)
        
        print("loading cameraVector assets done")
    }
    
    func update(_ frameInfo: FrameInfo) {
        updatecameraVectorRotation(frameInfo)
    }
    
    fileprivate func updatecameraVectorRotation(_ frameInfo: FrameInfo) {
        
        var cameraVectorInfo = CameraVectorInfo(
            xRotation: frameInfo.rotateX,
            yRotation: frameInfo.rotateY,
            zRotation: frameInfo.rotateZ,
            xPos: frameInfo.xPos,
            yPos: frameInfo.yPos,
            zPos: frameInfo.zPos)
        
        let pointer = cameraVectorInfoBuffer.contents()
        let size = MemoryLayout<CameraVectorInfo>.size
        memcpy(pointer, &cameraVectorInfo, size)
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
