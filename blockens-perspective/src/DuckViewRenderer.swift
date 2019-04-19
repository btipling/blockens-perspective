//
//  DuckViewRenderer.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/23/16.
//  Copyright © 2016 apphacker. All rights reserved.
//


import Foundation
import MetalKit


class DuckRenderer: Renderer, RenderController {
    
    var renderUtils: RenderUtils!
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var meshes: [MTKMesh] = Array()
    var materials: [MTLBuffer] = Array()
    let vertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
    
    var matrixBuffer: MTLBuffer! = nil
    var duckInfo: RenderUtils.Object3DInfo! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }
    
    func loadDuck(device: MTLDevice, pipelineStateDescriptor: MTLRenderPipelineDescriptor) {
        let path = Bundle.main.path(forResource: "duck", ofType: "obj", inDirectory: "Data/assets/models")
        if(path == nil) {
            print("Could not find duck.")
        } else {
            print("Found the duck.")
        }
        let assetURL = URL(fileURLWithPath: path!)
        
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = 12
        vertexDescriptor.layouts[0].stepRate = 1;
        vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex;
        
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        let attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: desc, bufferAllocator: bufferAllocator)
        let pointer: UnsafeMutablePointer<NSArray>? = UnsafeMutablePointer<NSArray>.allocate(capacity: 1)
        let autopointer: AutoreleasingUnsafeMutablePointer<NSArray?>? = AutoreleasingUnsafeMutablePointer<NSArray?>.init(pointer!)
        do {
            try meshes = MTKMesh.newMeshes(asset: asset, device: device).metalKitMeshes
        } catch let error {
            print("Unable to load mesh for duck: \(error)")
        }
        let memory_array: NSArray? = pointer!.pointee
        var model_meshes: [MDLMesh] = Array()
        for data in memory_array! {
            model_meshes.append(data as! MDLMesh)
        }
        print("mdlmesh \(model_meshes)")
        materials = renderUtils.meshesToMaterialsBuffer(device: device, meshes: model_meshes)
        print("done loading meshe for duck")
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        let pipelineStateDescriptor = renderUtils.createPipelineStateDescriptor(vertex: "duckVertex", fragment: "duckFragment", device: device, view: view)
        loadDuck(device: device, pipelineStateDescriptor: pipelineStateDescriptor);
        pipelineState = renderUtils.createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
        matrixBuffer = renderUtils.createMatrixBuffer(device: device, label: "Duck matrix")

        duckInfo = RenderUtils.Object3DInfo(
            rotation: [0.0, 0.0, 0.0],
            scale: [5.0, 5.0, 5.0],
            position: [0.0, 20.0, 0.0])
        
        update()
        print("loading Duck assets done")
    }
    
    func update() {
        renderUtils.updateMatrixBuffer(buffer: matrixBuffer, object3DInfo: duckInfo)
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Duck")
        
        let _ = renderUtils.drawIndexedPrimitives(renderEncoder: renderEncoder, meshes: meshes, materials: materials, vertexBuffers: [matrixBuffer])
        
    }
}
