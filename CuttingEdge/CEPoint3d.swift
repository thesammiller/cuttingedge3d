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



public class Point3d {
    
    var local: simd_float4
    var world: simd_float4
    
    
    init(_ local: simd_float4=EMPTYVECTOR, world: simd_float4=EMPTYVECTOR) {
        self.local = local
        self.world = world
    }
}

extension Point3d: Equatable {
    
    // ****************
    // POINT FUNCTIONS
    // ****************
    
    static func != (left: Point3d, right: Point3d) -> Bool {
        return left.local != right.local
    }
    
    public static func == (left: Point3d, right: Point3d) -> Bool {
        return left.local == right.local
    }
    
    static func - (left: Point3d, right: Point3d) -> Point3d {
        let t = Point3d()
        t.local = left.local - right.local
        return t
    }
    
    static func + (left: Point3d, right: Point3d) -> Point3d {
        let t = Point3d()
        t.local = left.local + right.local
        return t
    }
    
    static func * (left: Point3d, right: Point3d) -> Point3d {
        let t = Point3d()
        t.local = left.local * right.local
        return t
    }
    
    static func / (left: Point3d, right: Point3d) -> Point3d {
        let t = Point3d()
        t.local = left.local / right.local
        return t
    }
    
    static func -= (left: inout Point3d, right: Point3d) {
        left.local -= right.local
    }
    
    static func += (left: inout Point3d, right: Point3d) {
        left.local += right.local
    }
    
    static func *= (left: inout Point3d, right: Point3d) {
        left.local *= right.local
    }
    
    static func /= ( left: inout Point3d, right: Point3d) {
        left.local /= right.local
    }
    static func /= (left: inout Point3d, right: Float) {
        left.local /= right
    }
    
    //******************
    // SCALAR FUNCTIONS
    // ****************

    static func *= (left: inout Point3d, right: Float) {
        left.local *= right
    }
    
    
    
    static func += (left: inout Point3d, right: Float) {
        left.local[x] += right
        left.local[y] += right
        left.local[z] += right
    }
    
    static func -= (left: inout Point3d, right: Float) {
        left.local[x] -= right
        left.local[y] -= right
        left.local[z] -= right
    }
    
    static func * (left: Point3d, right: Float) -> Point3d {
          let t: Point3d = Point3d()
          t.local[x] = left.local[x] * right
          t.local[y] = left.local[y] * right
          t.local[z] = left.local[z] * right
          return t
      }
      
      static func / (left: Point3d, right: Float) -> Point3d {
          let t: Point3d = Point3d()
          t.local[x] = left.local[x] / right
          t.local[y] = left.local[y] / right
          t.local[z] = left.local[z] / right
          return t
      }
      
      static func + (left: Point3d, right: Float) -> Point3d {
          let t: Point3d = Point3d()
          t.local[x] = left.local[x] + right
          t.local[y] = left.local[y] + right
          t.local[z] = left.local[z] + right
          return t
      }
      
      static func - (left: Point3d, right: Float) -> Point3d {
          let t: Point3d = Point3d()
          t.local[x] = left.local[x] - right
          t.local[y] = left.local[y] - right
          t.local[z] = left.local[z] - right
          return t
      }
    
    

    func Mag() -> Float {
        return sqrt( pow(self.local[0], 2) + pow(self.local[1], 2) + pow(self.local[2], 2) )
    }

    func MTLMag() -> Double {
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
    var c = 0
    if List == [] {
        return false }
    for count in List {
        if c < Range {
            //if it's not unique (we find a match), return false
            if V == count {
                return false
            }
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
    if Range > 0 {
        for count in 0...Range {
            if V == List [ count ] {
                return count
            }
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
