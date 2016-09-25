//
//  Duck.metal
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/23/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct VertexIn {
    float3 position [[attribute(0)]];
};

struct Color {
    packed_float3 color;
};

vertex CubeOut duckVertex(const VertexIn vertices [[stage_in]],
                             constant RenderInfo* renderInfo [[ buffer(1) ]],
                             constant Color* color [[ buffer(2) ]]) {
    
    CubeOut outVertex;
    
    
    // ## Set up vectors.
    ModelViewData modelViewData = {
        .positionVertex = toFloat4(vertices.position),
        .scale = float4(5.0, 5.0, 5.0, 1.0),
        .rotationVertex = zeroVector(),
        .translationVertex = float4(0.0, 20.0, 0.0, 1.0),
        .renderInfo = renderInfo
    };
    
    float4 screenCoordinates = toScreenCoordinates(modelViewData);
    
    
    outVertex.position = screenCoordinates;
    outVertex.color = toFloat4(color->color);
    return outVertex;
}

fragment float4 duckFragment(CubeOut inFrag [[stage_in]]) {
    
//    return float4(1.0, 1.0, 0.0, 1.0);
    return inFrag.color;
}
