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
        var winResolution: [Float32]
        var cameraRotation: [Float32]
        var cameraTranslation: [Float32]
        var useCamera: Bool
    }
    
    struct Object3DInfo {
        var rotation: [Float32]
        var scale: [Float32]
        var position: [Float32]
    }
    
    let floatSize: Int;
    let float3Size: Int;
    let object3DInfoSize: Int;
    
    
    fileprivate var renderInfoBuffer_: MTLBuffer? = nil;
    var depthStencilState: MTLDepthStencilState? = nil

    let rectangleVertexData:[Float] = [
        
        -1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
        -1.0, -1.0, 1.0,
        
        1.0, 1.0, 1.0,
        1.0, -1.0, 1.0,
        -1.0, -1.0, 1.0,
    ]

    let rectangleTextureCoords:[Float] = [
            0.0,  1.0,
            0.0,  0.0,
            1.0,  1.0,

            0.0,  0.0,
            1.0,  0.0,
            1.0,  1.0,
    ]

    let cubeVertexData: [Float32] = [

        // Front face
        // - ff left triangle
        -1.0, 1.0, -1.0,
        1.0, 1.0, -1.0,
        -1.0, -1.0, -1.0,

        // - ff right triangle
        1.0, 1.0, -1.0,
        1.0, -1.0, -1.0,
        -1.0, -1.0, -1.0,


        // Back face WRONG
        // - bf left triangle
        1.0, 1.0, 1.0,
        -1.0, -1.0, 1.0,
        1.0, -1.0, 1.0,

        // - bf right triangle
        1.0, 1.0, 1.0,
        -1.0, 1.0, 1.0,
        -1.0, -1.0, 1.0,


        // Left face
        // - lf left triangle
        -1.0, 1.0, 1.0,
        -1.0, 1.0, -1.0,
        -1.0, -1.0, 1.0,

        // - lf right triangle
        -1.0, 1.0, -1.0,
        -1.0, -1.0, -1.0,
        -1.0, -1.0, 1.0,


        // Right face
        // - rf left triangle
        1.0, 1.0, -1.0,
        1.0, 1.0, 1.0,
        1.0, -1.0, -1.0,

        // - rf right triangle
        1.0, 1.0, 1.0,
        1.0, -1.0, 1.0,
        1.0, -1.0, -1.0,


        // Top face
        // - tf left triangle
        -1.0, 1.0, 1.0,
        1.0, 1.0, 1.0,
        -1.0, 1.0, -1.0,

        // - tf right triangle
        1.0, 1.0, 1.0, 
        1.0, 1.0, -1.0,
        -1.0, 1.0, -1.0,


        // Bottom face WRONG
        // - bf left triangle
        1.0, -1.0, 1.0,
        -1.0, -1.0, -1.0,
        1.0, -1.0, -1.0,

        // - bf right triangle
        1.0, -1.0, 1.0,
        -1.0, -1.0, 1.0,
        -1.0, -1.0, -1.0,
    ]

    var cubeColors: [Float32];
    var cameraColors: [Float32];
    var vectorColors: [Float32];
    
    let CONSTANT_BUFFER_SIZE = 1024*1024
    
    init() {
        cubeColors = red
        cubeColors += green
        cubeColors += orange
        cubeColors += purple
        cubeColors += yellow
        cubeColors += cherry
        
        cameraColors = gray1;
        cameraColors += gray2;
        cameraColors += gray3;
        cameraColors += gray4;
        cameraColors += gray5;
        cameraColors += blueGray;
        
        vectorColors = blueGray
        vectorColors += red
        vectorColors += yellow

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
            let packedFloat2Size = floatSize * 2
            let packedFloat3Size = floatSize * 3
            let boolSize = MemoryLayout<Bool>.size
            
            memcpy(pointer, &renderInfo.zoom, floatSize)
            var offset = floatSize
            memcpy(pointer + offset, &renderInfo.near, floatSize)
            offset += floatSize
            memcpy(pointer + offset, &renderInfo.far, floatSize)
            offset += floatSize
            memcpy(pointer + offset, renderInfo.winResolution, packedFloat2Size)
            offset += packedFloat2Size
            memcpy(pointer + offset, frameInfo.cameraRotation, packedFloat3Size)
            offset += packedFloat3Size
            memcpy(pointer + offset, renderInfo.cameraTranslation, packedFloat3Size)
            offset += packedFloat3Size
            memcpy(pointer + offset, &renderInfo.useCamera, boolSize)

        }
    }
    
    func createRenderInfoBuffer(device: MTLDevice) {
        
        // Setup memory layout.
        let floatSize = MemoryLayout<Float>.size
        let packedFloat2Size = floatSize * 2
        let packedFloat3Size = floatSize * 3
        let boolSize = MemoryLayout<Bool>.size
        
        var minBufferSize = floatSize * 3 // zoom, far, near
        minBufferSize += packedFloat2Size // winResolultion
        minBufferSize += packedFloat3Size * 2 // cameraRotation, cameraPosition
        minBufferSize += boolSize // useCamera
        let bufferSize = alignBufferSize(bufferSize: minBufferSize, alignment: floatSize)
        
        renderInfoBuffer_ = device.makeBuffer(length: bufferSize, options: [])

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
        return rectangleVertexData.count/3
    }

    func numVerticesInACube() -> Int {
        return cubeVertexData.count/3
    }

    func numCubeColors() -> Int {
        return cubeColors.count/3 // Divided by 3 because RGB.
    }

    func loadTexture(device: MTLDevice, name: String) -> MTLTexture {
        var image = NSImage(named: name)!
        image = flipImage(image)
        var imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!
        let textureLoader = MTKTextureLoader(device: device)
        var texture: MTLTexture? = nil
        do {
            texture = try textureLoader.newTexture(with: imageRef, options: .none)
        } catch {
            print("Got an error trying to texture \(error)")
        }
        return texture!
    }
    
    func createPipelineStateDescriptor(vertex: String, fragment: String, device: MTLDevice, view: MTKView) -> MTLRenderPipelineDescriptor {
        
        let defaultLibrary = device.newDefaultLibrary()!
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
    
    func drawIndexedPrimitives(renderEncoder: MTLRenderCommandEncoder, meshes: [MTKMesh]) {
        for mesh in meshes {
            for submesh in mesh.submeshes {
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
    
    func finishDrawing(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.popDebugGroup()
    }

    func createSizedBuffer(_ device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let buffer = device.makeBuffer(length: CONSTANT_BUFFER_SIZE, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createRectangleVertexBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let bufferSize = rectangleVertexData.count * MemoryLayout.size(ofValue: rectangleVertexData[0])
        let buffer = device.makeBuffer(length: bufferSize, options: [])
        let pointer = buffer.contents()
        memcpy(pointer, rectangleVertexData, bufferSize)
        buffer.label = bufferLabel

        return buffer
    }

    func createCubeVertexBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let bufferSize = cubeVertexData.count * MemoryLayout.size(ofValue: cubeVertexData[0])
        let buffer = device.makeBuffer(bytes: cubeVertexData, length: bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createRectangleTextureCoordsBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let bufferSize = rectangleTextureCoords.count * MemoryLayout.size(ofValue: rectangleTextureCoords[0])
        let buffer = device.makeBuffer(bytes: rectangleTextureCoords, length: bufferSize, options: [])
        
        buffer.label = bufferLabel

        return buffer
    }

    func createBufferFromIntArray(device: MTLDevice, count: Int, bufferLabel: String) -> MTLBuffer {
        let bufferSize = MemoryLayout.size(ofValue: Array<Int32>(repeating: 0, count: count))
        let buffer = device.makeBuffer(length: bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createBufferFromFloatArray(device: MTLDevice, count: Int, bufferLabel: String) -> MTLBuffer {
        let bufferSize = MemoryLayout.size(ofValue: Array<Float32>(repeating: 0, count: count))
        let buffer = device.makeBuffer(length: bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }
    
    func createObject3DInfoBuffer(device: MTLDevice, label: String) -> MTLBuffer {
        let buffer = device.makeBuffer(length: object3DInfoSize, options: [])
        buffer.label = "ground rotation"
        return buffer
    }
    
    func createColorBuffer(device: MTLDevice, colors: [Float32], label: String) -> MTLBuffer {
        
        let floatSize = MemoryLayout<Float32>.size
        let bufferSize = floatSize * colors.count
        let buffer = device.makeBuffer(length: bufferSize, options: [])
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
        let pointer = buffer.contents()
        memcpy(pointer, object.rotation, float3Size)
        memcpy(pointer + float3Size, object.scale, float3Size)
        memcpy(pointer + (float3Size * 2), object.position, float3Size)
    }
    
    func depthStencilState (device: MTLDevice) {
        let depthStateDescriptor = MTLDepthStencilDescriptor()
        depthStateDescriptor.isDepthWriteEnabled = true
        depthStateDescriptor.depthCompareFunction = .less
        depthStencilState = device.makeDepthStencilState(descriptor: depthStateDescriptor)
    }
    
    func setup3D(renderEncoder: MTLRenderCommandEncoder) {
        
        renderEncoder.setDepthStencilState(depthStencilState!)
        
        renderEncoder.setCullMode(MTLCullMode.back)
        renderEncoder.setFrontFacing(MTLWinding.clockwise)
    }
    
    
}
