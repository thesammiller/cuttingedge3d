//
//  Renderer.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

struct rgba {
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0
    var alpha: Double = 1
}

class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available.")
        }
        
        print("No MTL Compute commands have been implemented.")
        
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        // super init in the middle
        super.init()
        // middle
        
        var clearColor = rgba()
        clearColor.green = 1
        
        metalView.clearColor = MTLClearColor(red: clearColor.red,
                                             green: clearColor.green,
                                             blue: clearColor.blue,
                                             alpha: clearColor.alpha)
        
        metalView.delegate = self
        // mdlmesh
        
        // create library of metal shaders
        // what is in the metal shader default library?
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // for submesh in meshes
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

