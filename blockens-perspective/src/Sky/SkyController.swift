//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SkyController: RenderController {

    private var _renderer: SkyRenderer! = nil
    
    func setRenderUtils(renderUtils: RenderUtils) {
        _renderer = SkyRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }
}
