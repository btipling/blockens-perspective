//
//  cube.metal
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

#include "utils.h"

vertex ShapeOut shapeVertex(uint vid [[ vertex_id ]],
                          const ShapeIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant float4* colors [[ buffer(2) ]]) {

    ShapeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    outVertex.textureCoords = vertices.textureCoords;
    
    uint face = vid / 4;
    outVertex.color = colors[face % 6];
    
    return outVertex;
}

vertex ShapeOut bubbleVertex(uint vid [[ vertex_id ]],
                          const ShapeIn vertices [[stage_in]],
                          constant float4x4* matrix [[ buffer(1)]],
                          constant float4* colors [[ buffer(2) ]]) {
    
    ShapeOut outVertex;
    
    outVertex.position = toFloat4(vertices.position) * *matrix;
    
    uint face = vid > 700 ? 0 : 1;
    outVertex.color = colors[face];
    
    return outVertex;
}

vertex ShapeOut skyVertex(uint vid [[ vertex_id ]],
                            const ShapeIn vertices [[stage_in]],
                            constant float4x4* matrix [[ buffer(1)]],
                            constant float4* colors [[ buffer(2) ]]) {
    
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
                             texture2d<float>  diffuseTexture [[ texture(0) ]]) {
    constexpr sampler defaultSampler;
    
    // Blend texture color with input color and output to framebuffer
    float4 color =  diffuseTexture.sample(defaultSampler, in.textureCoords);
    
    return color;
}



