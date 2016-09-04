
#include "utils.h"

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}

float3 crossProduct(float3 a, float3 b) {

    float3 product;

    float x1 = a[0];
    float y1 = a[1];
    float z1 = a[2];

    float x2 = b[0];
    float y2 = b[1];
    float z2 = b[2];

    product[0] = y1 * z2 + z1 * y2;
    product[1] = z1 * x2 + x1 * z2;
    product[2] = x1 * y2 + y1 * x2;

    return product;
}

float dotProduct3(float3 a, float3 b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

float dotProduct4(float4 a, float4 b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3];
}

float3 scaleVector3(float scalar, float3 vector) {
    float3 result;
    for (int i = 0; i < 3; i++) {
        result[i] = vector[i] * scalar;
    }
    return result;
}

float4 scaleVector4(float scalar, float4 vector) {
    float4 result;
    for (int i = 0; i < 4; i++) {
        result[i] = vector[i] * scalar;
    }
    return result;
}

float3 negateVector3(float3 vector) {
    float3 result;
    for (int i = 0; i < 3; i++) {
        result[i] = vector[i] * -1;
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

float3 addVector3(float3 a, float3 b) {
    float3 result;
    for (int i = 0; i < 3; i++) {
        result[i] = a[i] + b[i];
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

float3 subtractVector3(float3 a, float3 b) {
    return addVector3(a, negateVector3(b));
}

float4 subtractVector4(float4 a, float4 b) {
    return addVector4(a, negateVector4(b));
}

float3 getVectorTo3(float3 from, float3 to) {
    return subtractVector3(to, from);
}

float4 getVectorTo4(float4 from, float4 to) {
    return subtractVector4(to, from);
}

float vectorMagnitude3(float3 vector) {
    float result;
    for (int i = 0; i < 3; i++) {
        result += pow(vector[i], 2);
    }
    return sqrt(result);
}

float vectorMagnitude4(float4 vector) {
    float result;
    for (int i = 0; i < 4; i++) {
        result += pow(vector[i], 2);
    }
    return sqrt(result);
}

float3 toUnitVector3(float3 vector) {
    float magnitude = vectorMagnitude3(vector);

    float3 result;

    for (int i = 0; i < 3; i++) {
        result[i] = vector[i]/magnitude;
    }

    return result;
}

float4 toUnitVector4(float4 vector) {
    float magnitude = vectorMagnitude4(vector);

    float4 result;

    for (int i = 0; i < 4; i++) {
        result[i] = vector[i]/magnitude;
    }

    return result;
}

float distance3(float3 from, float3 to) {

    float3 vector = getVectorTo3(from, to);

    return vectorMagnitude3(vector);
}

float distance4(float4 from, float4 to) {

    float4 vector = getVectorTo4(from, to);

    return vectorMagnitude4(vector);
}

float3x3 scale3x3(float scalar, float3x3 m) {
    float3x3 result;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; i++) {
            result[i][j] = m[i][j] * scalar;
        }
    }
    return result;
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

float3 transform3x3(float3 vector, float3x3 matrix) {
    float3 result;

    for (int i = 0; i < 3; i++) {
        result[i] = dotProduct3(vector, matrix[i]);
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

float3x3 matrixProduct3x3(float3x3 m1, float3x3 m2) {

    float3x3 result;

    for (int i = 0; i < 4; i++) {
        float3 rowM1 = float3(m1[0][i], m1[1][i], m1[2][i]);
        result[i] = dotProduct3(rowM1, m2[i]);
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

float4 orthoGraphicProjection(float4 cameraSpaceVector, float zoomX, float zoomY, float near, float far) {

    float4 expandedCameraSpace;
    float4x4 orthoGraphicProjectionMatrix;

    float zPlane = far - near;
    float clipPlane1 = -1 * (2/zPlane);
    float clipPlane2 = -1 * ((far + near)/zPlane);

    orthoGraphicProjectionMatrix = float4x4(
        float4(zoomX, 0, 0, 0), float4(0, zoomY, 0, 0), float4(0, 0, clipPlane1, 0), float4(0, 0, clipPlane2, 1)
    );

    return transform4x4(cameraSpaceVector, orthoGraphicProjectionMatrix);
}

float3 rotate3D(float3 vector, float3 angles) {
    float3 result;

    float cosX = cos(angles[0]);
    float sinX = sin(angles[0]);

    float cosY = cos(angles[1]);
    float sinY = sin(angles[1]);

    float cosZ = cos(angles[2]);
    float sinZ = sin(angles[2]);

    float3x3 xMatrix = float3x3(
        float3(1,  0,  0), float3(0,  cosX, sinX * -1), float3(0, sinX, cosX)
    );

    float3x3 yMatrix = float3x3(
        float3(cosY, 0, sinY), float3(0, 1,  0), float3(sinY * -1, 0, cosY)
    );

    float3x3 zMatrix = float3x3(
        float3(cosZ, sinZ * -1, 0), float3(sinZ, cosZ, 0), float3(0, 0, 1)
    );

    result = transform3x3(vector, xMatrix);
    result = transform3x3(result, yMatrix);
    result = transform3x3(result, zMatrix);

    return result;
}

float4 translationMatrix(float3 position, float3 transVector) {
    float4 expandedPosition = float4(position[0], position[1], position[2], 1);
    float4x4 m = float4x4( float4(1, 0, 0, transVector[0]), float4(0, 1, 0, transVector[1]), float4(0, 0, 1, transVector[2]), float4(0, 0, 0, 1));
    return transform4x4(expandedPosition, m);
}

float2 mapToWindow(float4 clipCoordinates, float winResX, float winResY) {
    float2 spaceCoordinates;

    float clipX = clipCoordinates[0];
    float clipY = clipCoordinates[1];
    float clipW = clipCoordinates[3];

    spaceCoordinates[0] = (clipX * winResX)/(2 * clipW);
    spaceCoordinates[1] = (clipY * winResY)/(2 * clipW);

    return spaceCoordinates;
}