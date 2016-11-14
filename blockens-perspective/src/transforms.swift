//
//  transforms.swift
//  blockens-perspective
//
//  Created by Bjorn Tipling on 9/27/16.
//  Copyright © 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit


enum Dimension: Int {
    case x = 0
    case y
    case z
}

enum MatrixPosition: Int {
    case P = 0
    case Q
    case R
    case S
}

struct RotationMatrix {
    var x: float4x4
    var y: float4x4
    var z: float4x4
}

struct ModelViewData {
    let scale: float4
    let rotation: float4
    let translation: float4
}

func scaleMatrix(scale: float4) -> float4x4 {
    
    var scaleMatrix: float4x4 = float4x4()
    
    scaleMatrix[0] = float4(scale.x, 0.0, 0.0, 0.0)
    scaleMatrix[1] = float4(0.0, scale.y, 0.0, 0.0)
    scaleMatrix[2] = float4(0.0, 0.0, scale.z, 0.0)
    scaleMatrix[3] = float4(0.0, 0.0, 0.0, 1.0)
    
    return scaleMatrix
}

func orthoGraphicProjection(renderInfo: RenderUtils.RenderInfo) -> float4x4 {
    
    let resolution = renderInfo.winResolution
    
    let near: Float32 = renderInfo.near
    let far = renderInfo.far
    let zoomX = renderInfo.zoom
    let zoomY = zoomX * (resolution.x/resolution.y)
    let zRange = far - near
    
    let sDepth = 1/zRange
    
    var projectionMatrix = float4x4()
    projectionMatrix[0] = float4(zoomX, 0, 0, 0)
    projectionMatrix[1] = float4(0, zoomY, 0, 0)
    projectionMatrix[2] = float4(0, 0, sDepth, -1 * near * sDepth)
    projectionMatrix[3] = float4(0, 0, 0, 1)
    
    return projectionMatrix
}

func perspectiveProjection(renderInfo: RenderUtils.RenderInfo) -> float4x4 {
    
    let resolution = renderInfo.winResolution
    
    let near = renderInfo.near
    let far = renderInfo.far
    let zoomX = renderInfo.zoom
    let zoomY = zoomX * (resolution.x/resolution.y)
    let zRange = far - near
    
    let zFar = far / zRange
    
    var projectionMatrix = float4x4()
    projectionMatrix[0] = float4(zoomX, 0, 0, 0)
    projectionMatrix[1] = float4(0, zoomY, 0, 0)
    projectionMatrix[2] = float4(0, 0, zFar, -1 * near * zFar)
    projectionMatrix[3] = float4(0, 0, 1, 0)
    
    return projectionMatrix
}

func translationMatrix(transVector: float4) -> float4x4 {
    
    var translationMatrix = float4x4()
    
    translationMatrix[0] = float4(1, 0, 0, transVector.x)
    translationMatrix[1] = float4(0, 1, 0, transVector.y)
    translationMatrix[2] = float4(0, 0, 1, transVector.z)
    translationMatrix[3] = float4(0, 0, 0, 1)
    
    return translationMatrix
}

func toFloat4(position: float3) -> float4 {
    return float4(position[0], position[1], position[2], 1)
}

func identityVector() -> float4 {
    return float4(1.0, 1.0, 1.0, 1.0)
}

func zeroVector() -> float4 {
    return float4(0.0, 0.0, 0.0, 0.0)
}

