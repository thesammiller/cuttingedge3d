//
//  Panel3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

class Panel3d {
    
    var VPoint: [Point3d] = []
    var SPoint: [Point2d] = []
    var Normal: Vector = Vector()
    
    var SPCount: Int = 0
    var Invis: Int = 0
    var Color: Double = 0
    var Padding: Double = 0
    
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

extension Panel3d {
    
    func CalcRadius() {
        //calculate the radius of the panel
        var TempPoint: [Point3d] = []
        var Center: Point3d = Point3d()
        var Distance: [Double] = []
        var Dist: Double
        
        for Count in 0...4 {
            TempPoint[Count] = VPoint[Count]
        }
        
        for Count in 0...4 {
            Center += TempPoint [Count]
        }
        
        Center /= Float(4.0)
        
        for Count in 0...4 {
            TempPoint[Count] -= Center
        }
        
        for Count in 0...4 {
            Dist = Double(TempPoint[Count].Mag())
            Distance[Count] = Dist
        }
        
        Dist = Distance[0]
        
        for Count in 0...4 {
            if Distance[Count] > Dist {
                Dist = Distance[Count]
            }
        }
        
        Radius = Dist
        
    }
        
    func MTLCalcRadius() {
        print("Panel3d -> MTLCalcRadius not implemented.")
        print("But it might be pretty cool when it is.")
    }
        
    func CalcInten() {
        var Mag: Double
        Mag = sqrt(1) // Light.X * Light.X + Light.Y * Light.Y + Light.Z * Light.Z
            //p. 115 in the book. I'll come back when I need to.
        print("Panel3d -> CalcIntent not implemented. Dummy result.")
        Color = Double(Mag) // pseudo answer for now
    }
        
    func Project() {
        SPCount = 4
        var Count: Int = 0
        var OutCount: Int = 0
        var OneOverZ: Double
        var ZClipPoint: [Point3d] = []
        
        
        var StartI = Int(SPCount - 1)
            
        //for indexing ease
            
        for EndI in 0...SPCount {
            if (VPoint[StartI].world[z] >= MINZ ) {
                if (VPoint[EndI].world[z] >= MINZ) {
                    //entirely inside front view volume
                    //output an unchanged vertex
                    ZClipPoint[OutCount].world = VPoint[EndI].world
                        
                    OutCount += 1
                } else {
                    //SPoint is leaving view volume
                    // clip using parametric form of line
                    var DeltaZ: Float
                    DeltaZ = (VPoint[EndI].world[z] - VPoint[StartI].world[z])
                    var t: Float
                    t = (MINZ - VPoint[StartI].world[z])/DeltaZ
                    
                    ZClipPoint[OutCount].world[x] = VPoint[StartI].world[x] + (VPoint[EndI].world[x] - VPoint[StartI].world[x]) * t
                    ZClipPoint[OutCount].world[y] = VPoint[StartI].world[y] + (VPoint[EndI].world[y] - VPoint[StartI].world[y]) * t
                    ZClipPoint[OutCount].world[z] = MINZ
                        
                        //update index
                    OutCount += 1
                }
            } else {
                    if (VPoint[EndI].world[z] >= MINZ) {
                        //Spoint is entering view volume
                        // clip using parametric form of line
                        var DeltaZ: Float
                        DeltaZ = (VPoint[EndI].world[z] - VPoint[StartI].world[z])
                        var t: Float
                        t = (MINZ - VPoint[StartI].world[z]) / DeltaZ
                        
                        ZClipPoint[OutCount].world[x] = VPoint[StartI].world[x] + (VPoint[EndI].world[x] - VPoint[StartI].world[x]) * t
                        ZClipPoint[OutCount].world[y] = VPoint[StartI].world[y] + (VPoint[EndI].world[y] - VPoint[StartI].world[y]) * t
                        ZClipPoint[OutCount].world[z] = MINZ
                        
                        OutCount += 1
                        
                        //Add an extra edge to the list
                        ZClipPoint[OutCount].world = VPoint[EndI].world
                        
                        OutCount += 1
                    } else {
                        // case 4 in the book... nothing to do
                    }
                }
            //advance to next vertex
            StartI = EndI
            }
        
        //Store the number of vertices in outcount
        SPCount = OutCount
        
        //Project panel points
        for Count in 0...OutCount {
            //calculate 1/z for vector normalization
            OneOverZ = Float(1)/ZClipPoint[Count].world[z]
            
            SPoint[Count].X = ZClipPoint[Count].world[z] * XSCALE * OneOverZ + Float(160)
            SPoint[Count].Y = ZClipPoint[Count].world[z] * XSCALE * OneOverZ + Float(100)
            SPoint[Count].Z = OneOverZ * (1 << ZSTEP_PREC)
            
        }
        
        
    }





}

        
