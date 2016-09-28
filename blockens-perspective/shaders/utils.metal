
#include "utils.h"

float4 rgbaToNormalizedGPUColors(int r, int g, int b) {
    return float4(float(r)/255.0, float(g)/255.0, float(b)/255.0, 1.0);
}

float4 toFloat4(float3 position) {
    return float4(position[0], position[1], position[2], 1);
}

float4 identityVector() {
    return float4(1.0, 1.0, 1.0, 1.0);
}

float4 zeroVector() {
    return float4(0.0, 0.0, 0.0, 0.0);
}
