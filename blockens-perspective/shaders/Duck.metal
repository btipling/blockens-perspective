//
//  Duck.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/23/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex CubeOut duckVertex(const CubeIn vertices [[stage_in]],
                            constant float4x4* matrix [[ buffer(1) ]],
                            constant Color* color [[ buffer(2) ]]) {
    
    CubeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    outVertex.color = toFloat4(color->color);
    return outVertex;
}

fragment float4 duckFragment(CubeOut inFrag [[stage_in]]) {
    
//    return float4(1.0, 1.0, 0.0, 1.0);
    return inFrag.color;
}
