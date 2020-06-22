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

class Renderer: NSObject, MTKViewDelegate {
    
    
    var vertices: [Float] = [
        -1, 1, 0,
        -1, -1, 0,
        1, -1, 0,
    ]
    
    var indices: [UInt16] = [
        0, 1, 2]
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
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
        
        //mdlMesh
        // vertexBuffer = mesh.vertexBuffers[0].buffer
        // do something more manual below
        // should steal the indexed triangles from the video for Ray Wenderlich
        //let data: [Int] = [3]
        
        // super init in the middle
        super.init()
        // middle
        
        buildModel()
        buildPipelineState()
        
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
        
        
    }
}


// Building Model and Pipeline State
extension Renderer {
    
    private func buildModel() {
        vertexBuffer = Renderer.device.makeBuffer(bytes: vertices,
                                         length: vertices.count*MemoryLayout<Float>.size,
                                         options: []) as! MTLBuffer
        indexBuffer = Renderer.device.makeBuffer(bytes: indices,
                                                 length: indices.count * MemoryLayout<UInt16>.size,
                                                 options: []) as! MTLBuffer
    }
    
    private func buildPipelineState() {
        let library = Renderer.device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    
    }
    
}

//MTKViewDelegate Conformity
extension Renderer {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable
                else { return }
        
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return }
        
        
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
        
        // ENDING
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

