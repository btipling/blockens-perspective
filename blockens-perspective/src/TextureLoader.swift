//
//  TextureLoader.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 10/23/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

protocol TextureLoader {
    func load(device: MTLDevice)
    func loadInto(renderEncoder: MTLRenderCommandEncoder)
}
