
#ifndef utils_h
#define utils_h

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
};

struct Color {
    packed_float3 color;
};

struct VertextOut {
    float4  position [[position]];
};

struct CubeOut {
    float4  position [[position]];
    float4 color;
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
