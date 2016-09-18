//
//  CameraVector.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/16/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex VertextOut cameraVectorVertex(uint vid [[ vertex_id ]],
                            constant packed_float3* position  [[ buffer(0) ]]) {
    
    VertextOut outVertex;
    
    float3 pos = position[vid];
    outVertex.position = toFloat4(pos);
    return outVertex;
}

fragment float4 cameraVectorFragment(VertextOut inFrag [[stage_in]]) {
    
    return float4(1.0, 0.0, 0.0, 1.0);
}
