//
// Created by Bjorn Tipling on 8/7/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class RenderUtils {
    
    struct RenderInfo {
        var zoom: Float32
        var near: Float32
        var far: Float32
        var winResolution: float2
        var cameraRotation: float3
        var cameraTranslation: float3
        var useCamera: Bool
    }
    
    struct MaterialUniform {
        var color: float3
    };

    
    struct Object3DInfo {
        var rotation: float3
        var scale: float3
        var position: float3
    }
    
    let floatSize: Int;
    let float3Size: Int;
    let object3DInfoSize: Int;
    
    
    fileprivate var renderInfoBuffer_: MTLBuffer? = nil;
    fileprivate var renderInfo_: RenderInfo? = nil
    var depthStencilState: MTLDepthStencilState? = nil

    let rectangleVertexData:[float3] = [
        
        float3(-1.0, 1.0, 1.0),
        float3(1.0, 1.0, 1.0),
        float3(-1.0, -1.0, 1.0),
        
        float3(1.0, 1.0, 1.0),
        float3(1.0, -1.0, 1.0),
        float3(-1.0, -1.0, 1.0),
    ]
    
    var cubeColors: [float4]
    var cameraColors: [float4]
    var vectorColors: [float4]
    var groundColors: [float4]
    var sphereColors: [float4]
    var skyColors: [float4]
    
    var windingOrder: MTLWinding = .clockwise
    
    let CONSTANT_BUFFER_SIZE = 1024*1024
    
    init() {
        cubeColors = [
            red,
            green,
            orange,
            purple,
            yellow,
            cherry,
        ]
    
        cameraColors = [
            gray1,
            gray2,
            gray3,
            gray4,
            gray5,
            blueGray,
        ]
        
        
        groundColors = []
        
        for _ in 0...5 {
            groundColors.append(blueGray)
        }
        
        sphereColors = []
        
        sphereColors = [
            white,
            lightGray,
        ]
        
        sphereColors = [
            white,
            lightGray,
        ]
        
        skyColors = [
            skyBlue,
            white,
        ]
        
        vectorColors = [blueGray, red, yellow]

        floatSize = MemoryLayout<Float>.size
        float3Size = floatSize * 4
        object3DInfoSize = float3Size * 3;
    }
    
    func setRenderInfo(frameInfo: FrameInfo) {
        var renderInfo = RenderInfo(
                zoom: frameInfo.zoom,
                near: frameInfo.near,
                far: frameInfo.far,
                winResolution: frameInfo.viewDimensions,
                cameraRotation: frameInfo.cameraRotation,
                cameraTranslation: frameInfo.cameraTranslation,
                useCamera: frameInfo.useCamera)
        if (renderInfoBuffer_ != nil) {
            let pointer = renderInfoBuffer_!.contents()
            
            // Memory layout for shader types:
            let packedFloat2Size = MemoryLayout<float2>.size
            let packedFloat3Size = MemoryLayout<float3>.size
            let boolSize = MemoryLayout<Bool>.size
            
            memcpy(pointer, &renderInfo.zoom, floatSize) //0
            var offset = floatSize // 0 + 4 = 4
            memcpy(pointer + offset, &renderInfo.near, floatSize)
            offset += floatSize // 4 + 4 = 8
            memcpy(pointer + offset, &renderInfo.far, floatSize)
            offset += floatSize // 8 + 4 = 12
            // Need to be at multiple of 8 for float2:
            offset += floatSize // 12 + 4 = Now at offset 16
            memcpy(pointer + offset, &renderInfo.winResolution, packedFloat2Size)
            offset += packedFloat2Size // 16 + 8 = 24
            // Need to be at offset 32 to start a float 3 (multiple of 16)
            offset += floatSize * 2  // 24 + 6 + 2 = 32
            memcpy(pointer + offset, &renderInfo.cameraRotation, packedFloat3Size)
            offset += packedFloat3Size // 32 + 16 = 48
            memcpy(pointer + offset, &renderInfo.cameraTranslation, packedFloat3Size)
            offset += packedFloat3Size // 48 + 16 = 64
            memcpy(pointer + offset, &renderInfo.useCamera, boolSize)
            
            renderInfo_ = renderInfo

        }
    }
    
    func createRenderInfoBuffer(device: MTLDevice) {
        
        // Setup memory layout.
        let floatSize = MemoryLayout<Float>.size
        let packedFloat2Size = MemoryLayout<float2>.size
        let packedFloat3Size = MemoryLayout<float3>.size
        let boolSize = MemoryLayout<Bool>.size
        
        var minBufferSize = floatSize * 3  // zoom, far, near
        minBufferSize += packedFloat2Size // winResolultion
        minBufferSize += packedFloat3Size * 3 // cameraRotation, cameraPosition + padding
        minBufferSize += boolSize // useCamera
        let bufferSize = alignBufferSize(bufferSize: minBufferSize, alignment: packedFloat3Size)
        
        renderInfoBuffer_ = device.makeBuffer(length: bufferSize, options: [])

    }
    
    func createMatrixBuffer(device: MTLDevice, label: String) -> MTLBuffer {
        let matrixSize = MemoryLayout<float4x4>.size
        let buffer = device.makeBuffer(length: matrixSize, options: [])!
        buffer.label = label
        return buffer
    }
    
    func updateMatrixBuffer(buffer: MTLBuffer, object3DInfo: Object3DInfo, translate: Bool=true) {
        guard let renderInfo = renderInfo_ else {
            return
        }
        let matrixSize = MemoryLayout<float4x4>.size
        let pointer = buffer.contents()
        let modelViewData = object3DInfoToModelViewData(object3DInfo: object3DInfo)
        var matrix = modelViewTransform(modelViewData: modelViewData, renderInfo: renderInfo, translate: translate)
        memcpy(pointer, &matrix, matrixSize)
    }
    
    func object3DInfoToModelViewData(object3DInfo: Object3DInfo) -> ModelViewData {
        return ModelViewData(
            scale: toFloat4(position: object3DInfo.scale),
            rotation: toFloat4(position: object3DInfo.rotation),
            translation: toFloat4(position: object3DInfo.position)
        )
    }
    
    func alignBufferSize(bufferSize: Int, alignment: Int) -> Int {
        let alignmentError = bufferSize % alignment;
        if (alignmentError == 0) {
            return bufferSize
        }
        return bufferSize + (alignment - alignmentError)
    }
    
    func renderInfoBuffer() -> MTLBuffer {
        return renderInfoBuffer_!
    }
    
    // Divided by 3 below because each pair is x,y,z for a single vertex.
    func numVerticesInARectangle() -> Int {
        return rectangleVertexData.count
    }

    func numCubeColors() -> Int {
        return cubeColors.count/3 // Divided by 3 because RGB.
    }
    
    func createPipelineStateDescriptor(vertex: String, fragment: String, device: MTLDevice, view: MTKView) -> MTLRenderPipelineDescriptor {
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexProgram = defaultLibrary.makeFunction(name: vertex)!
        let fragmentProgram = defaultLibrary.makeFunction(name: fragment)!
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount
        pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat
        
        return pipelineStateDescriptor
    }

    func createPipeLineState(vertex: String, fragment: String, device: MTLDevice, view: MTKView) -> MTLRenderPipelineState {
        let pipelineStateDescriptor = createPipelineStateDescriptor(vertex: vertex, fragment: fragment, device: device, view: view)
        return createPipeLineStateWithDescriptor(device: device, pipelineStateDescriptor: pipelineStateDescriptor)
    }

    
    func loadImageIntoTexture(device: MTLDevice, name: String) -> MTLTexture? {
        
        var image = NSImage(named: name)!
        image = fix(image: image)
        var imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!
        let textureLoader = MTKTextureLoader(device: device)
        do {
            return try textureLoader.newTexture(cgImage: imageRef, options: .none)
        } catch {
            print("Got an error trying to texture \(error)")
        }
        return nil
    }
    
    func createPipeLineStateWithDescriptor(device: MTLDevice, pipelineStateDescriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
        var pipelineState: MTLRenderPipelineState! = nil
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }

        return pipelineState
    }

    func setPipeLineState(renderEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState, name: String) {

        renderEncoder.label = "\(name) render encoder"
        renderEncoder.pushDebugGroup("draw \(name)")
        renderEncoder.setRenderPipelineState(pipelineState)
    }

    func drawPrimitives(renderEncoder: MTLRenderCommandEncoder, vertexCount: Int) {
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        finishDrawing(renderEncoder: renderEncoder)
    }
    
    func drawIndexedPrimitives(renderEncoder: MTLRenderCommandEncoder, meshes: [MTKMesh], materials: [MTLBuffer], vertexBuffers: [MTLBuffer]) {
        var bufferIndex = 0
        for mesh in meshes {
            
            for vertexBuffer in mesh.vertexBuffers {
                renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: bufferIndex)
                bufferIndex += 1
            }
            for buffer in vertexBuffers {
                renderEncoder.setVertexBuffer(buffer, offset: 0, index: bufferIndex)
                bufferIndex += 1
            }

            
            for (i, submesh) in mesh.submeshes.enumerated() {
                if (!materials.isEmpty) {
                    let material = materials[i]
                    renderEncoder.setVertexBuffer(material, offset: 0, index: bufferIndex)
                }
                
                renderEncoder.drawIndexedPrimitives(
                    type: submesh.primitiveType,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer.buffer,
                    indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
        finishDrawing(renderEncoder: renderEncoder)
        
    }
    
    func materialToBuffer(device: MTLDevice, material: MaterialUniform, label: String) -> MTLBuffer {
        var material = material
        let floatSize = MemoryLayout<Float>.size
        let packedFloat3Size = floatSize * 3;
        let bufferSize = packedFloat3Size
        let buffer = device.makeBuffer(length: bufferSize, options: [])!
        let pointer = buffer.contents()
        memcpy(pointer, &material.color, packedFloat3Size)
        buffer.label = label
        
        return buffer
    }
    
    func finishDrawing(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.popDebugGroup()
    }

    func createSizedBuffer(_ device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let buffer = device.makeBuffer(length: CONSTANT_BUFFER_SIZE, options: [])!
        buffer.label = bufferLabel

        return buffer
    }

    func createRectangleVertexBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let float3Size = MemoryLayout<float3>.size
        let bufferSize = rectangleVertexData.count * float3Size
        let buffer = device.makeBuffer(length: bufferSize, options: [])!
        let pointer = buffer.contents()
        memcpy(pointer, rectangleVertexData, bufferSize)
        buffer.label = bufferLabel

        return buffer
    }
    
    func createBufferFromIntArray(device: MTLDevice, count: Int, bufferLabel: String) -> MTLBuffer {
        let bufferSize = MemoryLayout.size(ofValue: Array<Int32>(repeating: 0, count: count))
        let buffer = device.makeBuffer(length: bufferSize, options: [])!
        buffer.label = bufferLabel

        return buffer
    }

    func createBufferFromFloatArray(device: MTLDevice, count: Int, bufferLabel: String) -> MTLBuffer {
        let bufferSize = MemoryLayout.size(ofValue: Array<Float32>(repeating: 0, count: count))
        let buffer = device.makeBuffer(length: bufferSize, options: [])!
        buffer.label = bufferLabel

        return buffer
    }
    
    func createObject3DInfoBuffer(device: MTLDevice, label: String) -> MTLBuffer {
        let buffer = device.makeBuffer(length: object3DInfoSize, options: [])!
        buffer.label = "ground rotation"
        return buffer
    }
    
    func createColorBuffer(device: MTLDevice, colors: [float4], label: String) -> MTLBuffer {
        
        let floatSize = MemoryLayout<float4>.size
        let bufferSize = floatSize * colors.count
        let buffer = device.makeBuffer(length: bufferSize, options: [])!
        buffer.label = label
        let pointer = buffer.contents()
        memcpy(pointer, colors, bufferSize)
        return buffer
    }
    
    func updateBufferFromIntArray(buffer: MTLBuffer, data: [Int32]) {
        let pointer = buffer.contents()
        let bufferSize = data.count * MemoryLayout.size(ofValue: data[0])
        memcpy(pointer, data, bufferSize)
    }

    func updateBufferFromFloatArray(buffer: MTLBuffer, data: [Float32]) {
        let pointer = buffer.contents()
        let bufferSize = data.count * MemoryLayout.size(ofValue: data[0])
        memcpy(pointer, data, bufferSize)
    }
    
    func updateObject3DInfoBuffer(object: Object3DInfo, buffer: MTLBuffer) {
        var object = object
        let pointer = buffer.contents()
        memcpy(pointer, &object.rotation, float3Size)
        memcpy(pointer + float3Size, &object.scale, float3Size)
        memcpy(pointer + (float3Size * 2), &object.position, float3Size)
    }
    
    func depthStencilState (device: MTLDevice) {
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.isDepthWriteEnabled = true
        depthStateDescriptor.depthCompareFunction = .less
        depthStencilState = device.makeDepthStencilState(descriptor: depthStateDescriptor)
    }
    
    func setup3D(renderEncoder: MTLRenderCommandEncoder) {
        
        renderEncoder.setDepthStencilState(depthStencilState!)
        windingOrder = MTLWinding.clockwise
        renderEncoder.setCullMode(MTLCullMode.back)
        renderEncoder.setFrontFacing(windingOrder)
    }
    
    func meshesToMaterialsBuffer(device: MTLDevice, meshes: [MDLMesh]) -> [MTLBuffer] {
        
        var submeshes: [MDLSubmesh] = Array()
        var materials: [MTLBuffer] = Array()
        
        for mesh in meshes {
            guard let submeshes_ = mesh.submeshes else {
                print("no submshes")
                continue
            }
            for submesh_ in submeshes_ {
                
                print("submesh is \(submesh_)")
                let submesh = submesh_ as! MDLSubmesh
                submeshes.append(submesh)
                print("submesh's name is \(submesh.name)")
                
                let specularColor = submesh.material?.property(with: MDLMaterialSemantic.baseColor)
                var material = RenderUtils.MaterialUniform(color: float3(0.0, 0.0, 0.0))
                if let color = specularColor {
                    material.color = float3(color.float3Value.x, color.float3Value.y, color.float3Value.z)
                    print("Found diffuse color: \(color.float3Value)")
                } else {
                    print("no diffuse")
                }
                materials.append(materialToBuffer(device: device, material: material, label: submesh.name))
                
                
            }
        }

        return materials
    }
    
    
}
