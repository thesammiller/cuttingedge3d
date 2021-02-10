//
//  Matrix3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit
import Foundation

public class Matrix3d {
    
    var Matrix: float4x4
    var RMatrix: float4x4
    var Xr, Zr, Yr: Float
    var XTrans, YTrans, ZTrans: Float

    init(_ M: float4x4) {
        
        Matrix = M
        RMatrix = EMPTY_MATRIX
        
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
    
    func Rotate(_ Xa: Float, _ Ya: Float, _ Za: Float) {
        Xr = Xa
        Yr = Ya
        Zr = Za
        var Rmat: float4x4
        
        RMatrix = IDENTITY_MATRIX
        
        //print("Rotating Matrices...")
        //TODO: Cos/Sin manually
      // make it LUT (?)
        
        //initialize Z rotation first --> translate to radians
        let fZa = Float(Za) * PI / 180
        
        Rmat = IDENTITY_MATRIX
        Rmat[0][0] = cos(fZa)
        Rmat[0][1] = sin(fZa)
        Rmat[1][0] = sin(fZa)
        Rmat[1][1] = cos(fZa)
        
        RMatrix *= Rmat
        
        //initialize X Rotation Matrix
        let fXa = Float(Xa) * PI / 180
        let cosfxa = cos(fXa)
        let sinfxa = sin(fXa)
        
        Rmat = IDENTITY_MATRIX
        Rmat[1][1] = cosfxa
        Rmat[1][2] = sinfxa
        Rmat[2][1] = sinfxa
        Rmat[2][2] = cosfxa
        
        RMatrix *= Rmat
        
        //initialize Y Rotation Matrix
        let fYa = Float(Ya) * PI/180
        let cosfya = cos(fYa)
        let sinfya = sin(fYa)
        
        Rmat = IDENTITY_MATRIX
        Rmat[0][0] = cosfya
        Rmat[0][2] = sinfya
        Rmat[2][0] = sinfya
        Rmat[2][2] = cosfya
        
        RMatrix *= Rmat
        
        Matrix *= RMatrix
        
    }
    
    //p. 233
    func Translate(_ Xt: Float, _ Yt: Float, _ Zt: Float) {
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
    
    func Scale(_ Xs: Float, _ Ys: Float, _ Zs: Float) {
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
        p.world = self.Matrix * V.local
        return p
    }
    
    func Transform(_ V: Vector) -> Vector {
        var p: Vector = V
        p.transformed = Matrix * V.direction
        return p
    }
    
  
  static func perspectiveProjection(_ aspect: Float32,
                                    fieldOfViewY: Float32,
                                    near: Float32,
                                    far: Float32) -> Matrix3d
  {
    var mat = Matrix3d()
    
    let fovRadians = fieldOfViewY * Float32(PI / 180)
    
    let yScale = 1 / tan(fovRadians * 0.5)
    let xScale = yScale / aspect
    let zRange = far - near
    let zScale = -(far + near) / zRange
    let wzScale = -2 * far * near / zRange
    
    mat.Matrix[0].x = fovRadians * fieldOfViewY
    mat.Matrix[1].y = fovRadians
    mat.Matrix[2].z = zScale
    mat.Matrix[2].w = wzScale
    mat.Matrix[2].w = -1
    
    
    return mat
  }
    
}
