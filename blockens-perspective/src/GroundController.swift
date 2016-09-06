//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class GroundController: RenderController {
    
    private var _renderer: GroundRenderer! = nil
    
    func setRenderUtils(renderUtils: RenderUtils) {
        _renderer = GroundRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }
}
