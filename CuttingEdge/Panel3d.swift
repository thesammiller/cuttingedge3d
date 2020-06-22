//
//  Panel3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit


class Panel3d {
    
    var VPoint: [Point3d] = [Point3d(), Point3d(), Point3d(), Point3d()]
    var SPoint: [Float] = [Float(0), Float(0), Float(0), Float(0), Float(0)]
    var Normal: Vector = Vector()
    
    var SPCount: Int = 0
    var Invis: Int = 0
    var Color: Int = 0
    var Padding: Int = 0
    
    var Radius: Double = 0
    
    init () {    }
    
    func HasVert(P: Point3d) -> Bool {
        return VPoint.contains(P)
    }
    
    func MTLHasVert(P: Point3d) -> Bool {
        //I'd think that a true/false like this would be embarrassingly parallel
        print("Panel3d -> MTLHasVert not implemented.")
        return false
    }
}

class PanelObject: Panel3d { }


