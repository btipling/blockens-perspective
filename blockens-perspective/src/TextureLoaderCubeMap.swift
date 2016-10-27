//
//  TextureLoaderCubeMap.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 10/23/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class TextureLoaderCubeMap: TextureLoader {
    
    private let name: String
    private let renderUtils: RenderUtils
    private var texture: MTLTexture?
    private var sampler: MTLSamplerState?
    
    init (name: String, renderUtils: RenderUtils) {
        self.name = name
        self.renderUtils = renderUtils
    }
    
    func load(device: MTLDevice) {
        
        if (texture != nil) {
            // Already loaded texture.
            return
        }
        
        // Load sampler
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.magFilter = MTLSamplerMinMagFilter.linear
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)
      
        // Load texture
        
        let sides = [
            "posx",
            "negx",
            "posy",
            "negy",
            "posz",
            "negz",
        ]
        
        var textures: [MTLTexture] = []
        for side in sides {
            if let texture = renderUtils.loadImageIntoTexture(device: device, name: "\(name)_\(side)") {
                textures.append(texture)
            } else {
                return
            }
        }
        let firstTexture = textures.first
        let descriptor = MTLTextureDescriptor()
        
        descriptor.pixelFormat = firstTexture!.pixelFormat
        descriptor.textureType = MTLTextureType.type2DArray
        descriptor.width = 4096
        descriptor.height = 4096
        descriptor.mipmapLevelCount = 1
        descriptor.arrayLength = 6
        texture = device.makeTexture(descriptor: descriptor)
        
        for (index, currentSide) in textures.enumerated() {
            let bytesPerRow = 4 * currentSide.width
            let imageSize = bytesPerRow * currentSide.height
            let region = MTLRegionMake2D(0, 0, currentSide.width, currentSide.height)
            let pointer = UnsafeMutableRawPointer.allocate(bytes: imageSize, alignedTo: 4)
            let roPointer = UnsafeRawPointer.init(pointer)
            print("rowBytes: \(bytesPerRow)")
            currentSide.getBytes(pointer, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
            texture!.replace(region: region, mipmapLevel: 0, slice: index, withBytes: roPointer, bytesPerRow: bytesPerRow, bytesPerImage: imageSize)
        }
        
        
    }
    
    func loadInto(renderEncoder: MTLRenderCommandEncoder) {
        if texture != nil {
            renderEncoder.setFragmentTexture(texture!, at: 0)
            if (sampler != nil) {
                renderEncoder.setFragmentSamplerState(sampler, at: 0)
            }
        }
    }
    
}
