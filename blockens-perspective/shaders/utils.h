
#ifndef utils_h
#define utils_h

#include <metal_stdlib>

using namespace metal;


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
    packed_float2 winResolution;
    packed_float2 cameraRotation;
    packed_float3 cameraPosition;
};

struct ModelViewData {
    float4 positionVertex;
    float4 scale;
    float4 rotationVertex;
    float4 translationVertex;
    constant RenderInfo* renderInfo;
};

float4 rgbaToNormalizedGPUColors(int r, int g, int b);

float3 crossProduct(float3 a, float3 b);
float dotProduct4(float4 a, float4 b);

float4 scaleVector4(float scalar, float4 vector);
float4 negateVector4(float4 vector);
float4 addVector4(float4 a, float4 b);
float4 subtractVector4(float4 a, float4 b);
float4 getVectorTo4(float4 from, float4 to);
float vectorMagnitude4(float4 vector);
float4 toUnitVector4(float4 vector);
float distance4(float4 from, float4 to);

float4x4 scale4x4(float scalar, float3x3 m);
float4 transform4x4(float4 vector, float4x4 matrix);
float4x4 matrixProduct4x4(float4x4 m1, float4x4 m2);

float4x4 orthoGraphicProjection(constant RenderInfo* renderInfo);
float4x4 perspectiveProjection(constant RenderInfo* renderInfo);

float4x4 scaleVector(float4 scale);

float4x4 rotateX(float4 angles);
float4x4 rotateY(float4 angles);
float4x4 rotateZ(float4 angles);

float4x4 translationMatrix(float4 translation);

float4 toFloat4(float3 position);
float4 identityVector();

float4 toScreenCoordinates(ModelViewData modelViewData);


#endif /* utils_h */
