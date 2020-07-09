//
//  LineType.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/22/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

class CeilLine {
    var X1, X2, Y1, Y2: Float
    var X, StepX, StepZ, Z: Float
    var EdgeHeight, Y: Float
    
    init (P1: Point2d = Point2d(), P2: Point2d = Point2d()) {
        
        var FWidth, DeltaZ, Z1, Z2: Float
        
        X1 = P1.X; X2 = P2.X
        Y1 = P1.Y; Y2 = P2.Y
        Z1 = P1.Z; Z2 = P2.Z
        
        EdgeHeight = ( Y2 - Y1 )
        FWidth = (X2-X1)
        DeltaZ = (Z2-Z1)
        
        X = X1
        Y = Y1
        Z = Z1
        
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
    
    func Step(Amount: Float) {
        X += (StepX * Amount)
        Y += (Amount)
        Z += (StepZ * Amount)
        EdgeHeight -= (Amount)
    }
    
    static func + (left: CeilLine, right: Float) -> Point2d {
        var Temp = Point2d()
        Temp.X = left.X  + (left.StepX * right)
        Temp.Y = left.Y + (right)
        Temp.Z = left.Z + (left.StepZ + right)
        return Temp
    }
    
    //steps edge by amount (right value)
    static func += (left: CeilLine, right: Float) {left.Step(Amount: right)}
    
    
    func Height() -> Float {
        return EdgeHeight
    }
    
    func GetY() -> Float {
        return Y
    }
    
    func GetX() -> Float {
        return X
    }
    
    func GetZ() -> Float {
        return Z
    }
    
    func ClipTop(_ Top: Float) {
        var SlopeX: Float
        var Step, h: Float
        
        h = Y2 - Y1
        
        if (Y<Top) {
            if (h > 0) {
            Step = Top - Y
            SlopeX = X2-X1 / h
            X = X1 + SlopeX * Step
            Y = Top
            Z += StepZ * Step
            EdgeHeight -= Step
            }
        }
    }
}


