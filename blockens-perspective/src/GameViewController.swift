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
    var cube: CubeRenderer! = nil
    var camera: CubeRenderer! = nil
    var frameInfo: FrameInfo! = nil
    var activeKey: UInt16? = nil
    
    let renderUtils = RenderUtils()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let gameWindow = appDelegate.getWindow()
        cube = CubeRenderer(colors: renderUtils.cubeColors, scale: [1.0, 1.0, 1.0])
        camera = CubeRenderer(colors: renderUtils.cameraColors, scale: [0.25, 0.25, 0.25])
        gameWindow.addKeyEventCallback(handleKeyEvent)

        device = MTLCreateSystemDefaultDevice()
        guard device != nil else { // Fallback to a blank NSView, an application could also fallback to OpenGL here.
            print("Metal is not supported on this device")
            self.view = NSView(frame: self.view.frame)
            return
        }

        // Setup view properties.
        let view = self.view as! MTKView
        view.delegate = self
        view.device = device
        view.sampleCount = 4
        view.depthStencilPixelFormat = .depth32Float_stencil8
        
        let trackingArea = NSTrackingArea(rect: view.frame, options: [NSTrackingAreaOptions.mouseMoved, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
        
        // Setup some initial render state.
        setupFrameInfo(view)
        renderUtils.depthStencilState(device: device)

        // Add render controllers, order matters.
        let renderControllers: [RenderController] = [
            SkyRenderer(),
            GroundRenderer(),
            cube,
            camera,
            CrossHairsRenderer(),
        ]
        
        // Collect renderers and provide renderUtils to controllers.
        for renderController in renderControllers {
            renderController.setRenderUtils(renderUtils)
            renderers.append(renderController.renderer())
        }
        
        loadAssets(view)
    }
    
    override func mouseMoved(with event: NSEvent) {
        let xMovement = event.deltaX/100.0
        let yMovement = event.deltaY/100.0
        let cameraRotation = frameInfo.cameraRotation
        let completeCircle: Float32 = 0.0
        // The x rotation rotates around the x coordinate, so we use y movement and so on.
        let newX: Float32 = completeCircle + cameraRotation[0] - Float32(yMovement)
        let newY: Float32 = completeCircle + cameraRotation[1] - Float32(xMovement)
        frameInfo.cameraRotation = [newX, newY]
        updateAll()
        print("new frameInfo \(frameInfo)")
        renderUtils.setRenderInfo(frameInfo: frameInfo)
    }
    
    func updateAll() {
        cube.update(rotation: [frameInfo.rotateX, frameInfo.rotateY,frameInfo.rotateZ], position: [frameInfo.xPos, frameInfo.yPos, frameInfo.zPos])
        camera.update(rotation: frameInfo.cameraRotation, position: frameInfo.cameraTranslation)
    }
    
    func windowDidResize(_ notification: Notification) {
        let view = self.view as! MTKView
        registerViewDimensions(view)
        updateAll()
        renderUtils.setRenderInfo(frameInfo: frameInfo)
    }
    
    func handleKeyEvent(_ event: NSEvent?) {
        
        guard let keyCode = event?.keyCode else {
            activeKey = nil
            return
        }
        
        activeKey = keyCode
    }
    
    func handleActiveKey() {
        
        guard let keyCode = activeKey else {
            return
        }
        
        let cameraTranslation = frameInfo.cameraTranslation

        switch keyCode {

            case Z_KEY:
                frameInfo.rotateX = frameInfo.rotateX - ROTATION_CHANGE_MODIFIER
                break
            case X_KEY:
                frameInfo.rotateX = frameInfo.rotateX + ROTATION_CHANGE_MODIFIER
                break
            case C_KEY:
                frameInfo.rotateY = frameInfo.rotateY - ROTATION_CHANGE_MODIFIER
                break
            case V_KEY:
                frameInfo.rotateY = frameInfo.rotateY + ROTATION_CHANGE_MODIFIER
                break

            case B_KEY:
                frameInfo.rotateZ = frameInfo.rotateZ - ROTATION_CHANGE_MODIFIER
                break
            case N_KEY:
                frameInfo.rotateZ = frameInfo.rotateZ + ROTATION_CHANGE_MODIFIER
                break

            case LEFT_KEY:
                frameInfo.xPos = frameInfo.xPos - POS_CHANGE_MODIFIER
                break
            case RIGHT_KEY:
                frameInfo.xPos = frameInfo.xPos + POS_CHANGE_MODIFIER
                break
            case DOWN_KEY:
                frameInfo.yPos = frameInfo.yPos - POS_CHANGE_MODIFIER
                break
            case UP_KEY:
                frameInfo.yPos = frameInfo.yPos + POS_CHANGE_MODIFIER
                break

            case O_KEY:
                frameInfo.zPos = frameInfo.zPos + POS_CHANGE_MODIFIER
                break
            case I_KEY:
                frameInfo.zPos = frameInfo.zPos - POS_CHANGE_MODIFIER
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
                let newY = cameraTranslation[1] + CAMERA_CHANGE_MODIFIER
                frameInfo.cameraTranslation = [cameraTranslation[0], newY, cameraTranslation[2]]
                break
            case S_KEY:
                let newY = cameraTranslation[1] - CAMERA_CHANGE_MODIFIER
                frameInfo.cameraTranslation = [cameraTranslation[0], newY, cameraTranslation[2]]
                break
            case D_KEY:
                let newX = cameraTranslation[0] + CAMERA_CHANGE_MODIFIER
                frameInfo.cameraTranslation = [newX, cameraTranslation[1], cameraTranslation[2]]
                break
            case A_KEY:
                let newX = cameraTranslation[0] -  CAMERA_CHANGE_MODIFIER
                frameInfo.cameraTranslation = [newX, cameraTranslation[1], cameraTranslation[2]]
                break
            case Q_KEY:
                let newZ = cameraTranslation[2] + CAMERA_CHANGE_MODIFIER
                frameInfo.cameraTranslation = [cameraTranslation[0], cameraTranslation[1], newZ]
                break
            case E_KEY:
                let newZ = cameraTranslation[2] -  CAMERA_CHANGE_MODIFIER
                frameInfo.cameraTranslation = [cameraTranslation[0], cameraTranslation[1], newZ]
                break

            case P_KEY:
                break
            default:
                print(keyCode)
                break
        }
        
        frameInfo.rotateX = frameInfo.rotateX.truncatingRemainder(dividingBy: 360.0)
        frameInfo.rotateY = frameInfo.rotateY.truncatingRemainder(dividingBy: 360.0)
        frameInfo.rotateZ = frameInfo.rotateZ.truncatingRemainder(dividingBy: 360.0)
        print("Frameinfo: \(frameInfo)")
        updateAll()
        renderUtils.setRenderInfo(frameInfo: frameInfo)

    }

    func setupFrameInfo(_ view: MTKView) {
        print("Setting up frame info")
        frameInfo = FrameInfo(
                viewWidth: 0,
                viewHeight: 0,
                viewDiffRatio: 0.0,
                rotateX: 5.5,
                rotateY: 0.7,
                rotateZ: 1.4,
                xPos: 0.0,
                yPos: 0.0,
                zPos: 4.0,
                zoom: 1,
                near: 0.1,
                far: 100.0,
                cameraRotation: [-0.26, 1.3, 0.0],
                cameraTranslation: [1.0, 2.0, 4.0]
        )
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
        
        frameInfo.viewWidth = Int32(width)
        frameInfo.viewHeight = Int32(height)
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
        
        handleActiveKey()
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "Frame command buffer"

        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.inflightSemaphore.signal()
            }
            return
        }

        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {

            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
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
