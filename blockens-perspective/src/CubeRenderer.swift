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
    var matrixBuffer: MTLBuffer! = nil
    var cubeInfo: RenderUtils.Object3DInfo! = nil
    
    let colors: [float4]
    let scale: float3
    

    init (colors: [float4], scale: float3) {
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
        colorBuffer = renderUtils.createColorBuffer(device: device, colors: colors, label: "cube colors")
        matrixBuffer = renderUtils.createMatrixBuffer(device: device, label: "Cube matrix")
        
    }

    func update(rotation: float3,position: float3) {
        
        cubeInfo = RenderUtils.Object3DInfo(
            rotation: rotation,
            scale: scale,
            position: position)
    }
    
    func update() {
        guard let objectCopy = cubeInfo else {
            return
        }
        renderUtils.updateMatrixBuffer(buffer: matrixBuffer, object3DInfo: objectCopy)
    }


    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "cube")
        for (i, vertexBuffer) in [cubeVertexBuffer, colorBuffer, matrixBuffer].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderUtils.drawPrimitives(renderEncoder: renderEncoder, vertexCount: renderUtils.numVerticesInACube())

    }
}
