//
//  CameraVector.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex CubeOut cameraVectorVertex(uint vid [[ vertex_id ]],
                                     constant packed_float3* position  [[ buffer(0) ]],
                                     constant packed_float4* colors  [[ buffer(1) ]],
                                     constant RenderInfo* renderInfo [[ buffer(2) ]]) {
    
    CubeOut outVertex;
    
    float4 screenCoordinates = toFloat4(position[vid]);
    
    // ## Set up vectors.
    ModelViewData modelViewData = {
        .positionVertex = screenCoordinates,
        .scale = identityVector(),
        .rotationVertex = toFloat4(renderInfo->cameraRotation),
        .translationVertex = toFloat4(renderInfo->cameraTranslation),
        .renderInfo = renderInfo
    };
    
    screenCoordinates = toScreenCoordinates(modelViewData);
    
    uint face = vid / 2;
    float4 color = colors[face];
    outVertex.color = color;
    outVertex.position = screenCoordinates;
    return outVertex;
}

fragment float4 cameraVectorFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}
