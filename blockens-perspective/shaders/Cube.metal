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
                                     constant float4x4* matrix) {

    CubeOut outVertex;
    
    outVertex.position = toFloat4(position[vid]) * *matrix;
    
    uint face = vid / 6;
    float4 color = colors[face];
    outVertex.color = color;

    return outVertex;
}

fragment float4 cubeFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}
