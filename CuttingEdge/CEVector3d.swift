//
//  Vector3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

public struct Vector {
    var transformed: simd_float4 = simd_make_float4(0) // Tx, Ty,Tz 
    var direction: simd_float4 = simd_make_float4(0) // x, y, z vector
}
