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

public var device: MTLDevice!
public var vertexBuffer: MTLBuffer!
public var pipelineState: MTLRenderPipelineState!
public var commandQueue: MTLCommandQueue!
public var vCount: Int = 0
public var library: MTLLibrary?

public var VertexData: [simd_float3] = []

class Renderer: NSObject, MTKViewDelegate {
    
    /*var vertices: [Float] = [
        -1, 1, 0,
        -1, -1, 0,
        1, -1, 0,
    ]
    
    var indices: [UInt16] = [
        0, 1, 2] */
    
    //var indexBuffer: MTLBuffer!
    
    var M: Matrix3d!
    var V: CEView!
    var W: PanelObject!
    
    
    init(metalView: MTKView) {
        
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        print("No MTL Compute commands have been implemented.")
        
        library = device.makeDefaultLibrary()
        
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
        
        M = Matrix3d()
        M.Translate(0, -600, 0)

        V = CEView()
        W = PanelObject()
        W = W.DXFLoadModel("TEST")

        CreateWorld(W: W, M: M, V: V)
        
    }
}


// Building Model and Pipeline State
extension Renderer {
    
    public static func buildModel() {
        vertexBuffer = device.makeBuffer(bytes: &VertexData, length: MemoryLayout<simd_float3>.size, options: [])
        
        
        
        /*vertexBuffer = Renderer.device.makeBuffer(bytes: vertices,
                                         length: vertices.count*MemoryLayout<Float>.size,
                                         options: []) as! MTLBuffer */
        
        /*indexBuffer = Renderer.device.makeBuffer(bytes: indices,
                                                 length: indices.count * MemoryLayout<UInt16>.size,
                                                 options: []) as! MTLBuffer */
    }
    
    public static func buildPipelineState(vFunc: String, fFunc: String) {
        
        let vertexFunction = library?.makeFunction(name: vFunc)
        let fragmentFunction = library?.makeFunction(name: fFunc)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
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
        
        WorldLoop(W: W, M:M, V:V)
        Renderer.buildModel()
        Renderer.buildPipelineState(vFunc: "vertex_main", fFunc: "fragment_main")
        
        
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return }
        if pipelineState != nil {
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vCount)
        }
        
        // ENDING
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}


