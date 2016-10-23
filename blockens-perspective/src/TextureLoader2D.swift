//
//  TextureLoader2D.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 10/23/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class TextureLoader2D: TextureLoader {
    
    private let name: String
    private var texture: MTLTexture?
    
    init (name: String) {
        self.name = name
    }
    
    internal func load(device: MTLDevice) {
        
        if (texture != nil) {
            // Already loaded texture.
            return
        }
        
        var image = NSImage(named: name)!
        
        image = flipImage(image)
        var imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!
        let textureLoader = MTKTextureLoader(device: device)
        do {
            texture = try textureLoader.newTexture(with: imageRef, options: .none)
        } catch {
            print("Got an error trying to texture \(error)")
        }
    }
    
    internal func loadInto(renderEncoder: MTLRenderCommandEncoder) {
        if texture != nil {
            renderEncoder.setFragmentTexture(texture!, at: 0)
        }
    }

}
