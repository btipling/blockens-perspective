//
//  Sky.metal
//  blockens
//
//  Created by Bjorn Tipling on 9/5/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct GroundInfo {
    float xRotation;
    float yRotation;
    float zRotation;
    float xScale;
    float yScale;
};

vertex VertextOut GroundVertex(uint vid [[ vertex_id ]],
                            constant packed_float2* position  [[ buffer(0) ]]) {
    
    VertextOut outVertex;
    
    float2 pos = position[vid];
    outVertex.position = float4(pos[0], pos[1], 0.0, 1.0);
    return outVertex;
}

fragment float4 GroundFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(183, 132, 2);
}