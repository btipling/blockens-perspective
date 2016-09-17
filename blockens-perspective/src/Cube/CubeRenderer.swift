//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class CubeRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var cubeVertexBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var cubeInfoBuffer: MTLBuffer! = nil

    init (utils: RenderUtils) {
        renderUtils = utils
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState(vertex: "cubeVertex", fragment: "cubeFragment", device: device, view: view)
        cubeVertexBuffer = renderUtils.createCubeVertexBuffer(device: device, bufferLabel: "cube vertices")

        
        let floatSize = MemoryLayout<Float>.size
        let bufferSize = floatSize * renderUtils.cubeColors.count
        colorBuffer = device.makeBuffer(length: bufferSize, options: [])
        colorBuffer.label = "cube colors"
        // put renderUtils.cubeColors into colorBuffer
        let pointer = colorBuffer.contents()
        memcpy(pointer, renderUtils.cubeColors, bufferSize)
        
        cubeInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "cube info")

        updateCubeRotation(frameInfo)
        
        print("loading cube assets done")
    }

    func update(_ frameInfo: FrameInfo) {
        updateCubeRotation(frameInfo)
    }

    fileprivate func updateCubeRotation(_ frameInfo: FrameInfo) {
        
        let cubeInfo = RenderUtils.Object3DInfo(
            rotation: [frameInfo.rotateX, frameInfo.rotateY,frameInfo.rotateZ],
            scale: [1.0, 1.0, 1.0],
            position: [frameInfo.xPos, frameInfo.yPos, frameInfo.zPos])
        
        renderUtils.updateObject3DInfoBuffer(object: cubeInfo, buffer: cubeInfoBuffer)
    }


    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "cube")
        for (i, vertexBuffer) in [cubeVertexBuffer, colorBuffer, cubeInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())

    }
}
