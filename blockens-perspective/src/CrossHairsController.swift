//
//  CrossHairsController.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//


import Foundation

class CrossHairsController: RenderController {
    
    fileprivate var _renderer: CrossHairsRenderer! = nil
    
    func setRenderUtils(_ renderUtils: RenderUtils) {
        _renderer = CrossHairsRenderer(utils: renderUtils)
    }
    
    func renderer() -> Renderer {
        return _renderer
    }
}
