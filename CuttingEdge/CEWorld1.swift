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
var FrameCount: Float = 0


public class CEView {
    
    var XRot, YRot, ZRot: Float
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

func UpdatePos(V: CEView) -> CEView {
    let X = Float(MouseX-50)
    let Y = Float(MouseY-50)
    
    if MouseClick {
        V.ZPos -= Y * Float(3)
        V.YRot += Float(X)
    }
    return V
}

public func CreateWorld(W: PanelObject, M: Matrix3d, V: CEView)  {
    var World = W
    var Matrix = M
    
    ZTrans = 0
    var v = CEView()
    v = UpdatePos(V: V)
    
  
  //CEView Z Position
    Matrix.Translate(0, 0, -v.ZPos)
    Matrix.Rotate(-v.XRot, v.YRot, -v.ZRot)
    v.Clear()
    
    
    VertexData = World.Display(Matrix)
    
      // Metal Test Data --> 2D Points
    /*VertexData = [SIMD3<Float>(-1.0, -1.0, 0.5), SIMD3<Float>(-1.0, 0.0, 0.5), SIMD3<Float>(1.0, 1.0, 0.5)]*/
    
    FrameCount = 0
    StartTime = clock()
}

public func WorldLoop(W: PanelObject, M: Matrix3d, V: CEView) -> [simd_float3] {
    
    
    //var FramesPerSecond: Float
    //var MaxWait: Float
    //MaxWait = Float(256*256)
    
    var v = UpdatePos(V: V)
    M.Translate(0, 0, -v.ZPos)
    M.Rotate(-v.XRot, v.YRot, -v.ZRot)
    v.Clear()
    
    /*ZTrans += 1
    if (FrameCount / Float(MaxWait) == 1) {
        ZTrans = 0
        ZBuffer = [:]
    }*/
    
    VertexData = W.Display(M)
  
    return VertexData
    
    
    //Test Data
  /*VertexData = [SIMD3<Float>(0.0, 0.0, 1.0), SIMD3<Float>(-1.0, 0.0, 0.5), SIMD3<Float>(1.0, 0.0, 0.0)] */
    
        
    /*EndTime = clock()
    let FrameTime = EndTime-StartTime
    print("FrameTime: \(FrameTime)")
    StartTime = EndTime*/
    
}


