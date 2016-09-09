
#include "utils.h"

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}

float3 crossProduct(float3 a, float3 b) {

    float3 product;

    float x1 = a.x;
    float y1 = a.y;
    float z1 = a.z;

    float x2 = b.x;
    float y2 = b.y;
    float z2 = b.z;

    product.x = y1 * z2 + z1 * y2;
    product.y = z1 * x2 + x1 * z2;
    product.z = x1 * y2 + y1 * x2;

    return product;
}

float dotProduct4(float4 a, float4 b) {
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
}

float4 scaleVector4(float scalar, float4 vector) {
    float4 result;
    for (int i = 0; i < 4; i++) {
        result[i] = vector[i] * scalar;
    }
    return result;
}

float4 negateVector4(float4 vector) {
    float4 result;
    for (int i = 0; i < 3; i++) {
        result[i] = vector[i] * -1;
    }
    return result;

}

float4 addVector4(float4 a, float4 b) {
    float4 result;
    for (int i = 0; i < 4; i++) {
        result[i] = a[i] + b[i];
    }
    return result;
}

float4 subtractVector4(float4 a, float4 b) {
    return addVector4(a, negateVector4(b));
}

float4 getVectorTo4(float4 from, float4 to) {
    return subtractVector4(to, from);
}

float vectorMagnitude4(float4 vector) {
    float result;
    for (int i = 0; i < 4; i++) {
        result += pow(vector[i], 2);
    }
    return sqrt(result);
}

float4 toUnitVector4(float4 vector) {
    float magnitude = vectorMagnitude4(vector);

    float4 result;

    for (int i = 0; i < 4; i++) {
        result[i] = vector[i]/magnitude;
    }

    return result;
}

float distance4(float4 from, float4 to) {

    float4 vector = getVectorTo4(from, to);

    return vectorMagnitude4(vector);
}

float4x4 scale4x4(float scalar, float3x3 m) {
    float4x4 result;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; i++) {
            result[i][j] = m[i][j] * scalar;
        }
    }
    return result;
}

float4 transform4x4(float4 vector, float4x4 matrix) {
    float4 result;

    for (int i = 0; i < 4; i++) {
        result[i] = dotProduct4(vector, matrix[i]);
    }

    return result;
}

float4x4 matrixProduct4x4(float4x4 m1, float4x4 m2) {

    float4x4 result;

    for (int i = 0; i < 4; i++) {
        float4 rowM1 = float4(m1[0][i], m1[1][i], m1[2][i], m1[3][i]);
        result[i] = dotProduct4(rowM1, m2[i]);
    }

    return result;
}

float4 scaleVector(float4 vector, float4 scale) {
    
    float4x4 scaleMatrix = float4x4(float4(scale.x, 0, 0, 0), float4(0, scale.y, 0, 0), float4(0, 0, scale.z, 0), float4(0, 0, 0, 1));
    return transform4x4(vector, scaleMatrix);
}

float4 orthoGraphicProjection(float4 cameraSpaceVector, constant RenderInfo* renderInfo) {

    float4x4 orthographicProjectionMatrix;

    float near = renderInfo->near;
    float far = renderInfo->far;
    float zoomX = renderInfo->zoom;
    float zoomY = zoomX * (renderInfo->winResX/renderInfo->winResY);
    float zRange = far - near;
    
    float sDepth = 1/zRange;

    orthographicProjectionMatrix = float4x4(
        float4(zoomX, 0, 0, 0), float4(0, zoomY, 0, 0), float4(0, 0, sDepth, -1 * near * sDepth), float4(0, 0, 0, 1)
    );

    return transform4x4(cameraSpaceVector, orthographicProjectionMatrix);
}

float4 perspectiveProjection(float4 cameraSpaceVector, constant RenderInfo* renderInfo) {
    
    float4x4 perspectiveProjectionMatrix;
    
    float near = renderInfo->near;
    float far = renderInfo->far;
    float zoomX = renderInfo->zoom;
    float zoomY = zoomX * (renderInfo->winResX/renderInfo->winResY);
    float zRange = far - near;
    
    float zFar = far / zRange;
    
    perspectiveProjectionMatrix = float4x4(
       float4(zoomX, 0, 0, 0), float4(0, zoomY, 0, 0), float4(0, 0, zFar, -1 * near * zFar), float4(0, 0, 1, 0));
    
    return transform4x4(cameraSpaceVector, perspectiveProjectionMatrix);
}

float4 rotate3D(float4 vector, float4 angles) {
    float4 result;

    float cosX = cos(angles.x);
    float sinX = sin(angles.x);

    float cosY = cos(angles.y);
    float sinY = sin(angles.y);

    float cosZ = cos(angles.z);
    float sinZ = sin(angles.z);

    float4x4 xMatrix = float4x4(
        float4(1, 0, 0, 0), float4(0, cosX, sinX * -1, 0), float4(0, sinX, cosX, 0), float4(0, 0, 0, 1)
    );

    float4x4 yMatrix = float4x4(
        float4(cosY, 0, sinY, 0), float4(0, 1, 0, 0), float4(sinY * -1, 0, cosY, 0), float4(0, 0, 0, 1)
    );

    float4x4 zMatrix = float4x4(
        float4(cosZ, sinZ * -1, 0, 0), float4(sinZ, cosZ, 0, 0), float4(0, 0, 1, 0), float4(0, 0, 0, 1)
    );

    result = transform4x4(vector, xMatrix);
    result = transform4x4(result, yMatrix);
    result = transform4x4(result, zMatrix);

    return result;
}

float4 translationMatrix(float4 position, float4 transVector) {
    float4x4 m = float4x4( float4(1, 0, 0, transVector.x), float4(0, 1, 0, transVector.y), float4(0, 0, 1, transVector.z), float4(0, 0, 0, 1));
    return transform4x4(position, m);
}

float4 toFloat4(float3 position) {
    return float4(position[0], position[1], position[2], 1);
}