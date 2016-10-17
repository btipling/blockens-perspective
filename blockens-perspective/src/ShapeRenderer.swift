//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class ShapeRenderer: Renderer, RenderController {
    
    enum ShapeType {
        case Cube
        case Plane
        case Sphere
    }

    var renderUtils: RenderUtils!

    var pipelineState: MTLRenderPipelineState! = nil
    
    var meshes: [MTKMesh] = Array()
    var materials: [MTLBuffer] = Array()
    var colorBuffer: MTLBuffer! = nil
    var matrixBuffer: MTLBuffer! = nil
    var ShapeInfo: RenderUtils.Object3DInfo! = nil
    
    let colors: [float4]
    let scale: float3
    let shapeType: ShapeType
    

    init (colors: [float4], scale: float3, shapeType: ShapeType) {
        self.colors = colors
        self.scale = scale
        self.shapeType = shapeType
    }
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }
    
    func loadShape(device: MTLDevice, view: MTKView) -> MTLRenderPipelineDescriptor {
        
        let allocator = MTKMeshBufferAllocator.init(device: device)
        let dimension: Float32 = 2.0
        
        var mesh: MDLMesh! = nil
        var vertexName = ""
        var fragmentName = ""
        
        switch shapeType {
        case .Cube:
            vertexName = "cubeVertex"
            fragmentName = "cubeFragment"
            mesh = MDLMesh.newBox(withDimensions: float3(dimension, dimension, dimension),
                                  segments: vector_uint3(1, 1, 1),
                                  geometryType: MDLGeometryType.triangles,
                                  inwardNormals: false,
                                  allocator: allocator)
        case .Plane:
            vertexName = "cubeVertex"
            fragmentName = "cubeFragment"
            mesh = MDLMesh.newBox(withDimensions: float3(dimension, dimension, 0.0),
                                  segments: vector_uint3(1, 1, 1),
                                  geometryType: MDLGeometryType.triangles,
                                  inwardNormals: false,
                                  allocator: allocator)
        default:
            print("Unsupported shape type")
        }
        
        do {
            try meshes = [MTKMesh.init(mesh: mesh, device: device)]
        } catch let error {
            print("Unable to load mesh for new box: \(error)")
        }
        
        materials = renderUtils.meshesToMaterialsBuffer(device: device, meshes: [mesh])
        
        
        let pipelineStateDescriptor = renderUtils.createPipelineStateDescriptor(vertex: vertexName, fragment: fragmentName, device: device, view: view)
        pipelineStateDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        return pipelineStateDescriptor
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        let pipelineStateDescriptor: MTLRenderPipelineDescriptor
            pipelineStateDescriptor = loadShape(device: device, view: view)
        pipelineState = renderUtils.createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
        colorBuffer = renderUtils.createColorBuffer(device: device, colors: colors, label: "Shape colors")
        matrixBuffer = renderUtils.createMatrixBuffer(device: device, label: "Shape matrix")
        
    }

    func update(rotation: float3, position: float3, scale: float3?=nil) {
        
        ShapeInfo = RenderUtils.Object3DInfo(
            rotation: rotation,
            scale: scale ?? self.scale,
            position: position)
    }
    
    func update() {
        guard let objectCopy = ShapeInfo else {
            return
        }
        renderUtils.updateMatrixBuffer(buffer: matrixBuffer, object3DInfo: objectCopy)
    }


    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Shape")
        
        let vertexBuffers: [MTLBuffer] = [matrixBuffer, colorBuffer]
        let _ = renderUtils.drawIndexedPrimitives(renderEncoder: renderEncoder, meshes: meshes, materials: materials, vertexBuffers: vertexBuffers)

    }
}
