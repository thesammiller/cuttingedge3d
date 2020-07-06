//
//  VWalk1.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/23/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

// Local structs/classes

import MetalKit
import Foundation

var StartTime: clock_t = clock()
var EndTime: clock_t = clock()
var FrameCount: Int = 0


public class CEView {
    
    var XRot, YRot, ZRot: Int
    var ZPos: Float
    
    
    init() {
        XRot = 0
        YRot = 0
        ZRot = 0
        ZPos = Float(0)
    }
    
    func Clear() {
        XRot = 0
        YRot = 0
        ZRot = 0
        ZPos = Float(0)
    }
}

func UpdatePos(V: CEView) {
    let X = Float(MouseX-50) / 4
    let Y = Float(MouseY-50) / 4
    
    if MouseClick {
        V.ZPos -= Y * Float(3)
        V.YRot += Int(X)
    }
}

public func CreateWorld(W: PanelObject, M: Matrix3d, V: CEView)  {
    var World = W
    var Matrix = M
    
    ZTrans = 0
    
    UpdatePos(V: V)
    
    Matrix.Translate(0, 0, -V.ZPos)
    Matrix.Rotate(-V.XRot, V.YRot, -V.ZRot)
    V.Clear()
    
    //2D Points
    VertexData.append(contentsOf: World.Display(Matrix))
    
    print("First world displayed.")
    
    FrameCount = 0
    StartTime = clock()
}

public func WorldLoop(W: PanelObject, M: Matrix3d, V: CEView) {
    
    
    var FramesPerSecond: Float
    var MaxWait: Float
    
    MaxWait = Float(256*256)
    
    
    UpdatePos(V: V)
    M.Translate(0, 0, -V.ZPos)
    M.Rotate(-V.XRot, V.YRot, -V.ZRot)
    V.Clear()
    
    ZTrans += 1
    if (FrameCount % Int(MaxWait) == 0) {
        ZTrans = 0
        ZBuffer = []
    }
    VertexData = []
    VertexData.append(contentsOf: W.Display(M))
    print("World vertex loaded.")
        
    /*vertexBuffer = device.makeBuffer(bytes: &VertexData,
                                                  length: MemoryLayout<simd_float4>.size,
                                                  options: []) as! MTLBuffer
        
      */
    //memmove vidmem, vidbuffer, bytesize
    // this is whatever the mtl commit thing is
        
        
    EndTime = clock()
    FramesPerSecond = Float(FrameCount) /
                            Float(EndTime - StartTime)
    print("FPS: \(FramesPerSecond)")
    
}


