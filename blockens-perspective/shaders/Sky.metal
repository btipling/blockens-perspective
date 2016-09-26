//
//  Sky.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertextOut skyVertex(uint vid [[ vertex_id ]],
                                     constant float3* position  [[ buffer(0) ]]) {

    VertextOut outVertex;

    float3 pos = position[vid];
    outVertex.position = float4(pos[0], pos[1], 0.9999, 1.0);
    return outVertex;
}

fragment float4 skyFragment(VertextOut inFrag [[stage_in]]) {

    return rgbaToNormalizedGPUColors(116, 184, 223);
}
