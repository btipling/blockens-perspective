
#ifndef utils_h
#define utils_h

#include <metal_stdlib>

using namespace metal;


struct DuckIn {
    float3 position [[attribute(0)]];
};

struct DuckOut {
    float4  position [[position]];
    float4 color;
};

struct ShapeInfo {
    uint numSides;
};

struct ShapeIn {
    float3 position [[attribute(0)]];
    //    float3 normals [[attribute(1)]];
    float2 textureCoords [[attribute(2)]];
};

struct ShapeOut {
    float4  position [[position]];
    float4 modelCoordinates;
    float2 textureCoords;
    float4 color;
};

struct CubeIn {
    float3 position [[attribute(0)]];
    //    float3 normals [[attribute(1)]];
    float2 textureCoords [[attribute(2)]];
};

struct CubeOut {
    float4 position [[position]];
    float4 color;
    float2 textureCoords;
    uint cubeSide;
};

struct PlaneIn {
    float2 position [[attribute(0)]];
};

struct Color {
    packed_float3 color;
};

struct VertextOut {
    float4  position [[position]];
};

struct RenderInfo {
    float zoom;
    float near;
    float far;
    float2 winResolution;
    float3 cameraRotation;
    float3 cameraTranslation;
    bool useCamera;
};

float4 rgbaToNormalizedGPUColors(int r, int g, int b);
float4 toFloat4(float3 position);
float4 zeroVector();
float4 identityVector();


#endif /* utils_h */
