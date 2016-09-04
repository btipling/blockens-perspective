//
// Created by Bjorn Tipling on 8/7/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class RenderUtils {

    let rectangleVertexData:[Float] = [
            -1.0, -1.0,
            -1.0,  1.0,
            1.0, -1.0,

            -1.0, 1.0,
            1.0,  1.0,
            1.0,  -1.0,
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

    let cubeColors: [Float32] = [
        // front
        red[0], red[1], red[2],
        // back
        green[0], green[1], green[2],
        // left
        orange[0], orange[1], orange[2],
        // right
        purple[0], purple[1], purple[2],
        // top
        yellow[0], yellow[1], yellow[2],
        // bottom
        cherry[0], cherry[1], cherry[2],

    ];

    let CONSTANT_BUFFER_SIZE = 1024*1024

    func numVerticesInARectangle() -> Int {
        return rectangleVertexData.count/2 // Divided by 2 because each pair is x,y for a single vertex.
    }

    func numVerticesInACube() -> Int {
        return cubeVertexData.count/3 // Divided by 3 because each pair is x,y,z for a single vertex.
    }

    func numCubeColors() -> Int {
        return cubeColors.count/3 // Divided by 3 because RGB.
    }

    func loadTexture(device: MTLDevice, name: String) -> MTLTexture {
        var image = NSImage(named: name)!
        image = flipImage(image)
        var imageRect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let imageRef = image.CGImageForProposedRect(&imageRect, context: nil, hints: nil)!
        let textureLoader = MTKTextureLoader(device: device)
        var texture: MTLTexture? = nil
        do {
            texture = try textureLoader.newTextureWithCGImage(imageRef, options: .None)
        } catch {
            print("Got an error trying to texture \(error)")
        }
        return texture!
    }

    func createPipeLineState(vertex: String, fragment: String, device: MTLDevice, view: MTKView) -> MTLRenderPipelineState {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName(vertex)!
        let fragmentProgram = defaultLibrary.newFunctionWithName(fragment)!

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount

        var pipelineState: MTLRenderPipelineState! = nil
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
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
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }

    func createSizedBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let buffer = device.newBufferWithLength(CONSTANT_BUFFER_SIZE, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createRectangleVertexBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let bufferSize = rectangleVertexData.count * sizeofValue(rectangleVertexData[0])
        let buffer = device.newBufferWithBytes(rectangleVertexData, length: bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createCubeVertexBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let bufferSize = cubeVertexData.count * sizeofValue(cubeVertexData[0])
        let buffer = device.newBufferWithBytes(cubeVertexData, length: bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createRectangleTextureCoordsBuffer(device: MTLDevice, bufferLabel: String) -> MTLBuffer {

        let bufferSize = rectangleTextureCoords.count * sizeofValue(rectangleTextureCoords[0])
        let buffer = device.newBufferWithBytes(rectangleTextureCoords, length: bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createBufferFromIntArray(device: MTLDevice, count: Int, bufferLabel: String) -> MTLBuffer {
        let bufferSize = sizeofValue(Array<Int32>(count: count, repeatedValue: 0))
        let buffer = device.newBufferWithLength(bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func createBufferFromFloatArray(device: MTLDevice, count: Int, bufferLabel: String) -> MTLBuffer {
        let bufferSize = sizeofValue(Array<Float32>(count: count, repeatedValue: 0))
        let buffer = device.newBufferWithLength(bufferSize, options: [])
        buffer.label = bufferLabel

        return buffer
    }

    func updateBufferFromIntArray(buffer: MTLBuffer, data: [Int32]) {
        let contents = buffer.contents()
        let pointer = UnsafeMutablePointer<Int32>(contents)
        pointer.initializeFrom(data)
    }

    func updateBufferFromFloatArray(buffer: MTLBuffer, data: [Float32]) {
        let contents = buffer.contents()
        let pointer = UnsafeMutablePointer<Float32>(contents)
        pointer.initializeFrom(data)
    }
}
