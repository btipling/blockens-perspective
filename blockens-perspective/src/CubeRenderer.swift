//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class CubeRenderer: Renderer, RenderController {

    var renderUtils: RenderUtils!

    var pipelineState: MTLRenderPipelineState! = nil

    var cubeVertexBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var cubeInfoBuffer: MTLBuffer! = nil
    var cubeInfo: RenderUtils.Object3DInfo! = nil
    
    let colors: [Float32]
    let scale: [Float32]
    

    init (colors: [Float32], scale: [Float32]) {
        self.colors = colors
        self.scale = scale
    }
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        pipelineState = renderUtils.createPipeLineState(vertex: "cubeVertex", fragment: "cubeFragment", device: device, view: view)
        cubeVertexBuffer = renderUtils.createCubeVertexBuffer(device: device, bufferLabel: "cube vertices")

        colorBuffer = renderUtils.createColorBuffer(device: device, colors: colors, label: "camera colors")
        
        cubeInfoBuffer = renderUtils.createObject3DInfoBuffer(device: device, label: "cube info")
        
        print("loading cube assets done")
    }

    func update(rotation: [Float32], position: [Float32]) {
        
        cubeInfo = RenderUtils.Object3DInfo(
            rotation: rotation,
            scale: scale,
            position: position)
        
    }


    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        let objectCopy = cubeInfo
        renderUtils.updateObject3DInfoBuffer(object: objectCopy!, buffer: cubeInfoBuffer)
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "cube")
        for (i, vertexBuffer) in [cubeVertexBuffer, colorBuffer, cubeInfoBuffer, renderUtils.renderInfoBuffer()].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())

    }
}
