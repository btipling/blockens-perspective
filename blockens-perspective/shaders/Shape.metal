//
//  cube.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex CubeOut cubeVertex(uint vid [[ vertex_id ]],
                          const CubeIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant float4* colors [[ buffer(2) ]]) {

    CubeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    
    uint face = vid / 4;
    outVertex.color = colors[face % 6];
    
    return outVertex;
}

vertex CubeOut sphereVertex(uint vid [[ vertex_id ]],
                          const CubeIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant float4* colors [[ buffer(2) ]]) {
    
    CubeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    
    uint face = vid > 700 ? 0 : 1;
    outVertex.color = colors[face];
    
    return outVertex;
}

fragment float4 cubeFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}

fragment float4 sphereFragment(CubeOut inFrag [[stage_in]]) {
    return float4(0.5, 0.0, 1.0, 1.0);
}



