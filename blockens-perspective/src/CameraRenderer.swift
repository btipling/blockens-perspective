//
//  CameraRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct CameraInfo {
    var xRotation: Float32
    var yRotation: Float32
    var zRotation: Float32
    var xPos: Float32
    var yPos: Float32
    var zPos: Float32
}

class CameraRenderer: Renderer {
    
    let renderUtils: RenderUtils
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var CameraVertexBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var CameraInfoBuffer: MTLBuffer! = nil
    
    init (utils: RenderUtils) {
        renderUtils = utils
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState(vertex: "CameraVertex", fragment: "CameraFragment", device: device, view: view)
        CameraVertexBuffer = renderUtils.createCubeVertexBuffer(device: device, bufferLabel: "Camera vertices")
        
        
        let floatSize = MemoryLayout<Float>.size
        let bufferSize = floatSize * renderUtils.cubeColors.count
        colorBuffer = device.makeBuffer(length: bufferSize, options: [])
        colorBuffer.label = "Camera colors"
        // put renderUtils.CameraColors into colorBuffer
        let pointer = colorBuffer.contents()
        memcpy(pointer, renderUtils.cubeColors, bufferSize)
        
        CameraInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "Camera rotation")
        
        updateCameraRotation(frameInfo)
        
        print("loading Camera assets done")
    }
    
    func update(_ frameInfo: FrameInfo) {
        updateCameraRotation(frameInfo)
    }
    
    fileprivate func updateCameraRotation(_ frameInfo: FrameInfo) {
        
        var cameraInfo = CameraInfo(
            xRotation: frameInfo.rotateX,
            yRotation: frameInfo.rotateY,
            zRotation: frameInfo.rotateZ,
            xPos: frameInfo.xPos,
            yPos: frameInfo.yPos,
            zPos: frameInfo.zPos)
        
        let pointer = CameraInfoBuffer.contents()
        let size = MemoryLayout<CameraInfo>.size
        memcpy(pointer, &cameraInfo, size)
    }
    
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Camera")
        renderUtils.setup3D(renderEncoder: renderEncoder)
        for (i, vertexBuffer) in [CameraVertexBuffer, colorBuffer, CameraInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())
        
    }
}
