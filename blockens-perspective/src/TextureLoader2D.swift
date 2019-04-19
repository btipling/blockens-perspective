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
        
        texture = renderUtils.loadImageIntoTexture(device: device, name: name)
    }
    
    func loadInto(renderEncoder: MTLRenderCommandEncoder) {
        if texture != nil {
            renderEncoder.setFragmentTexture(texture!, index: 0)
        }
    }

}
