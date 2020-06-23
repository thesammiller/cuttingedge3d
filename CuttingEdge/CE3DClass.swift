//
//  3DClass.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import Foundation

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

//************************
//Cutting Edge Constants
//************************

let PI = 3.141592654
let MINX = 10
let MAXX = 309
let MINY = 10
let MAXY = 189
let WIDTH = 320
let HEIGHT = 200
let XCENTER = 160
let YCENTER = 100
let MINZ = Float(100)
let MAXZ = Float(10000)
let XSCALE = 120
let YSCALE = -120

//BUFFER VARIABLE???? What does ZBuffer do?
var ZBuffer: [Int] = []
var ZTrans: Int = 0

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

