//
//  cube.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex CubeOut cubeVertex(uint vid [[ vertex_id ]],
                          const VertexIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant float4* colors [[ buffer(2) ]]) {

    CubeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    
    outVertex.color = float4(0.5, 0.0, 1.0, 1.0);
    uint face = vid / 4;
    outVertex.color = colors[face % 6];
    
    return outVertex;
}

fragment float4 cubeFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}
