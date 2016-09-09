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
    float3 position;
};

vertex VertextOut GroundVertex(uint vid [[ vertex_id ]],
                               constant packed_float3* position  [[ buffer(0) ]],
                               constant GroundInfo* groundInfo [[ buffer(1)]],
                               constant RenderInfo* renderInfo [[ buffer(2) ]]) {
    
    VertextOut outVertex;
    
    // ## Setup vectors.
    
    float4 positionVertex = toFloat4(position[vid]);
//    
//    float4 scale = toFloat4(groundInfo->scale);
//    float4 rotation = toFloat4(groundInfo->rotation);
//    float4 translation = toFloat4(groundInfo->position);
//  
//    // ## Setup matrices.
//    
//    float4x4 perspectiveMatrix = perspectiveProjection(renderInfo);
//    float4x4 objectTransformationMatrix_ = objectTransformationMatrix(scale, rotation, translation);
//    
//    // ## Do the matrix multiplications.
//    float4x4 transformMatrix = matrixProduct4x4(perspectiveMatrix, objectTransformationMatrix_);
//    
//    // Perspective projection.
//    float4 screenCoordinates = transform4x4(transformMatrix, positionVertex);
//    
//    outVertex.position = screenCoordinates;
    outVertex.position = positionVertex;

    return outVertex;
}

fragment float4 GroundFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(78, 183, 2);
}