//
//  Sky.metal
//  blockens
//
//  Created by Bjorn Tipling on 9/5/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct GroundInfo {
    float3 rotation;
    float3 scale;
};

vertex VertextOut GroundVertex(uint vid [[ vertex_id ]],
                               constant packed_float3* position  [[ buffer(0) ]],
                               constant GroundInfo* groundInfo [[ buffer(1)]],
                               constant RenderInfo* renderInfo [[ buffer(2) ]]) {
    
    VertextOut outVertex;
    
    float3 positionVertex = position[vid];
    float3 worldVector = float3(0.0, 0.0, 0.0);
    
    float3 groundRotationVertex = groundInfo->rotation;

    float3 scaleVertex = scaleVector(positionVertex, groundInfo->scale);
    float3 transformedPositionVertex = rotate3D(scaleVertex, groundRotationVertex);
    float4 translatedVertex = translationMatrix(transformedPositionVertex, worldVector);
    float4 screenCoordinates = orthoGraphicProjection(translatedVertex, renderInfo);

    outVertex.position = screenCoordinates;

    return outVertex;
}

fragment float4 GroundFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(183, 132, 2);
}