//
//  3DClass.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import Foundation
import MetalKit


//DXF file to load for the World Model
let WORLD_MODEL = "TEST4"

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


let EMPTYXVECTOR = simd_float4(1, 0, 0, 0)
let EMPTYYVECTOR = simd_float4(0, 1, 0, 0)
let EMPTYZVECTOR = simd_float4(0, 0, 1, 0)
let BLANK_VECTOR = simd_float4(0, 0, 0, 1)

let IDENTITY_MATRIX = float4x4(1)
let EMPTY_MATRIX = float4x4(0)

//************************
//Cutting Edge Constants
//************************


// THINK TWICE BEFORE ALTERING MAGIC NUMBERS... 

let PI = Float(3.141592654)

let WIDTH = Float(320)
let MINX = 0.05 * WIDTH
let MAXX = 0.945 * WIDTH

let HEIGHT = Float(200)
let MINY = 0.05 * HEIGHT
let MAXY = 0.945 * HEIGHT


let XCENTER = 160
let YCENTER = 100
let MINZ = Float(100.0)
let MAXZ = Float(2000.0)
let XSCALE = Float(120)
let YSCALE = Float(-120)

//ZBuffer is the Dictionary we use to look up Points to find its location relative to Z Value
//Used in Panel Buffer
var ZBuffer: [simd_float2: Float] = [:]
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

