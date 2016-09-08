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

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState("cubeVertex", fragment: "cubeFragment", device: device, view: view)
        cubeVertexBuffer = renderUtils.createCubeVertexBuffer(device, bufferLabel: "cube vertices")

        let bufferSize = sizeof(Float32) * renderUtils.cubeColors.count
        colorBuffer = device.newBufferWithLength(bufferSize, options: [])
        colorBuffer.label = "cube colors"

        let contents = colorBuffer.contents()
        let pointer = UnsafeMutablePointer<Float32>(contents)
        pointer.initializeFrom(renderUtils.cubeColors)

        cubeInfoBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "cube rotation")

        updateCubeRotation(frameInfo)
        
        print("loading cube assets done")
    }

    func update(frameInfo: FrameInfo) {
        updateCubeRotation(frameInfo)
    }

    private func updateCubeRotation(frameInfo: FrameInfo) {
        
        var cubeInfo = CubeInfo(
                xRotation: frameInfo.rotateX,
                yRotation: frameInfo.rotateY,
                zRotation: frameInfo.rotateZ,
                xPos: frameInfo.xPos,
                yPos: frameInfo.yPos,
                zPos: frameInfo.zPos)
        
        let contents = cubeInfoBuffer.contents()
        let pointer = UnsafeMutablePointer<CubeInfo>(contents)
        pointer.initializeFrom(&cubeInfo, count: 1)
    }


    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "cube")
        renderUtils.setup3D(renderEncoder)
        for (i, vertexBuffer) in [cubeVertexBuffer, colorBuffer, cubeInfoBuffer, renderUtils.renderInfoBuffer()].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInACube())

    }
}
