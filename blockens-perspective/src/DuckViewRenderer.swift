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
    
    var meshes: [MTKMesh]!
    var DuckVertexBuffer: MTLBuffer! = nil
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
        
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        vertexDescriptor.layouts[0].stride = 12
        
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        let attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: desc, bufferAllocator: bufferAllocator)
        do {
            try meshes = MTKMesh.newMeshes(from: asset, device: device, sourceMeshes: nil)
        } catch let error {
            print("Unable to load mesh for duck: \(error)")
        }
    }
    
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        
        let pipelineStateDescriptor = renderUtils.createPipelineStateDescriptor(vertex: "duckVertex", fragment: "duckFragment", device: device, view: view)
        loadDuck(device: device, pipelineStateDescriptor: pipelineStateDescriptor);
        pipelineState = renderUtils.createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
        DuckVertexBuffer = renderUtils.createRectangleVertexBuffer(device: device, bufferLabel: "Duck vertices")
        
        print("loading Duck assets done")
    }
    
    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        
        renderUtils.setPipeLineState(renderEncoder: renderEncoder, pipelineState: pipelineState, name: "Duck")
        
        renderEncoder.setVertexBuffer(renderUtils.renderInfoBuffer(), offset: 0, at: 1)
        
        renderUtils.drawIndexedPrimitives(renderEncoder: renderEncoder, meshes: meshes)
        
    }
}
