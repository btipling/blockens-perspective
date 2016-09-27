
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
    float2 winResolution;
    float3 cameraRotation;
    float3 cameraTranslation;
    bool useCamera;
};

struct ModelViewData {
    float4 positionVertex;
    float4 scale;
    float4 rotationVertex;
    float4 translationVertex;
    constant RenderInfo* renderInfo;
};

struct Object3DInfo {
    float3 rotation;
    float3 scale;
    float3 position;
};

struct CameraVectors {
    float3 sideVector;
    float3 upVector;
    float3 directionVector;
};

struct RotationMatrix {
    float4x4 x;
    float4x4 y;
    float4x4 z;
};

float4 rgbaToNormalizedGPUColors(int r, int g, int b);

float4x4 matrixProduct4x4(float4x4 m1, float4x4 m2);

float4x4 orthoGraphicProjection(constant RenderInfo* renderInfo);
float4x4 perspectiveProjection(constant RenderInfo* renderInfo);

float4x4 scaleVector(float4 scale);

float4x4 rotateX(float4 angles);
float4x4 rotateY(float4 angles);
float4x4 rotateZ(float4 angles);

float4x4 translationMatrix(float4 translation);

float4 toFloat4(float3 position);
float4 zeroVector();
float4 identityVector();

RotationMatrix getRotationMatrix(float4 rotationVector);
float4x4 lookAt(float4 cameraPosition, float4 cameraRotation);
float4x4 lookAtArcBall(float4 cameraPosition, float4 cameraRotation);
float4 toScreenCoordinates(ModelViewData modelViewData);


#endif /* utils_h */
