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
    var zoom: Float32
    var near: Float32
    var far: Float32
    var winResX: Float32
    var winResY: Float32
}

class CubeRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var cubeVertexBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var cubeInfoBuffer: MTLBuffer! = nil
    var viewFrameBuffer: MTLBuffer! = nil
    var depthStencilState: MTLDepthStencilState! = nil

    init (utils: RenderUtils) {
        renderUtils = utils
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        var depthStateDescriptor =  MTLDepthStencilDescriptor()
        depthStateDescriptor.depthWriteEnabled = true
        depthStateDescriptor.depthCompareFunction = MTLCompareFunction.Greater
        depthStencilState = device.newDepthStencilStateWithDescriptor(depthStateDescriptor)

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
                zPos: frameInfo.zPos,
                zoom: frameInfo.zoom,
                near: frameInfo.near,
                far: frameInfo.far,
                winResX: Float32(frameInfo.viewWidth),
                winResY: Float32(frameInfo.viewHeight)
                )
        print("CubeRotation: \(cubeInfo)")
//        if (frameInfo.rotateX != 0.0) {
//            cubeInfo.xRotation = 90
//            print("fudging it \(cubeInfo.xRotation)")
//        }
        let contents = cubeInfoBuffer.contents()
        let pointer = UnsafeMutablePointer<CubeInfo>(contents)
        pointer.initializeFrom(&cubeInfo, count: 1)
    }


    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "cube")
        renderEncoder.setCullMode(MTLCullMode.Back)
        renderEncoder.setFrontFacingWinding(MTLWinding.Clockwise)
        renderEncoder.setDepthStencilState(depthStencilState)
        for (i, vertexBuffer) in [cubeVertexBuffer, colorBuffer, cubeInfoBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInACube())

    }
}
