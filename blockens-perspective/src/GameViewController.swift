//
//  GameViewController.swift
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa
import MetalKit

class GameViewController: NSViewController, MTKViewDelegate, NSWindowDelegate {

    var device: MTLDevice! = nil

    var commandQueue: MTLCommandQueue! = nil

    let inflightSemaphore = DispatchSemaphore(value: 1)

    var renderers: [Renderer] = Array()
    var cube: ShapeRenderer! = nil
    var sky: ShapeRenderer! = nil
    var frameInfo: FrameInfo! = nil
    
    var activeKeys: [UInt16] = Array()
    var cameraRotationChange: (Float32, Float32) = (0.0, 0.0)
    
    let renderUtils = RenderUtils()
    
    var trackingArea: NSTrackingArea? = nil

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else {
            print("Metal is not supported on this device")
            exit(1)
        }
        
        let view = self.view as! MTKView
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let gameWindow = appDelegate.getWindow()
        gameWindow.makeFirstResponder(view)
        cube = ShapeRenderer(colors: renderUtils.cubeColors, scale: float3(1.0, 1.0, 1.0), shapeType: .Cube)
        
        var bubbles: [ShapeRenderer] = Array()
        for _ in 0..<100 {
            let scale = Float32(arc4random_uniform(2) + 1)
            let bubble = ShapeRenderer(colors: renderUtils.sphereColors, scale: [scale, scale, scale], shapeType: .Sphere)
            bubble.vertexName = "bubbleVertex"
            bubbles.append(bubble)
        }
        gameWindow.addKeyDownEventCallback(handleKeyDownEvent)
        gameWindow.addKeyUpEventCallback(handleKeyUpEvent)


        // Setup view properties.
        view.delegate = self
        view.device = device
        view.sampleCount = 4
        view.depthStencilPixelFormat = .depth32Float_stencil8
        
        updateTrackingArea()
        
        // Setup some initial render state.
        setupFrameInfo(view)
        renderUtils.depthStencilState(device: device)
        
        let plane = ShapeRenderer(colors: renderUtils.groundColors, scale: float3(1000.0, 1000.0, 1.0), shapeType: .Plane)
        plane.update(rotation: float3(1.6, 0.0, 0.0), position: float3(0.0, -6.0, 1.0))
        
        sky = ShapeRenderer(colors: renderUtils.skyColors, scale: float3(400.0, 400.0, 400.0), shapeType: .Sphere, inward: true, translate: false)
        sky.vertexName = "skyVertex"
        sky.update(rotation: float3(1.0, 1.0, 1.0), position: float3(0.0, 0.0, 0.0))
        
        let doggoTexture = TextureLoader2D(name: "spaghetti", renderUtils: renderUtils)
        let testCube = ShapeRenderer(colors: renderUtils.cameraColors, scale: float3(1.0, 1.0, 1.0), shapeType: .Cube, textureLoader: doggoTexture)
        testCube.fragmentName = "shapeTextureFragment"
        testCube.update(rotation: float3(0.0, 0.0, 1.0), position: float3(55.0, 0.0, 5.0))
        
        let testTextureSphere = ShapeRenderer(colors: renderUtils.cameraColors, scale: float3(1.0, 1.0, 1.0), shapeType: .Sphere, textureLoader: doggoTexture)
        testTextureSphere.fragmentName = "shapeTextureFragment"
        testTextureSphere.update(rotation: float3(2.0, 2.0, 0.0), position: float3(55.0, 0.0, -5.0))
        
        let testDrawingSphere = ShapeRenderer(colors: renderUtils.cameraColors, scale: float3(1.0, 1.0, 1.0), shapeType: .Sphere)
        testDrawingSphere.fragmentName = "sphereDrawingFragment"
        testDrawingSphere.update(rotation: float3(2.0, 2.0, 0.0), position: float3(60.0, 0.0, 0.0))
        
        let ggTexture = TextureLoaderCubeMap(name: "gg", renderUtils: renderUtils)
        let testMappedCube = ShapeRenderer(colors: renderUtils.cameraColors, scale: float3(25.0, 25.0, 25.0), shapeType: .Cube, textureLoader: ggTexture,
                                           inward: true)
        testMappedCube.vertexName = "cubeVertex"
        testMappedCube.fragmentName = "cubeTextureFragment"
        testMappedCube.update(rotation: float3(0.0, 0.0, 0.0), position: float3(105.0, 25.0, 55.0))
        
        
        let earthTexture = TextureLoader2D(name: "earth", renderUtils: renderUtils)
        let testMappedSphere = ShapeRenderer(colors: renderUtils.cameraColors, scale: float3(15.0, 15.0, 15.0), shapeType: .Sphere, textureLoader: earthTexture,
                                           inward: false)
        testMappedSphere.vertexName = "shapeVertex"
        testMappedSphere.fragmentName = "shapeTextureFragment"
        testMappedSphere.update(rotation: float3(0.0, 0.0, 0.0), position: float3(4.3, 25.0, 121.0))

