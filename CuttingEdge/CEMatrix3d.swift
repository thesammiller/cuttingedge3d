//
//  Matrix3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit
import Foundation

class Matrix3d {
    
    var Matrix: float4x4
    var RMatrix: float4x4
    var Xr, Zr, Yr: Int
    var XTrans, YTrans, ZTrans: Float

    init(_ M: float4x4) {
        
        Matrix = M
        RMatrix = float4x4(EMPTYVECTOR, EMPTYVECTOR, EMPTYVECTOR, EMPTYVECTOR)
        
        Zr = 0
        Yr = 0
        Xr = 0
        
        XTrans = Float(0)
        YTrans = Float(0)
        ZTrans = Float(0)
        
        
    }
    init() {
        Matrix = IDENTITY_MATRIX
        RMatrix = EMPTY_MATRIX
        
        Zr = 0
        Yr = 0
        Xr = 0
        
        XTrans = Float(0)
        YTrans = Float(0)
        ZTrans = Float(0)
        
    }
    func GetXt() -> Float { return XTrans }
    func GetYt() -> Float { return YTrans }
    func GetZt() -> Float { return ZTrans }
    
    //Merge Matrix functions are basically addition operation on matrix
    func MergeMatrices(left: float4x4, right: float4x4) -> float4x4 {
        return (left + right)
    }
    // set passed matrix as identity matrix
    // deprecating - just set to identity matrix... Swift handles the memory issue
    
    //func MTLRotate --> COULD WE KEEP LUT in the GPU???
    
    func Rotate(Xa: Int, Ya: Int, Za: Int) {
        Xr = Xa
        Yr = Ya
        Zr = Za
        var Rmat: float4x4
        
        RMatrix = IDENTITY_MATRIX
        
        print("Rotating Matrices... Looking up Cos/Sin manually.")
        print("Consider using Look Up Tables.")
        
        //initialize Z rotation first
        Rmat = IDENTITY_MATRIX
        Rmat[0][0] = cos(Float(Za))
        Rmat[0][1] = sin(Float(Za))
        Rmat[1][0] = sin(Float(Za))
        Rmat[1][1] = cos(Float(Za))
        
        RMatrix *= Rmat
        
        //initialize X Rotation Matrix
        Rmat = IDENTITY_MATRIX
        Rmat[1][1] = cos(Float(Xa))
        Rmat[1][2] = sin(Float(Xa))
        Rmat[2][1] = sin(Float(Xa))
        Rmat[2][2] = cos(Float(Xa))
        
        RMatrix *= Rmat
        
        //initialize Y Rotation Matrix
        Rmat = IDENTITY_MATRIX
        Rmat[0][0] = cos(Float(Ya))
        Rmat[0][2] = sin(Float(Ya))
        Rmat[2][0] = sin(Float(Ya))
        Rmat[2][2] = cos(Float(Ya))
        
        RMatrix *= Rmat
        
        Matrix *= RMatrix
        
    }
    
    //p. 233
    func Translate(Xt: Float, Yt: Float, Zt: Float) {
        //create initialized matrix
        var T = Matrix3d()
        
        //save translation values
        XTrans = Xt
        YTrans = Yt
        ZTrans = Zt
        
        //Create translation matrix, effecting last row only
        T.Matrix[3] = simd_make_float4(Xt, Yt, Zt, 1)
        
        //merge matrix with master matrix
        Matrix *= T.Matrix
        
    }
    
    func Scale(Xs: Float, Ys: Float, Zs: Float) {
        var S = Matrix3d()
        
        S.Matrix[0][0] = Xs
        S.Matrix[1][1] = Ys
        S.Matrix[2][2] = Zs
        
        Matrix *= S.Matrix
    }
    
    func Shear(Xs: Float, Ys: Float) {
        //create 3d shearing matrix
        var S = Matrix3d()
        
        S.Matrix[0][2] = Xs
        S.Matrix[1][2] = Ys
        
        Matrix *= S.Matrix
    }
    
    //function to transform the vertex using the master matrix
    func Transform(_ V: Point3d) -> Point3d {
        var p: Point3d = V
        p.world = Matrix * V.local
        return p
    }
    
    func Transform(_ V: Vector) -> Vector {
        var p: Vector = V
        p.transformed = Matrix * V.direction
        return p
    }
    
    
}
