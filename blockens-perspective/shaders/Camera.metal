//
//  Camera.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex CubeOut cameraVertex(uint vid [[ vertex_id ]],
                          constant packed_float3* position  [[ buffer(0) ]],
                          constant Object3DInfo* cameraInfo [[ buffer(1)]],
                          constant RenderInfo* renderInfo [[ buffer(2) ]]) {
    
    CubeOut outVertex;
    
    // ## Set up vectors.
    ModelViewData modelViewData = {
        .positionVertex = toFloat4(position[vid]),
        .scale = toFloat4(cameraInfo->scale),
        .rotationVertex = toFloat4(cameraInfo->rotation),
        .translationVertex = toFloat4(cameraInfo->position),
        .renderInfo = renderInfo
    };

    
    float4 screenCoordinates = toScreenCoordinates(modelViewData);
    
    // Set up the output.
    outVertex.position = screenCoordinates;
    
    return outVertex;
}

fragment float4 cameraFragment(CubeOut inFrag [[stage_in]]) {
    return float4(1.0, 0.0, 0.0, 1.0);
}
