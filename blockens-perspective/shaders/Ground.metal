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
    
    float4 positionVertex = toFloat4(position[vid]);
    float4 scale = toFloat4(groundInfo->scale);
    float4 rotation = toFloat4(groundInfo->rotation);
    float4 translation = toFloat4(groundInfo->position);
  
    // ## Setup matrices.
    
    float4x4 scaleMatrix = scaleVector(scale);
    
    float4x4 rotationXMatrix = rotateX(rotation);
    float4x4 rotationYMatrix = rotateY(rotation);
    float4x4 rotationZMatrix = rotateZ(rotation);
    
    float4x4 translationMatrix_ = translationMatrix(translation);
    float4x4 perspectiveMatrix = perspectiveProjection(renderInfo);
    
    // ## Do the matrix multiplications.
    
    // Scale.
    float4 transformationProduct = transform4x4(positionVertex, scaleMatrix);
    
    // Rotate.
    transformationProduct = transform4x4(transformationProduct, rotationXMatrix);
    transformationProduct = transform4x4(transformationProduct, rotationYMatrix);
    transformationProduct = transform4x4(transformationProduct, rotationZMatrix);
    
    // Translate.
    transformationProduct = transform4x4(transformationProduct, translationMatrix_);
    
    // Perspective projection.
    float4 screenCoordinates = transform4x4(transformationProduct, perspectiveMatrix);
    
    outVertex.position = screenCoordinates;

    return outVertex;
}

fragment float4 GroundFragment(VertextOut inFrag [[stage_in]]) {
    
    return rgbaToNormalizedGPUColors(78, 183, 2);
}