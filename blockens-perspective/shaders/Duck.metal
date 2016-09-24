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

vertex VertextOut duckVertex(const VertexIn vertices [[stage_in]],
                             constant RenderInfo* renderInfo [[ buffer(1) ]]) {
    
    VertextOut outVertex;
    
    
    // ## Set up vectors.
    ModelViewData modelViewData = {
        .positionVertex = toFloat4(vertices.position),
        .scale = float4(10.0, 10.0, 10.0, 1.0),
        .rotationVertex = zeroVector(),
        .translationVertex = float4(0.0, 55.0, 0.0, 1.0),
        .renderInfo = renderInfo
    };
    
    float4 screenCoordinates = toScreenCoordinates(modelViewData);
    
    
    outVertex.position = screenCoordinates;
    return outVertex;
}

fragment float4 duckFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(255, 184, 223);
}
