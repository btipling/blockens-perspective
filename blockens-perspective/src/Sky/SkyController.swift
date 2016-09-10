//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SkyController: RenderController {

    fileprivate var _renderer: SkyRenderer! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        _renderer = SkyRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }
}
