//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class GroundController: RenderController {
    
    fileprivate var _renderer: GroundRenderer! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        _renderer = GroundRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }
}
