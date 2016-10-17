//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class CubeRenderer: Renderer, RenderController {

    var renderUtils: RenderUtils!

    var pipelineState: MTLRenderPipelineState! = nil
    
    var meshes: [MTKMesh] = Array()
    var materials: [MTLBuffer] = Array()
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
    
    func loadCube(device: MTLDevice, view: MTKView) -> MTLRenderPipelineDescriptor {
        
        let pipelineStateDescriptor = renderUtils.createPipelineStateDescriptor(vertex: "cubeVertex", fragment: "cubeFragment", device: device, view: view)
        let numSegments: vector_uint3 = vector_uint3(1)
        let allocator = MTKMeshBufferAllocator.init(device: device)
        let dimension: Float32 = 1.5
        let boxMesh = MDLMesh.newBox(
            withDimensions: float3(dimension, dimension, dimension),
            segments: numSegments,
            geometryType: MDLGeometryType.triangles,
            inwardNormals: false,
            allocator: allocator)
        do {
            try meshes = [MTKMesh.init(mesh: boxMesh, device: device)]
        } catch let error {
            print("Unable to load mesh for new box: \(error)")
        }
        materials = renderUtils.meshesToMaterialsBuffer(device: device, meshes: [boxMesh])
        pipelineStateDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(boxMesh.vertexDescriptor)
        return pipelineStateDescriptor
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        let pipelineStateDescriptor = loadCube(device: device, view: view)
        pipelineState = renderUtils.createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
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
        
        let vertexBuffers: [MTLBuffer] = [matrixBuffer, colorBuffer]
        let _ = renderUtils.drawIndexedPrimitives(renderEncoder: renderEncoder, meshes: meshes, materials: materials, vertexBuffers: vertexBuffers)

    }
}
