
#include "utils.h"

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}

float3 crossProduct(float3 V, float3 W) {
    
    float3 product;
    
    product.x = V.y * W.z - W.y * V.z;
    product.y = V.z * W.x - W.z * V.x;
    product.z = V.x * W.y - W.x * V.y;

    return product;
}

float dotProduct4(float4 a, float4 b) {
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
}

float dotProduct3(float3 a, float3 b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

float3 scaleVector3(float scalar, float3 vector) {
    float3 result;
    for (int i = 0; i < 3; i++) {
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
    for (int i = 0; i < 4; i++) {
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
    float3 result;
    for (int i = 0; i < 3; i++) {
        result[i] = a[i] - b[i];
    }
    return result;
}

float4 subtractVector4(float4 a, float4 b) {
    float4 result;
    for (int i = 0; i < 3; i++) {
        result[i] = a[i] - b[i];
    }
    return result;
}

float3 getVectorTo3(float3 from, float3 to) {
    return subtractVector3(to, from);
}

float vectorMagnitude3(float3 vector) {
    float result = 0.0;
    for (int i = 0; i < 3; i++) {
        result += pow(vector[i], 2);
    }
    return sqrt(result);
}

float3 normalize3(float3 vector) {
    
    float magnitude = vectorMagnitude3(vector);
    float3 result;
    
    result.x = vector.x/magnitude;
    result.y = vector.y/magnitude;
    result.z = vector.z/magnitude;
    
    return result;
}

float distance3(float3 from, float3 to) {

    float3 vector = getVectorTo3(from, to);

    return vectorMagnitude3(vector);
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
        for (int j = 0; j < 4; j++) {
            result[j][i] = dotProduct4(rowM1, m2[j]);
        }
    }

    return result;
}

float4x4 scaleVector(float4 scale) {
    
    return float4x4(float4(scale.x, 0, 0, 0), float4(0, scale.y, 0, 0), float4(0, 0, scale.z, 0), float4(0, 0, 0, 1));
}

float4x4 orthoGraphicProjection(constant RenderInfo* renderInfo) {
    
    float2 resolution = float2(renderInfo->winResolution);

    float near = renderInfo->near;
    float far = renderInfo->far;
    float zoomX = renderInfo->zoom;
    float zoomY = zoomX * (resolution.x/resolution.y);
    float zRange = far - near;
    
    float sDepth = 1/zRange;

    return float4x4(
        float4(zoomX, 0, 0, 0), float4(0, zoomY, 0, 0), float4(0, 0, sDepth, -1 * near * sDepth), float4(0, 0, 0, 1)
    );
}

float4x4 perspectiveProjection(constant RenderInfo* renderInfo) {
    
    float2 resolution = float2(renderInfo->winResolution);
    
    float near = renderInfo->near;
    float far = renderInfo->far;
    float zoomX = renderInfo->zoom;
    float zoomY = zoomX * (resolution.x/resolution.y);
    float zRange = far - near;
    
    float zFar = far / zRange;
    
    return float4x4(
       float4(zoomX, 0, 0, 0), float4(0, zoomY, 0, 0), float4(0, 0, zFar, -1 * near * zFar), float4(0, 0, 1, 0)
    );
}

float4x4 rotateX(float4 angles) {

    float cosX = cos(angles.x);
    float sinX = sin(angles.x);

    return float4x4(float4(1, 0, 0, 0), float4(0, cosX, sinX * -1, 0), float4(0, sinX, cosX, 0), float4(0, 0, 0, 1));
}

float4x4 rotateY(float4 angles) {
    
    float cosY = cos(angles.y);
    float sinY = sin(angles.y);
    
    return float4x4(float4(cosY, 0, sinY, 0), float4(0, 1, 0, 0), float4(sinY * -1, 0, cosY, 0), float4(0, 0, 0, 1));
}

float4x4 rotateZ(float4 angles) {
    
    float cosZ = cos(angles.z);
    float sinZ = sin(angles.z);
    
    return float4x4(float4(cosZ, sinZ * -1, 0, 0), float4(sinZ, cosZ, 0, 0), float4(0, 0, 1, 0), float4(0, 0, 0, 1));
}

float4x4 translationMatrix(float4 transVector) {
    return float4x4( float4(1, 0, 0, transVector.x), float4(0, 1, 0, transVector.y), float4(0, 0, 1, transVector.z), float4(0, 0, 0, 1));
}

float4 toFloat4(float3 position) {
    return float4(position[0], position[1], position[2], 1);
}

float4 identityVector() {
    return float4(1, 1, 1, 1);
}

RotationMatrix getRotationMatrix(float4 rotationVector) {
    return {
       .x = rotateX(rotationVector),
       .y = rotateY(rotationVector),
       .z = rotateZ(rotationVector),
    };
}
float4x4 lookAt(float4 cameraPosition, float4 cameraRotation) {
    
    float4 initialUp = float4(0.0, 1.0, 0.0, 1.0);
    
    float4 poiFromOrigin = float4(cameraPosition.x, cameraPosition.y, cameraPosition.z + 1000.0, 1.0);
    
    
    float3 eye = float3(cameraPosition.x, cameraPosition.y, cameraPosition.z);
    float3 poi = float3(poiFromOrigin.x, poiFromOrigin.y, poiFromOrigin.z);
    float3 up = float3(initialUp.x, initialUp.y, initialUp.z);
    
    float3 f = normalize3(subtractVector3(poi, eye));
    float3 s = normalize3(crossProduct(up, f));
    float3 u = crossProduct(f, s);
    
    
    float4x4 C = float4x4(
                          float4(
                                 s.x,
                                 s.y,
                                 s.z,
                                 0.0),
                          float4(
                                 u.x,
                                 u.y,
                                 u.z,
                                 0.0),
                          float4(
                                 f.x,
                                 f.y,
                                 f.z,
                                 0.0),
                          float4(
                                 0.0,
                                 0.0,
                                 0.0,
                                 1.0));
    return matrixProduct4x4(C, translationMatrix(negateVector4(cameraPosition)));
}

float4x4 lookAtArcBall(float4 cameraPosition, float4 cameraRotation) {
    
    float4 eye = float4(cameraPosition.x, cameraPosition.y, cameraPosition.z, 1.0);
   
    float cosPitch = cos(cameraRotation.x);
    float sinPitch = sin(cameraRotation.x);
    
    float cosYaw = cos(cameraRotation.y);
    float sinYaw = sin(cameraRotation.y);
    
    
    float3 s = float3(cosYaw, 0, -1.0 * sinYaw);
    float3 u = float3(sinYaw * sinPitch, cosPitch, cosYaw * sinPitch);
    float3 f = float3(sinYaw * cosPitch, -1.0 * sinPitch, cosPitch * cosYaw);
    
    
    float4x4 C = float4x4(
                float4(
                       s.x,
                       s.y,
                       s.z,
                       0.0),
                           float4(
                                  u.x,
                                  u.y,
                                  u.z,
                                  0.0),
                                       float4(
                                              f.x,
                                              f.y,
                                              f.z,
                                              0.0),
                                                   float4(
                                                          0.0,
                                                          0.0,
                                                          0.0,
                                                          1.0));
   return matrixProduct4x4(C, translationMatrix(negateVector4(eye)));
}


float4 toScreenCoordinates(ModelViewData modelViewData) {
    
    // ## Setup camera vectors
    
    float4 cameraPosition = toFloat4(modelViewData.renderInfo->cameraTranslation);
    
    
    // ## Setup matrices.
    
    float4x4 scaleMatrix = scaleVector(modelViewData.scale);
    RotationMatrix rotationMatrix = getRotationMatrix(modelViewData.rotationVertex);
    float4x4 objectTranslationMatrix = translationMatrix(modelViewData.translationVertex);
    float4x4 cameraMatrix = lookAt(cameraPosition, toFloat4(modelViewData.renderInfo->cameraRotation));
    RotationMatrix cameraRotationMatrix = getRotationMatrix(toFloat4(modelViewData.renderInfo->cameraRotation));
    float4x4 perspectiveMatrix = perspectiveProjection(modelViewData.renderInfo);
    
    // ## Build the final transformation matrix by multiplying the matrices together, matrices are associative: ABC == A(BC).
    // Scale * rotation matrices * translation * perspective = SRTP
    // Camera translation C
    // Then multiply the vector by v(SRTP(C))
    
    float4x4 SR;
    SR = matrixProduct4x4(scaleMatrix, rotationMatrix.x);
    SR = matrixProduct4x4(SR, rotationMatrix.y);
    SR = matrixProduct4x4(SR, rotationMatrix.z);
    
    
    float4x4 SRT;
    
    SRT = matrixProduct4x4(SR, objectTranslationMatrix);
    
    float4x4 SRTP;
    
    if (!modelViewData.renderInfo->useCamera) {
        // Final non-camera transformation, v(SRTP):
        
        SRTP = matrixProduct4x4(SRT, perspectiveMatrix);
        return transform4x4(modelViewData.positionVertex, SRTP);
    }
    
    float4x4 SRT_C;
    
    SRT_C = matrixProduct4x4(SRT, cameraMatrix);
    
    float4x4 SRT_CR;
    
    SRT_CR = matrixProduct4x4(SRT_C, cameraRotationMatrix.y);
    SRT_CR = matrixProduct4x4(SRT_CR, cameraRotationMatrix.x);
    
    float4x4 SRTP_CR;
    
    SRTP_CR = matrixProduct4x4(SRT_CR, perspectiveMatrix);
    
    // Final non-camera transformation, v(SRTP(CR):
    return transform4x4(modelViewData.positionVertex, SRTP_CR);
    
}
