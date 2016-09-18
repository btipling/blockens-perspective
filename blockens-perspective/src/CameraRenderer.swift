//
//  CameraRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit
class CameraRenderer: Renderer {
    
    let renderUtils: RenderUtils
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var cameraVertexBuffer: MTLBuffer! = nil
    var cameraInfoBuffer: MTLBuffer! = nil
    
    init (utils: RenderUtils) {
        renderUtils = utils
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState(vertex: "cameraVertex", fragment: "cameraFragment", device: device, view: view)
        cameraVertexBuffer = renderUtils.createCubeVertexBuffer(device: device, bufferLabel: "Camera vertices")
        
        
        cameraInfoBuffer = renderUtils.createObject3DInfoBuffer(device: device, label: "Camera rotation")
        
        updateCameraRotation(frameInfo)
        
        print("loading Camera assets done")
    }
    
    func update(_ frameInfo: FrameInfo) {
        updateCameraRotation(frameInfo)
    }
    
    fileprivate func updateCameraRotation(_ frameInfo: FrameInfo) {
        let cameraRotation = [
            frameInfo.cameraRotation[0],
            frameInfo.cameraRotation[1],
            0.0
        ]
        let cameraInfo = RenderUtils.Object3DInfo(
            rotation: [0.0, 0.0, 0.0],
            scale: [0.5, 0.5, 0.5],
            position: [1.0, 1.0, 10.0])
        
        renderUtils.updateObject3DInfoBuffer(object: cameraInfo, buffer: cameraInfoBuffer)
    }
    
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Camera")
        renderUtils.setup3D(renderEncoder: renderEncoder)
        for (i, vertexBuffer) in [cameraVertexBuffer, cameraInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }
        
        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())
        
    }
}
