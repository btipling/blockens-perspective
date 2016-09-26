//
//  cube.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex CubeOut cubeVertex(uint vid [[ vertex_id ]],
                                     constant float3* position  [[ buffer(0) ]],
                                     constant float4* colors  [[ buffer(1) ]],
                                     constant Object3DInfo* cubeInfo [[ buffer(2)]],
                                     constant RenderInfo* renderInfo [[ buffer(3) ]]) {

    CubeOut outVertex;

    // ## Set up vectors.
    ModelViewData modelViewData = {
        .positionVertex = toFloat4(position[vid]),
        .scale = toFloat4(cubeInfo->scale),
        .rotationVertex = toFloat4(cubeInfo->rotation),
        .translationVertex = toFloat4(cubeInfo->position),
        .renderInfo = renderInfo
    };

    float4 screenCoordinates = toScreenCoordinates(modelViewData);
    
    // Set up the output.
    outVertex.position = screenCoordinates;
    
    uint face = vid / 6;
    float4 color = colors[face];
    outVertex.color = color;

    return outVertex;
}

fragment float4 cubeFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}
