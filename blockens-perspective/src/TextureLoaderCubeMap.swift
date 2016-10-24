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
    
    init (name: String, renderUtils: RenderUtils) {
        self.name = name
        self.renderUtils = renderUtils
    }
    
    func load(device: MTLDevice) {
        
        if (texture != nil) {
            // Already loaded texture.
            return
        }
      
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
        let descriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: firstTexture!.pixelFormat, size: 4096, mipmapped: false)
        texture = device.makeTexture(descriptor: descriptor)
        for (index, currentSide) in textures.enumerated() {
            let origin = MTLOrigin(x: 0, y: 0, z: 0)
            let size = MTLSize(width: currentSide.width, height: currentSide.height, depth: currentSide.depth)
            let bytesPerRow = 8 * currentSide.width
            let imageSize = bytesPerRow * currentSide.height
            let region = MTLRegion(origin: origin, size: size)
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
        }
    }
    
}