        // Add render controllers, order matters.
        var renderControllers: [RenderController] = [
            sky,
            cube,
            DuckRenderer(),
            plane,
            testCube,
            testTextureSphere,
            testDrawingSphere,
            testMappedCube,
            testMappedSphere,
        ]
        
        renderControllers = renderControllers + bubbles
        renderControllers.append(CrossHairsRenderer())
        
        // Collect renderers and provide renderUtils to controllers.
        for renderController in renderControllers {
            renderController.setRenderUtils(renderUtils)
            renderers.append(renderController.renderer())
        }
        
        loadAssets(view)
        for referenceCube in bubbles {
            let x = Float32(arc4random_uniform(100)) - 50.0
            let y = Float32(arc4random_uniform(4)) - 2.0
            let z = Float32(arc4random_uniform(100)) - 50.0
            
            let pitch = Float32(arc4random_uniform(5))
            let yaw = Float32(arc4random_uniform(5))
            let roll = Float32(arc4random_uniform(1))
            referenceCube.update(rotation: [pitch, yaw, roll], position: [x, y, z]);
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        cameraRotationChange = (Float32(event.deltaX)/100.0, Float32(event.deltaY)/100.0)
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.unhide()
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.hide()
    }
    
    func updateAll() {
        cube.update(rotation: frameInfo.cubeRotation, position: frameInfo.cubePosition)
        renderUtils.setRenderInfo(frameInfo: frameInfo)
        for renderer in renderers {
            renderer.update()
        }
    }
    
    func windowDidResize(_ notification: Notification) {
        let view = self.view as! MTKView
        registerViewDimensions(view)
        updateAll()
        updateTrackingArea()
    }
    
    func updateTrackingArea() {
        if let area = trackingArea {
            view.removeTrackingArea(area)
        }
        trackingArea = NSTrackingArea(rect: view.frame, options: [
            NSTrackingArea.Options.enabledDuringMouseDrag,
            NSTrackingArea.Options.mouseMoved,
            NSTrackingArea.Options.activeAlways
            ], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea!)
    }
    
    func handleKeyDownEvent(_ event: NSEvent?) {
        
        guard let keyCode = event?.keyCode else {
            activeKeys = Array()
            return
        }
        
        if (activeKeys.contains(keyCode)) {
            return
        }
        
        switch keyCode {
            
        case P_KEY:
            print(frameInfo)
            return
        case M_KEY:
            frameInfo.useCamera = !frameInfo.useCamera
            return
        default:
            break
        }
        
        activeKeys.append(keyCode)
    }
    
    func handleKeyUpEvent(_ event: NSEvent?) {
        
        guard let keyCode = event?.keyCode else {
            activeKeys = Array()
            return
        }
        
        
        if let index = activeKeys.index(of: keyCode) {
            activeKeys.remove(at: index)
            return
        }
    }
    
    private func modifyCubeRotation(_ dimension: Int, _ modifier: Float32 = 1.0) {
        frameInfo.cubeRotation[dimension] = frameInfo.cubeRotation[dimension] - (modifier * ROTATION_CHANGE_MODIFIER)
    }
    
    private func modifyCubePosition(_ dimension: Int, _ modifier: Float32 = 1.0) {
        frameInfo.cubePosition[dimension] = frameInfo.cubePosition[dimension] - (modifier * POS_CHANGE_MODIFIER)
    }
    
    private func moveCamera(dimension: Dimension, modifier: Float32 = 1.0) {
        var basisVector: float3! = nil
        
        switch dimension {
        case .x:
            basisVector = float3(1.0, 0.0, 0.0)
        case .y:
            basisVector = float3(0.0, 1.0, 0.0)
        case .z:
            basisVector = float3(0.0, 0.0, 1.0)
        }
        
        let rotationMatrix = getRotationMatrix(rotationVector: toFloat4(position: -frameInfo.cameraRotation))
        let finalRotationMatrix = rotationMatrix.x * rotationMatrix.y * rotationMatrix.z
        let delta4 = toFloat4(position: basisVector) * finalRotationMatrix
        var delta3 = float3(delta4.x, delta4.y, delta4.z)
        delta3 *= modifier
        frameInfo.cameraTranslation = frameInfo.cameraTranslation + delta3
    }
    
    func handleActiveKeys() {
        for keyCode in activeKeys {
            handleActiveKey(keyCode: keyCode)
        }
    }
    
