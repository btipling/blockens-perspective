//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct CubeInfo {
    var xRotation: Float32
    var yRotation: Float32
    var zRotation: Float32
    var xPos: Float32
    var yPos: Float32
    var zPos: Float32
}

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
        
        cubeInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "cube rotation")

        updateCubeRotation(frameInfo)
        
        print("loading cube assets done")
    }

    func update(_ frameInfo: FrameInfo) {
        updateCubeRotation(frameInfo)
    }

    fileprivate func updateCubeRotation(_ frameInfo: FrameInfo) {
        
        var cubeInfo = CubeInfo(
                xRotation: frameInfo.rotateX,
                yRotation: frameInfo.rotateY,
                zRotation: frameInfo.rotateZ,
                xPos: frameInfo.xPos,
                yPos: frameInfo.yPos,
                zPos: frameInfo.zPos)
        
        let pointer = cubeInfoBuffer.contents()
        let size = MemoryLayout<CubeInfo>.size
        memcpy(pointer, &cubeInfo, size)
    }


    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "cube")
        for (i, vertexBuffer) in [cubeVertexBuffer, colorBuffer, cubeInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())

    }
}