func getRotationMatrix(q: float4) -> float4x4 {
    
    let x2 = pow(q.x, 2)
    let y2 = pow(q.y, 2)
    let z2 = pow(q.z, 2)
    
    /**
     1 − 2y^2 − 2z^2,  2xy + 2wz,  2xz − 2wy
     2xy − 2wz,  1 − 2x^2 − 2z^2,  2yz + 2wx
     2xz + 2wy, 2yz − 2wx, 1 − 2x^2 − 2y^2.
     
 */
    let m11 = 1 - 2 * y2 - 2 * z2
    let m12 = 2 * q.x * q.y + 2 * q.w * q.z 
    let m13 = 2 * q.x * q.z - 2 * q.w * q.y 
    
    let m21 = 2 * q.x * q.y - 2 * q.w * q.z 
    let m22 = 1 - 2 * x2 - 2 * z2
    let m23 = 2 * q.y * q.z + 2 * q.w * q.x
    
    let m31 = 2 * q.x * q.z + 2 * q.w * q.y
    let m32 = 2 * q.y * q.z - 2 * q.w * q.x
    let m33 = 1 - 2 * x2 - 2 * y2
    
    var rotationMatrix = float4x4()
    
    rotationMatrix[0] = float4(m11, m12, m13, 0)
    rotationMatrix[1] = float4(m21, m22, m23, 0)
    rotationMatrix[2] = float4(m31, m32, m33, 0)
    rotationMatrix[3] = float4(0, 0, 0, 1)
    
    return rotationMatrix
}

func lookAt(cameraPosition: float4) -> float4x4 {
    
    let initialUp = float4(0.0, 1.0, 0.0, 1.0)
    
    let poiFromOrigin = float4(cameraPosition.x, cameraPosition.y, cameraPosition.z + 1000.0, 1.0)
    
    
    let eye = float3(cameraPosition.x, cameraPosition.y, cameraPosition.z)
    let poi = float3(poiFromOrigin.x, poiFromOrigin.y, poiFromOrigin.z)
    let up = float3(initialUp.x, initialUp.y, initialUp.z)
    
    let f: float3 = normalize(poi - eye)
    let s: float3 = normalize(cross(up, f))
    let u: float3 = cross(f, s)
    
    var lookAtMatrix = float4x4()
    
    lookAtMatrix[0] = float4(
        s.x,
        s.y,
        s.z,
        0.0)
    lookAtMatrix[1] = float4(
            u.x,
            u.y,
            u.z,
            0.0)
    lookAtMatrix[2] = float4(
                f.x,
                f.y,
                f.z,
                0.0)
    lookAtMatrix[3] = float4(
                    0.0,
                    0.0,
                    0.0,
                    1.0)
    
    return lookAtMatrix * translationMatrix(transVector: -cameraPosition)
}

func modelViewTransform(modelViewData: ModelViewData, renderInfo: RenderUtils.RenderInfo, translate: Bool=true) -> float4x4 {
    
    // ## Setup camera vectors
    
    let cameraPosition = toFloat4(position: renderInfo.cameraTranslation)
    
    
    // ## Setup matrices.
    
    let scaleMatrix_ = scaleMatrix(scale: modelViewData.scale)
    let rotationMatrix = getRotationMatrix(q: modelViewData.rotation)
    let objectTranslationMatrix = translationMatrix(transVector: modelViewData.translation)
    let cameraMatrix = lookAt(cameraPosition: cameraPosition)
    let cameraRotationMatrix = getRotationMatrix(q: renderInfo.cameraRotation)
    let perspectiveMatrix = perspectiveProjection(renderInfo: renderInfo)
    
    // ## Build the final transformation matrix by multiplying the matrices together, matrices are associative: ABC == A(BC).
    // Scale * rotation matrices * translation * perspective = SRTP
    // Camera translation C
    // Then multiply the vector by v(SRTP(C))
    
    let SR: float4x4 = scaleMatrix_ * rotationMatrix
    
    let SRT: float4x4 = SR * objectTranslationMatrix
    
    if (!renderInfo.useCamera) {
        // Final non-camera transformation, v(SRTP):
        return SRT * perspectiveMatrix
    }
    
    var SRT_C: float4x4 = SRT
    if translate {
        SRT_C = SRT_C * cameraMatrix
    }
    
    let SRT_CR: float4x4 = SRT_C * cameraRotationMatrix
    
    // Finally add perspective transformation, for eventual v(SRTP(CR):
    return SRT_CR * perspectiveMatrix
    
}