    func handleActiveKey(keyCode: UInt16) {

        switch keyCode {

        case Z_KEY:
            modifyCubeRotation(0)
            break
        case X_KEY:
            modifyCubeRotation(0, -1.0)
                break
        case C_KEY:
            modifyCubeRotation(1)
                break
        case V_KEY:
            modifyCubeRotation(1, -1.0)
                break
        case B_KEY:
            modifyCubeRotation(2)
                break
        case N_KEY:
            modifyCubeRotation(2, -1.0)
                break

        case LEFT_KEY:
            modifyCubePosition(0)
                break
        case RIGHT_KEY:
            modifyCubePosition(0, -1.0)
                break
        case DOWN_KEY:
            modifyCubePosition(1)
                break
        case UP_KEY:
            modifyCubePosition(1, -1.0)
                break
        case O_KEY:
            modifyCubePosition(2)
                break
        case I_KEY:
            modifyCubePosition(2, -1.0)
                break

        case PLUS_KEY:
            frameInfo.zoom += ZOOM_CHANGE_MODIFIER
            break
        case MINUS_KEY:
            frameInfo.zoom -= ZOOM_CHANGE_MODIFIER
            break

        case OPEN_BRACKET_KEY:
            frameInfo.near -= POS_CHANGE_MODIFIER
            break
        case CLOSE_BRACKET_KEY:
            frameInfo.near += POS_CHANGE_MODIFIER
            break
        case OPEN_ALL_KEY:
            frameInfo.far -= POS_CHANGE_MODIFIER
            break
        case CLOSE_ALL_KEY:
            frameInfo.far += POS_CHANGE_MODIFIER
            break
        
        case W_KEY:
            moveCamera(dimension: .z)
            break
        case S_KEY:
            moveCamera(dimension: .z, modifier: -1.0)
                break
        case D_KEY:
            moveCamera(dimension: .x)
                break
        case A_KEY:
            moveCamera(dimension: .x, modifier: -1.0)
                break
        case SPACE_KEY:
            moveCamera(dimension: .y)
                break
        case Q_KEY:
            moveCamera(dimension: .y, modifier: -1.0)
            break

        default:
            print(keyCode)
            break
        }

    }
    
    func handleCameraRotation () {
        
        var (xMovement, yMovement) = cameraRotationChange
        
        if xMovement == 0.0 && yMovement == 0.0 {
            return
        }
        
        let cameraRotation = frameInfo.cameraRotation
        let completeCircle: Float32 = 0.0
        // The x rotation rotates around the x coordinate, so we use y movement and so on.
        if frameInfo.useCamera {
            yMovement *= -1.0
        } else {
            xMovement *= -1.0
        }
        let newX: Float32 = completeCircle + cameraRotation[0] + yMovement
        let newY: Float32 = completeCircle + cameraRotation[1] - xMovement
        frameInfo.cameraRotation = [newX, newY, 0.0]
        cameraRotationChange = (0.0, 0.0)
    }
    

    func setupFrameInfo(_ view: MTKView) {
        print("Setting up frame info")
        frameInfo = FrameInfo(
            viewDimensions: float2(0.0, 0.0),
            viewDiffRatio: 0.0,
            cubeRotation: float3(5.5, 0.7, 1.4),
            cubePosition: float3(60.0, 0.0, 10.0),
            zoom: 1,
            near: 0.1,
            far: 6000.0,
            cameraRotation: float3(-0.36, 01.06, 0),
            cameraTranslation: float3(61.6952, 6.77314, 24.5539),
            useCamera: true)
        registerViewDimensions(view)
    }
    
    func registerViewDimensions(_ view: MTKView) {
        print("Registering view dimensions")
        let frame = view.frame
        let width = frame.size.width
        let height = frame.size.height
        let maxDimension = max(width, height)
        let sizeDiff = abs(width - height)
        let ratio: Float = Float(sizeDiff)/Float(maxDimension)
        
        frameInfo.viewDimensions = [Float32(width), Float32(height)]
        frameInfo.viewDiffRatio = ratio
    }

    func loadAssets(_ view: MTKView) {
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        
        renderUtils.createRenderInfoBuffer(device: device)
        renderUtils.setRenderInfo(frameInfo: frameInfo)
        for renderer in renderers {
            renderer.loadAssets(device, view: view, frameInfo: frameInfo)
        }
        updateAll()
    }

    func draw(in view: MTKView) {
        _ = inflightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        
        handleActiveKeys()
        handleCameraRotation()
        updateAll()
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "Frame command buffer"

        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.inflightSemaphore.signal()
            }
            return
        }

        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {

            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderUtils.setup3D(renderEncoder: renderEncoder)
            for renderer in renderers {
                renderer.render(renderEncoder)
            }

            renderEncoder.endEncoding()
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Pass through and do nothing.
    }
}
