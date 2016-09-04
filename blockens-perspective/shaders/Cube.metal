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
    float zoom;
    float near;
    float far;
    float winResX;
    float winResY;
};

vertex CubeOut cubeVertex(uint vid [[ vertex_id ]],
                                     constant packed_float3* position  [[ buffer(0) ]],
                                     constant packed_float3* colors  [[ buffer(1) ]],
                                     constant CubeInfo* cubeInfo [[ buffer(2)]]) {

    CubeOut outVertex;

    float3 positionVertex = position[vid];
    float3 worldVector = float3(cubeInfo->xPos, cubeInfo->yPos, cubeInfo->zPos);

    float3 cubeRotationVertex = float3(cubeInfo->xRotation, cubeInfo->yRotation, cubeInfo->zRotation);

    float3 transformedPositionVertex = rotate3D(positionVertex, cubeRotationVertex);
    float4 translatedVertex = translationMatrix(transformedPositionVertex, worldVector);
    float4 screenCoordinates = orthoGraphicProjection(translatedVertex, cubeInfo->zoom, cubeInfo->zoom, cubeInfo->near, cubeInfo->far);

    uint face = vid / 6;
    float3 color = colors[face];
    outVertex.position = screenCoordinates;
    outVertex.color = float4(color[0], color[1], color[2], 1.0);

    return outVertex;
}

fragment float4 cubeFragment(CubeOut inFrag [[stage_in]]) {
    return inFrag.color;
}