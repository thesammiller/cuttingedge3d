//
//  LineType.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/22/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

let XSTEP_PREC = 10 //used for bitshifting... not sure how that will work here
let ZSTEP_PREC = 26

class CeilLine {
    var X1, X2, Y1, Y2: Int
    var X, StepX, StepZ, Z: Int
    var EdgeHeight, Y: Int
    
    init (P1: Point2d, P2: Point2d) {
        
        var FWidth, DeltaZ, Z1, Z2: Int
        
        X1 = P1.X; X2 = P2.X
        Y1 = P1.Y; Y2 = P2.Y
        Z1 = P1.Z; Z2 = P2.Z
        
        EdgeHeight = ( Y2 - Y1 )
        FWidth = (X2-X1)
        DeltaZ = (Z2-Z1)
        
        X = X1 + CEIL_FRACT
        Y = Y1
        Z = Z1 //+ ZTrans -- What is ZTrans?
        
        if (EdgeHeight > 0) {
            StepX = FWidth / EdgeHeight
            StepZ = DeltaZ / EdgeHeight
        } else {
            StepX = 0
            StepZ = 0
        }
        
    }
    
    func Step() {
        X += StepX
        Y += 1
        Z += StepZ
        EdgeHeight -= 1
    }
    
    func Step(Amount: Int) {
        X += (StepX * Amount)
        Y += (Amount)
        Z += (StepZ * Amount)
        EdgeHeight -= (Amount)
    }
    
    static func + (left: CeilLine, right: Int) -> Point2d {
        var Temp = Point2d()
        Temp.X = left.X  + (left.StepX * right)
        Temp.Y = left.Y + (right)
        Temp.Z = left.Z + (left.StepZ + right)
        return Temp
    }
    
    func Height() -> Int {
        return EdgeHeight
    }
    
    func GetY() -> Int {
        return Y
    }
    
    func GetX() -> Int {
        return X
    }
    
    func GetZ() -> Int {
        return Z
    }
    
    func ClipTop(_ Top: Int) {
        var SlopeX: Float
        var Step, h: Int
        
        h = Y2 - Y1
        
        if (Y<Top) {
            if (h > 0) {
            Step = Top - Y
            SlopeX = Float(X2-X1) / Float(h)
            X = X1 + Int(SlopeX) * Step + CEIL_FRACT
            Y = Top
            Z += StepZ * Step
            EdgeHeight -= Step
            }
        }
    }
}


