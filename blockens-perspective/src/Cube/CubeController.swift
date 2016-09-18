//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class CubeController: RenderController {

    fileprivate var _renderer: CubeRenderer! = nil
    
    let colors: [Float32]
    let scale: [Float32]
    
    init (colors: [Float32], scale: [Float32]) {
        self.colors = colors
        self.scale = scale
    }

    func setRenderUtils(_ renderUtils: RenderUtils) {
        _renderer = CubeRenderer(utils: renderUtils, colors: colors, scale: scale)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }

    func update(rotation: [Float32], position: [Float32])  {
        _renderer.update(rotation: rotation, position: position);
    }
}
