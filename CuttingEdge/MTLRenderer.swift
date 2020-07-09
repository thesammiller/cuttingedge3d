//
//  Renderer.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

struct rgba {
    var red: Double = 0.9
    var green: Double = 0.9
    var blue: Double = 0.8
    var alpha: Double = 1
}

public let VFUNC = "basic_vertex"
public let FFUNC = "basic_fragment"

public var device: MTLDevice!
public var vertexBuffer: MTLBuffer!
public var pipelineState: MTLRenderPipelineState!
public var commandQueue: MTLCommandQueue!
public var vCount: Float = 0
public var library: MTLLibrary?

public var VertexData: [simd_float3] = []

class Renderer: NSObject, MTKViewDelegate {
    
    /*var vertices: [Float] = [
        -1, 1, 0,
        -1, -1, 0,
        1, -1, 0,
    ]
    
    var indices: [UFloat16] = [
        0, 1, 2] */
    
    //var indexBuffer: MTLBuffer!
    
    var M: Matrix3d!
    var V: CEView!
    var W: PanelObject!
    
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    var commandQueue: MTLCommandQueue!
    
    let device: MTLDevice
    let mtkView: MTKView
    
    
    init(metalView: MTKView, device: MTLDevice) {
        
        self.device = device
        self.mtkView = metalView
        
        commandQueue = device.makeCommandQueue()
        
        print("No MTL Compute commands have been implemented.")
        
        // super init in the middle
        super.init()
        // middle
        
        M = Matrix3d()
        M.Translate(0, -600, 0)

        V = CEView()
        W = PanelObject()
        W = W.DXFLoadModel("TEST")

        CreateWorld(W: W, M: M, V: V)
        
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        
        //Trigger Game Engine --> Loads VertexData
        WorldLoop(W: W, M:M, V:V)
        
        if VertexData.count == 0 {
            VertexData = [simd_float3(repeating: 0)]
        }
        
        //recalculate dataSize
        let dataSize = VertexData.count * MemoryLayout.size(ofValue: VertexData[0])
        
        //Vertex Buffer made out of Vertex Data loaded in Game Engine Loop
        vertexBuffer = device.makeBuffer(bytes:&VertexData, length: dataSize, options: [[]])
        
        //library functions
        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexProgram = defaultLibrary.makeFunction(name: VFUNC)
        let fragmentProgram = defaultLibrary.makeFunction(name: FFUNC)
        
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
                
        commandQueue = device.makeCommandQueue()
            
            
        guard let drawable = mtkView.currentDrawable else {return}
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor( red: 1.0,
                                                                             green: 1.0,
                                                                                    blue: 0,
                                                                                    alpha: 1)
        let commandBuffer = commandQueue.makeCommandBuffer()!
            
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: VertexData.count, instanceCount: 1)
        renderEncoder.endEncoding()
                
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        
    }
}


