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
        case Hemisphere
    }
    
    struct ShapeInfo {
        let colors: [float4]
        let numSides: uint4
    }

    var renderUtils: RenderUtils!

    var pipelineState: MTLRenderPipelineState! = nil
    
    var meshes: [MTKMesh] = Array()
    var materials: [MTLBuffer] = Array()
    var shapeInfoBuffer: MTLBuffer! = nil
    var colorBuffer: MTLBuffer! = nil
    var matrixBuffer: MTLBuffer! = nil
    var object3DInfo: RenderUtils.Object3DInfo! = nil
    
    private var textureLoader: TextureLoader? = nil
    
    let colors: [float4]
    let scale: float3
    let shapeType: ShapeType
    let inward: Bool
    let translate: Bool
    var vertexName = "shapeVertex"
    var fragmentName = "shapeFragment"
    

    init (colors: [float4], scale: float3, shapeType: ShapeType, textureLoader: TextureLoader?=nil, inward: Bool=false, translate: Bool=true) {
        self.colors = colors
        self.scale = scale
        self.shapeType = shapeType
        self.inward = inward
        self.translate = translate
        self.textureLoader = textureLoader
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
        
        switch shapeType {
        case .Cube:
            mesh = MDLMesh.newBox(withDimensions: float3(dimension, dimension, dimension),
                                  segments: vector_uint3(1, 1, 1),
                                  geometryType: MDLGeometryType.triangles,
                                  inwardNormals: inward,
                                  allocator: allocator)
        case .Plane:
            mesh = MDLMesh.newBox(withDimensions: float3(dimension, dimension, 0.0),
                                  segments: vector_uint3(1, 1, 1),
                                  geometryType: MDLGeometryType.triangles,
                                  inwardNormals: false,
                                  allocator: allocator)
        case .Sphere:
            fallthrough
        case .Hemisphere:
            let sphereDimension: Float32 = 2.0
            mesh = MDLMesh.newEllipsoid(withRadii: float3(sphereDimension, sphereDimension, sphereDimension),
                                        radialSegments: 40,
                                        verticalSegments: 40,
                                        geometryType: MDLGeometryType.triangles,
                                        inwardNormals: inward,
                                        hemisphere: shapeType == .Hemisphere,
                                        allocator: allocator)
        }
        
        if let textureLoader = self.textureLoader {
            textureLoader.load(device: device)
        }
        
        do {
            try meshes = [MTKMesh.init(mesh: mesh, device: device)]
        } catch let error {
            print("Unable to load mesh for new box: \(error)")
        }
        materials = renderUtils.meshesToMaterialsBuffer(device: device, meshes: [mesh])
        let meshDescriptor = mesh.vertexDescriptor
        let attributes = meshDescriptor.attributes
        let tc = mesh.vertexAttributeData(forAttributeNamed: "textureCoordinate")!
        let map = tc.map
        switch(tc.format) {
        case .float2:
            print("float2")
        case .float3:
            print("float3")
        case .float4:
            print("float4")
        case .half3:
            print("half3")
        default:
            print("nope")
        }
        
        
        let pipelineStateDescriptor = renderUtils.createPipelineStateDescriptor(vertex: vertexName, fragment: fragmentName, device: device, view: view)
        pipelineStateDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        let attributes3 = pipelineStateDescriptor.vertexDescriptor!.attributes[2]
        print(attributes3!.format)
        return pipelineStateDescriptor
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        let pipelineStateDescriptor: MTLRenderPipelineDescriptor
            pipelineStateDescriptor = loadShape(device: device, view: view)
        pipelineState = renderUtils.createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
        colorBuffer = renderUtils.createColorBuffer(device: device, colors: colors, label: "Color shape buffer")
        loadShapeInfo(device: device)
        matrixBuffer = renderUtils.createMatrixBuffer(device: device, label: "Shape matrix")
        
    }
    
    func loadShapeInfo(device: MTLDevice) {
        
        var numSides = self.numSides()
        
        let uint4Size = MemoryLayout<uint4>.size
        let bufferSize = uint4Size
        
        let buffer = device.makeBuffer(length: bufferSize, options: [])!
        buffer.label = "Shape info"
        let pointer = buffer.contents()
        memcpy(pointer, &numSides, uint4Size)
        shapeInfoBuffer = buffer
    }
    
    func numSides() -> uint4 {
        switch shapeType {
        case .Cube:
                return uint4(6)
        default:
                return uint4(0)
        }
    }

    func update(rotation: float3, position: float3, scale: float3?=nil) {
        
        object3DInfo = RenderUtils.Object3DInfo(
            rotation: rotation,
            scale: scale ?? self.scale,
            position: position)
    }
    
    func update() {
        guard let objectCopy = object3DInfo else {
            return
        }
        renderUtils.updateMatrixBuffer(buffer: matrixBuffer, object3DInfo: objectCopy, translate: translate)
    }


    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Shape")
        
        var changedWindingOrder = false
        // Inward pointing spheres require changing the winding order.
        if shapeType == .Sphere && inward && renderUtils.windingOrder != .counterClockwise {
            renderEncoder.setFrontFacing(.counterClockwise)
            changedWindingOrder = true
        }
        
        textureLoader?.loadInto(renderEncoder: renderEncoder)
        
        let vertexBuffers: [MTLBuffer] = [matrixBuffer, shapeInfoBuffer, colorBuffer]
        let _ = renderUtils.drawIndexedPrimitives(renderEncoder: renderEncoder, meshes: meshes, materials: materials, vertexBuffers: vertexBuffers)
        
        if (changedWindingOrder) {
            renderEncoder.setFrontFacing(renderUtils.windingOrder)
        }

    }
}
