//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class CubeController: RenderController {

    fileprivate var _renderer: CubeRenderer! = nil

    func setRenderUtils(_ renderUtils: RenderUtils) {
        _renderer = CubeRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }

    func update(_ frameInfo: FrameInfo) {
        _renderer.update(frameInfo);
    }
}
