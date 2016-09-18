//
//  CameraVector.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertextOut cameraVectorVertex(uint vid [[ vertex_id ]],
                                     constant packed_float3* position  [[ buffer(0) ]],
                                     constant RenderInfo* renderInfo [[ buffer(1) ]]) {
    
    VertextOut outVertex;
    
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
    
    outVertex.position = screenCoordinates;
    return outVertex;
}

fragment float4 cameraVectorFragment(VertextOut inFrag [[stage_in]]) {
    
    return float4(1.0, 0.0, 0.0, 1.0);
}
