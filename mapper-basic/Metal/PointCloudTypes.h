#ifndef PointCloudTypes_h
#define PointCloudTypes_h

#include <simd/simd.h>

enum TextureIndices {
    kTextureY = 0,
    kTextureCbCr = 1,
    kTextureDepth = 2,
    kTextureConfidence = 3,
};

enum BufferIndices {
    kPointCloudUniforms = 0,
    kPointUniforms = 1,
    kGridPoints = 2,
};

struct PointCloudUniforms {
    matrix_float4x4 viewProjectionMatrix;
    matrix_float4x4 localToWorld;
    matrix_float3x3 cameraIntrinsicsInversed;
    simd_float2 cameraResolution;
};

struct PointUniforms {
    simd_float3 position;
    simd_float3 color;
    float confidence;
};


#endif /* PointCloudTypes_h */
