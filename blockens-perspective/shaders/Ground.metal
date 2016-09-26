//
//  Sky.metal
//  blockens
//
//  Created by Bjorn Tipling on 9/5/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertextOut GroundVertex(uint vid [[ vertex_id ]],
                               constant float3* position  [[ buffer(0) ]],
                               constant Object3DInfo* groundInfo [[ buffer(1)]],
                               constant RenderInfo* renderInfo [[ buffer(2) ]]) {
    
    VertextOut outVertex;
  
    // ## Set up vectors.
    ModelViewData modelViewData = {
        .positionVertex = toFloat4(position[vid]),
        .scale = toFloat4(groundInfo->scale),
        .rotationVertex = toFloat4(groundInfo->rotation),
        .translationVertex = toFloat4(groundInfo->position),
        .renderInfo = renderInfo
    };
    
    float4 screenCoordinates = toScreenCoordinates(modelViewData);
    
    outVertex.position = screenCoordinates;

    return outVertex;
}

fragment float4 GroundFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(78, 183, 2);
}
