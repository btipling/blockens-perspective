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
                               constant float4x4* matrix [[ buffer(1) ]]) {
    
    VertextOut outVertex;
    
    outVertex.position = toFloat4(position[vid]) * *matrix;

    return outVertex;
}

fragment float4 GroundFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(78, 183, 2);
}
