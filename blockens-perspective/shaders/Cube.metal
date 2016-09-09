//
//  cube.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

struct CubeInfo {
    float xRotation;
    float yRotation;
    float zRotation;
    float xPos;
    float yPos;
    float zPos;
};

vertex CubeOut cubeVertex(uint vid [[ vertex_id ]],
                                     constant packed_float3* position  [[ buffer(0) ]],
                                     constant packed_float3* colors  [[ buffer(1) ]],
                                     constant CubeInfo* cubeInfo [[ buffer(2)]],
                                     constant RenderInfo* renderInfo [[ buffer(3) ]]) {

    CubeOut outVertex;

    float4 positionVertex = toFloat4(position[vid]);
    float4 worldVector = float4(cubeInfo->xPos, cubeInfo->yPos, cubeInfo->zPos, 1.0);

    float4 cubeRotationVertex = float4(cubeInfo->xRotation, cubeInfo->yRotation, cubeInfo->zRotation, 1.0);

    float4 transformedPositionVertex = rotate3D(positionVertex, cubeRotationVertex);
    float4 translatedVertex = translationMatrix(transformedPositionVertex, worldVector);
    float4 screenCoordinates = perspectiveProjection(translatedVertex, renderInfo);
    uint face = vid / 6;
    float3 color = colors[face];
    outVertex.position = screenCoordinates;
    outVertex.color = float4(color[0], color[1], color[2], 1.0);

    return outVertex;
}

fragment float4 cubeFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}