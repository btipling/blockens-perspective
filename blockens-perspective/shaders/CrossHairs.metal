//
//  CrossHairs.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertextOut crossHairsVertex(uint vid [[ vertex_id ]],
                                   constant packed_float2* position  [[ buffer(0) ]],
                                   constant RenderInfo* renderInfo [[ buffer(1) ]]) {
    
    VertextOut outVertex;
    
    float2 winResolution = renderInfo->winResolution;
    
    float pixelSize = 1/winResolution.x; // Resolution for cross hairs bound to x.
    
    float2 pos = position[vid] * pixelSize * 25;
    
    float pos1 = pos[0];
    float pos2 = pos[1] * winResolution.x/winResolution.y;
    
    outVertex.position = float4(pos1, pos2, 0.0, 1.0);
    return outVertex;
}

fragment float4 crossHairsFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(30, 30, 30);
}
