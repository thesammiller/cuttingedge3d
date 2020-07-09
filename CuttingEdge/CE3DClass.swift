//
//  3DClass.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import Foundation
import MetalKit


let DEBUG = true
let DEBUGMOUSE = false // xy mouse location... it's a lot

public func debugMsg(_ S: String) {
    if DEBUG {
        print(S)
    }
}

//unimplemented -- FAKE NUMBERS ---> if you see strange behavior...
let COLOR_RANGE = 255
let COLOR_START = 0
let DEGREECOUNT = 1024



//********************
// helpers for the indexing of functions
//********************
let x = 0
let y = 1
let z = 2

let LIGHTX: Float = 1000
let LIGHTY: Float = 100
let LIGHTZ: Float = 4

let EMPTYVECTOR = simd_make_float4(0)
let EMPTYXVECTOR = simd_make_float4(1, 0, 0, 0)
let EMPTYYVECTOR = simd_make_float4(0, 1, 0, 0)
let EMPTYZVECTOR = simd_make_float4(0, 0, 1, 0)
let BLANK_VECTOR = simd_make_float4(0, 0, 0, 1)

let IDENTITY_MATRIX = float4x4(EMPTYXVECTOR, EMPTYYVECTOR, EMPTYZVECTOR, BLANK_VECTOR)
let EMPTY_MATRIX = float4x4(EMPTYVECTOR, EMPTYVECTOR, EMPTYVECTOR, EMPTYVECTOR)

//************************
//Cutting Edge Constants
//************************


// THINK TWICE BEFORE ALTERING MAGIC NUMBERS... 

let PI = 3.141592654
let MINX = Float(-1000.0)
let MAXX = Float(1000.0)
let MINY = Float(-1000.0)
let MAXY = Float(1000.0)
let WIDTH = Float(320)
let HEIGHT = Float(200)
let XCENTER = 160
let YCENTER = 100
let MINZ = Float(100.0)
let MAXZ = Float(2000.0)
let XSCALE = 120
let YSCALE = -120

//BUFFER VARIABLE???? What does ZBuffer do?
var ZBuffer: [Float] = []
var ZTrans: Float = 0

var CosTable: [Float] = []
var SinTable: [Float] = []


func InitMath() {
    var Unit: Float
    Unit = Float(PI) * Float(2) / Float(DEGREECOUNT)
    
    for N in 0...DEGREECOUNT {
        let Degree = Float(N)
        CosTable[N] = Float(cos(Unit*Degree))
        SinTable[N] = Float(sin(Unit*Degree))
    }
}

