//
//  Point3d.swift
//  Cutting Edge 3d Programming in C++
//
//  John de Goes
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

let defaultValue = simd_make_float4(0)

class Point3d: Equatable {
    
    var local: simd_float4
    var world: simd_float4
    
    
    init(_ local: simd_float4=defaultValue, world: simd_float4=defaultValue) {
        self.local = local
        self.world = world
    }
    
    static func != (left: Point3d, right: Point3d) -> Bool {
        return left.local != right.local
    }
    
    static func == (left: Point3d, right: Point3d) -> Bool {
        return left.local == right.local
    }
    
    static func - (left: Point3d, right: Point3d) -> Point3d {
        var t = Point3d()
        t.local = left.local - right.local
        return t
    }
    
    static func + (left: Point3d, right: Point3d) -> Point3d {
        var t = Point3d()
        t.local = left.local + right.local
        return t
    }
    
    static func * (left: Point3d, right: Point3d) -> Point3d {
        var t = Point3d()
        t.local = left.local * right.local
        return t
    }
    
    static func / (left: Point3d, right: Point3d) -> Point3d {
        var t = Point3d()
        t.local = left.local / right.local
        return t
    }
    
    static func -= (left: Point3d, right: Point3d) -> Point3d {
        left.local -= right.local
        return left
    }
    
    static func += (left: Point3d, right: Point3d) -> Point3d {
        left.local += right.local
        return left
    }
    
    static func *= (left: Point3d, right: Point3d) -> Point3d {
        left.local *= right.local
        return left
    }
    
    static func /= (left: Point3d, right: Point3d) -> Point3d {
        left.local /= right.local
        return left
    }

    static func * (left: Point3d, right: Float) -> Point3d {
        left.local *= right
        return left
    }
    
    static func / (left: Point3d, right: Float) -> Point3d {
        left.local /= right
        return left
    }
    
    static func + (left: Point3d, right: Float) -> Point3d {
        left.local[0] += right
        left.local[1] += right
        left.local[2] += right
        return left
    }
    
    static func - (left: Point3d, right: Float) -> Point3d {
        left.local[0] -= right
        left.local[1] -= right
        left.local[2] -= right
        return left
    }

    func Mag() -> Float {
        return sqrt( pow(self.local[0], 2) + pow(self.local[1], 2) + pow(self.local[2], 2) )
    }

    func MTLMag() -> Float {
        // metal has a sqrt unction...
        return 0
    }
    
    
    // metal implementation?
    func DotUnit(_ foreign: Point3d) -> Float {
        return dot(self.local, foreign.local)
    }
    
    func MTLDotUnit(_ foreign: Point3d) -> Float {
        print("Point3d->MTLDotUnit not implemented.")
        //need to read up on threads/thread groups
        //need to figure out how to have one thread for computation, one for graphics
        return Float(0.0)
    }
    
    func DotNotUnit(_ foreign: Point3d) -> Float {
        
        var dot: Float
        dot = ( self.local[0] * foreign.local[0] + self.local[1] * foreign.local[1] +
            self.local[2] * foreign.local[2] ) / ( self.Mag() * foreign.Mag() )
        return dot
    }
    
    func MTLDotNotUnit(_ foreign: Point3d) -> Float {
        print("Point3d->MTLDotNotUnit not implemented.")
        //how can we parallel this?
        return Float(0.0)
    }
    
}

func UniqueVert(V: Point3d, List: [Point3d], Range: Int) -> Bool {
    for count in 0...Range {
        //if it's not unique, return false
        if V == List[ count ] {
            return false
        }
    }
    return true
}

func MTLUniqueVert(V: Point3d, List: [Point3d], Range: Int) -> Bool {
    //if it's a for loop, it can be paralleled!
    print("MTLUniqueVert not implemented")
    return false
}

func GetVertexIndex (V: Point3d, List: [Point3d], Range: Int) -> Int {
    for count in 0...Range {
        if V == List [ count ] {
            return count
        }
    }
    return 0
}

func MTLGetVertexIndex(V: Point3d, List: [Point3d], Range: Int) -> Int {
    //this should be able to be paralized since it's a for loop
    // send out each index to test true/false... would be able to process much faster than a loop through thousands of vertex
    // QUESTION: How to return the count if done this way?
    // Can this be implemented with a metal shader?
    
    print("MTLGetVertexIndex not implemented in Point3d.")
    return 0
}
