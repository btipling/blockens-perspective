//
//  cube.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"


// Basic Shader

vertex ShapeOut shapeVertex(uint vid [[ vertex_id ]],
                            const ShapeIn vertices [[stage_in]],
                            constant float4x4* matrix [[ buffer(1)]],
                            constant ShapeInfo* shapeInfo [[ buffer(2)]],
                            constant float4* colors [[ buffer (3) ]]) {

    ShapeOut outVertex;
    
    float4 pos = toFloat4(vertices.position);
    outVertex.position = pos * *matrix;
    outVertex.textureCoords = vertices.textureCoords;
    outVertex.modelCoordinates = pos;
    
    uint face = vid / 4;
    outVertex.color = colors[face % 6];
    
    return outVertex;
}

vertex ShapeOut bubbleVertex(uint vid [[ vertex_id ]],
                             const ShapeIn vertices [[stage_in]],
                             constant float4x4* matrix [[ buffer(1)]],
                             constant ShapeInfo* shapeInfo [[ buffer(2)]],
                             constant float4* colors [[ buffer (3) ]]) {
    
    ShapeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    
    uint face = vid > 700 ? 0 : 1;
    outVertex.color = colors[face];
    
    return outVertex;
}

vertex ShapeOut skyVertex(uint vid [[ vertex_id ]],
                          const ShapeIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant ShapeInfo* shapeInfo [[ buffer(2)]],
                          constant float4* colors [[ buffer (3) ]]) {
    
    ShapeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    
    uint face = vid > 41 ? 0 : 1;
    outVertex.color = colors[face];
    
    return outVertex;
}

fragment float4 shapeFragment(ShapeOut inFrag [[stage_in]]) {
    return inFrag.color;
}

fragment float4 shapeTextureFragment(ShapeOut in [[stage_in]],
                             texture2d<float>  shapeTexture [[ texture(0) ]]) {
    constexpr sampler defaultSampler;
    
    float4 color =  shapeTexture.sample(defaultSampler, in.textureCoords);
    
    return color;
}


// Cube Map shaders

vertex CubeOut cubeVertex(uint vid [[ vertex_id ]],
                          const CubeIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant ShapeInfo* shapeInfo [[ buffer(2)]],
                          constant float4* colors [[ buffer (3) ]]) {
    
    CubeOut outVertex;
    
    uint sideNo = vid / 4;
    
    float4 pos = toFloat4(vertices.position);
    outVertex.position = pos * *matrix;
    outVertex.cubeSide = sideNo;
    
    outVertex.textureCoords = vertices.textureCoords;
    return outVertex;
}

fragment float4 cubeTextureFragment(CubeOut in [[stage_in]],
                                     texture2d_array<float> cubeTexture [[ texture(0) ]],
                                     sampler cubeSampler [[ sampler(0)]]) {
    
    float4 color =  cubeTexture.sample(cubeSampler, in.textureCoords, in.cubeSide);
    
    return color;
}


// Colorized sphere shaders

fragment float4 sphereDrawingFragment(ShapeOut in [[stage_in]]) {
    
    float4 purple = rgbaToNormalizedGPUColors(233, 116, 223);
    float4 orange = rgbaToNormalizedGPUColors(255, 191, 127);
    float4 green = rgbaToNormalizedGPUColors(158, 236, 117);
    float4 red = rgbaToNormalizedGPUColors(249, 82, 12);
    float4 yellow = rgbaToNormalizedGPUColors(249, 237, 12);
    float4 cherry = rgbaToNormalizedGPUColors(249, 0, 75);
    float4 lightBlue = rgbaToNormalizedGPUColors(0, 159, 225);
    float4 lightGreen = rgbaToNormalizedGPUColors(159, 250, 0);
    
    
    float4 pos = in.modelCoordinates;
    if (pos.x < 0) {
        if (pos.y < 0) {
            if (pos.z < 0) {
                return lightBlue;
            }
            return orange;
        }
        if (pos.z < 0) {
            return yellow;
        }
        return green;
    }
    if (pos.y < 0) {
        if (pos.z < 0) {
            return lightGreen;
        }
        return purple;
    }
    if (pos.z < 0) {
        return cherry;
    }
    
    return red;
}



