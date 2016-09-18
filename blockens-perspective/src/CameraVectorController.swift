//
//  CameraVectorController.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation

class CameraVectorController: RenderController {
    
    fileprivate var _renderer: CameraVectorRenderer! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        _renderer = CameraVectorRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }
    
    func update(_ frameInfo: FrameInfo) {
        _renderer.update(cameraRotation: []);
    }
}
