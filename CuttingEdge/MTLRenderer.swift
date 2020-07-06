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

public let VFUNC = "vertexShader"
public let FFUNC = "frgamentShader"

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

        
        
        metalView.delegate = self
        
        M = Matrix3d()
        M.Translate(0, -600, 0)

        V = CEView()
        W = PanelObject()
        W = W.DXFLoadModel("TEST2")

        CreateWorld(W: W, M: M, V: V)
        
    }
}


// Building Model and Pipeline State
extension Renderer {
    
    public static func buildVertexBuffer() {
        vertexBuffer = device.makeBuffer(bytes: &VertexData, length: MemoryLayout<simd_float3>.size, options: [])
        print("World information buffered.")
        
        
        
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
        
        //Trigger Game Engine --> Loads VertexData
        WorldLoop(W: W, M:M, V:V)
        
        //buildModel creates the Buffer out of VertexData
        Renderer.buildVertexBuffer()
        
        //Builds the pipeline state with the main functions
        Renderer.buildPipelineState(vFunc: VFUNC, fFunc: FFUNC)
        
        
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer() else {
                return }
        
        let clearColor = rgba()
        
        descriptor.colorAttachments[0].clearColor = MTLClearColorMake(clearColor.red,
                                             clearColor.green,
                                             clearColor.blue,
                                             clearColor.alpha)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {return}
        
        //if we have our pipelineState (made in buildPipelineState) --> no errors
        
        
        if pipelineState != nil {
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: VertexData.count)
        }
        
        
        
        // ENDING
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        
    }
}


