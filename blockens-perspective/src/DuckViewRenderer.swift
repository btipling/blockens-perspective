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
    var submeshes: [MDLSubmesh] = Array()
    let vertexDescriptor: MTLVertexDescriptor = MTLVertexDescriptor()
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        self.renderUtils = renderUtils
    }
    
    func renderer() -> Renderer {
        return self
    }
    
    func loadDuck(device: MTLDevice, pipelineStateDescriptor: MTLRenderPipelineDescriptor) {
        let path = Bundle.main.path(forResource: "duck", ofType: "obj", inDirectory: "Data/assets")
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
            try meshes = MTKMesh.newMeshes(from: asset, device: device, sourceMeshes: autopointer)
        } catch let error {
            print("Unable to load mesh for duck: \(error)")
        }
        let memory_array: NSArray? = pointer!.pointee
        var model_meshes: [MDLMesh] = Array()
        for data in memory_array! {
            model_meshes.append(data as! MDLMesh)
        }
        print("mdlmesh \(model_meshes)")
        for mesh in model_meshes {
            guard let submeshes_ = mesh.submeshes else {
                print("no submshes")
                continue
            }
            for submesh_ in submeshes_ {
                
                print("submesh is \(submesh_)")
                let submesh = submesh_ as! MDLSubmesh
                submeshes.append(submesh)
                print("submesh's name is \(submesh.name)")
               
                let specularColor = submesh.material?.property(with: MDLMaterialSemantic.baseColor)
                var material = RenderUtils.MaterialUniform(color: float3(0.0, 0.0, 0.0))
                if let color = specularColor {
                    material.color = float3(color.float3Value.x, color.float3Value.y, color.float3Value.z)
                    print("Found diffuse color: \(color.float3Value)")
                } else {
                    print("no diffuse")
                }
                materials.append(renderUtils.materialToBuffer(device: device, material: material, label: submesh.name))
                

            }
        }
        print("done loading meshe for duck")
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        let pipelineStateDescriptor = renderUtils.createPipelineStateDescriptor(vertex: "duckVertex", fragment: "duckFragment", device: device, view: view)
        loadDuck(device: device, pipelineStateDescriptor: pipelineStateDescriptor);
        pipelineState = renderUtils.createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
        
        print("loading Duck assets done")
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Duck")
        
        
        renderUtils.drawIndexedPrimitives(renderEncoder: renderEncoder, meshes: meshes, materials: materials)
        
    }
}
