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
        var Mag: Float
        Mag = sqrt(Light.X * Light.X +
            Light.Y * Light.Y +
            Light.Z * Light.Z  )
        
        var CosA: Float
        CosA = ( (Normal.direction[x] - VPoint[0].local[x]) * Light.X +
            (Normal.direction[y] - VPoint[0].local[y]) * Light.Y +
            (Normal.direction[z] - VPoint[0].local[z]) * Light.Z ) / Mag
            
        Color = Double(CosA * COLOR_RANGE + COLOR_START)
    }
        
    func Project() {
        SPCount = 4
        var Count: Int = 0
        var OutCount: Int = 0
        var OneOverZ: Float
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
            
            // this right now multiplies to 1 --> will need to return to logic
            SPoint[Count].Z = OneOverZ * Float((1 * ZSTEP_PREC)) // C++ uses 1 << bit shift
            
        }
        
        
    }
    
    func CalcNormal() {
        var X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3, Distance, A, B, C: Float
        var UniqueVerts: [Point3d] = []
        var TVert: Point3d
        var Range: Int = 0
        
        for Count in 0...4 {
            TVert = VPoint[Count]
            if (Range == 0) {
                UniqueVerts[Range] = TVert
                Range+=1
            }else {
                if UniqueVert(V: TVert, List: UniqueVerts, Range: Range) {
                    UniqueVerts[Range] = TVert
                    Range += 1
                }
            }
        }
        
        X1 = UniqueVerts[0].local[x]
        Y1 = UniqueVerts[0].local[y]
        Z1 = UniqueVerts[0].local[z]
        
        X2 = UniqueVerts[1].local[x]
        Y2 = UniqueVerts[1].local[y]
        Z2 = UniqueVerts[1].local[z]
        
        X3 = UniqueVerts[2].local[x]
        Y3 = UniqueVerts[2].local[y]
        Z3 = UniqueVerts[2].local[z]
        
        //use plane equation to determine plane orientation
        A = Y1 * (Z2-Z3) + Y2 * (Z3-Z1) + Y3 * (Z1-Z2)
        B = Z1 * (X2-X3) + Z2 * (X3-X1) + Z3 + (X1-X2)
        C = X1 * (Y2-Y3) + X2 * (Y3-Y1) + X3 * (Y1-Y2)
        
        //Get the distance to the vector
        Distance = sqrt(A*A + B*B + C*C)
        
        //Normalize the normal to 1 and create a point
        Normal.direction[x] = (A/Distance) + VPoint[0].local[x]
        Normal.direction[y] = (B/Distance) + VPoint[0].local[y]
        Normal.direction[z] = (C/Distance) + VPoint[0].local[z]
    }
    
    func CalcBFace() -> Int {
        //determine if polygon is a backface
        var Visible: Int = 1
        var Invis: Int = 0
        var Direction: Float
        
        var V: Point3d = VPoint[0]
        
        Direction = V.world[x] * (Normal.transformed[x] - VPoint[0].world[x]) +
        V.world[y] * (Normal.transformed[y] - VPoint[0].world[y]) +
        V.world[z] * (Normal.transformed[z] - VPoint[0].world[z])
        
        if Direction > Float(0) {
            //get the cosine of the angle between the viewer and the polygon normal
            Direction /= V.Mag()
            //assume panel will remain time proportional to the angle between the viewer to the normal
            Invis = Int(Direction * Float(25))
            Visible = 0
            
        }
        return Visible
    }
    
    func CalcVisible3d() -> Int {
        //perform 3d culling
        
        //assume panel is visible
        var Visible: Int
        
        Visible = CalcBFace()
        
        //If Panel still visible perform extent test
        //is there a better way to bool an int in swift? WTF is this language.
        if (Visible == 1) {
            Visible = CheckExtents()
        }
        return Visible
    }
    
    func CalcCenterZ() -> Float {
        var SummedComponents, CenterZ: Float
        
        SummedComponents = VPoint[0].world[z] +
                            VPoint[1].world[z] +
                            VPoint[2].world[z] +
                            VPoint[3].world[z]
        
        CenterZ = SummedComponents/Float(VPoint.count)
        
        return CenterZ
        
    }
    
    
    func CalcVisible2d() -> Int {
        // perform 2d culling
        var XMinInVis: Int = 0
        var XMaxInVis: Int = 0
        var YMinInVis: Int = 0
        var YMaxInVis: Int = 0
        var Visible: Int = 1
        var AveX: Float = 0
        var AveY: Float = 0
        Invis = 0
        
        // make sure the panel has more than two points
        if (SPCount < 3) {
            //if not, flag panel as invisible
            Visible = 0
            // Assume Panel will remain Invisible for four more frames
            Invis = 4
            return Visible
        }
        for N in 0...SPCount {
            if (SPoint[N].X < MINX) {
                XMinInVis += 1
            }
            else {
                if (SPoint[N].X > MAXX) {
                    XMaxInVis += 1
                }
            }
            if (SPoint[N].Y < MINY) {
                YMinInVis += 1
            }
            else if (SPoint[N].Y > MAXY) {
                YMaxInVis += 1
            }
        
            AveX += SPoint[N].X
            AveY += SPoint[N].Y
        }
        if (XMinInVis >= SPCount) {
            //Assume panel will remain invisible for a time proportional to the distance from the edge of viewport
            AveX /= Float(SPCount)
            Invis = Int(abs(AveX)/(320 * 26)) // NOT SURE WHAT THESE HARD CODED NUMBERS ARE
            print("Hard coded numbers 320 * 26 in CalcVisible 2d in Panel3d")
            Visible = 0
        }
        if (YMinInVis >= SPCount) {
            AveY /= Float(SPCount)
            Invis = Int(abs(AveY)/(200*26))
            print("Hard coded numbers 200*26 in CalcVisible 2d in Panel 3d")
            Visible = 0
            }
        if (XMaxInVis >= SPCount) {
            //assume panel will remain invisible for a time
            AveX /= Float(SPCount)
            Invis = Int((AveX-MAXX) / (320*26))
            Visible = 0
        }
        if (YMaxInVis >= SPCount) {
            AveY/=Float(SPCount)
            Invis = Int((AveY-MAXY)/(200*26))
            Visible = 0
        }

        return Visible
    }
    
    func CheckExtents() -> Int {
        var Visible: Int = 0
        var MinZ: Float
        
        for Count in 0...4 {
            if (VPoint[Count].world[z] > MINZ) {
                Visible = 1
                Invis = 0
                break
            }
        }
        if (Visible == 1) {
            MinZ = VPoint[0].world[z]
            for Count in 0...4 {
                if(VPoint[Count].world[z] < MinZ) {
                    MinZ = VPoint[Count].world[z]
                }
            }
            if (MinZ > MAXZ)
            {
                // set the invisible flag for this frame
                Visible = 0
                // assume panel will remain invisible for time proportional
                Invis = Int((MinZ-MAXZ)/50)
            }
        }
        else {
            //make invisible
            Invis = Int((abs(CalcCenterZ()))/50)
        }
        
        return Visible
    }

    func Update(M: Matrix3d) {
        
        M.Transform(Normal)
        
        if (Invis > 0) {
            Invis -= 1
        }
    }
    
    
    // when do we use the passed in argument?
    func Display(Dest: Int) {
        var RColor: Double // color of the panel
        var DPtr: Int // pointer to the off-screen buffer (!)
        var ZPtr: Int // Zbuffer ptr
        
        var LeftSeg: CeilLine = CeilLine()
        var RightSeg: CeilLine = CeilLine() // used for interpolating values along sides
        
        var Top, RightPos, LeftPos, NewRightPos, NewLeftPos, Height, EdgeCount, YIndex, Width, XStart, XEnd, DeltaZ, ZStep, Z: Int
        Top = 0
        
        RColor = Color
        EdgeCount = SPCount
        
        //Search for lowest Y Coordinate (top of polyon)
        for N in 0...SPCount {
            if (SPoint[N].Y < SPoint[Top].Y) {
                Top = N
            }
        }
        RightPos = Top
        LeftPos = Top
        
        //Calculate the index to the buffer
        YIndex = Int(SPoint[Top].Y * 320)
        print("Hard coded 320 in Panel3d -> Display")
        
        //loop for all Polygon edges
        while (EdgeCount > 0) {
            //determine if the right side of the polygon needs (re)initializing
            if (RightSeg.Height() <= 0) {
                NewRightPos = RightPos + 1
                if (NewRightPos >= SPCount ) {
                    NewRightPos = 0}
                RightSeg.Init(SPoint[RightPos], SPoint[NewRightPos])
                RightPos = NewRightPos
                EdgeCount -= 1
                //perform object precision clip on top edge
                //(if necessary)
                if (RightSeg.GetY() < MINY) {
                    RightSeg.ClipTop(MINY)
                    YIndex = MINY * 320
                    print("Hard coded value 320 in Panel3d->Display->RightSegGetY Conditional")
                }
            }
            //determine if the left side of the polygon needs (re)initializing
            if (LeftSeg.Height() <= 0) {
                NewLeftPos = LeftPos - 1
                if (NewLeftPos < 0) {
                    NewLeftPos = (SPCount - 1 )
                }
                LeftSeg.Init(SPoint[LeftPos], SPoint[NewLeftPos])
                LeftPos = NewLeftPos
                EdgeCount -= 1
                // perform object precision clip if neccessary
                if (LeftSeg.GetY() < MINY) {
                    LeftSeg.ClipTop(MINY)
                    YIndex = MINY * 320
                }
            }
            
            //subdivide polygon into trapezoid
            if (LeftSeg.Height() < RightSeg.Height()) {
                Height = LeftSeg.Height()
                if ( (LeftSeg.GetY() + Height) > MAXY) {
                    Height = MAXY - LeftSeg.GetY()
                    EdgeCount = 0
                }
            } else {
                Height = RightSeg.Height()
                if ( (RightSeg.GetY() + Height ) > MAXY ) {
                    Height = MAXY - RightSeg.GetY()
                    EdgeCount = 0
                }
            }
            
            //loop for the height of the trapezoid
            while (Height > 0) {
                Height -= 1
                XStart = LeftSeg.GetX()
                XEnd = RightSeg.GetX()
                Width = XEnd - XStart
                if (Width > 0) {
                    Z = LeftSeg.GetZ()
                    DeltaZ = (RightSeg.GetZ() - LeftSeg.GetZ() )
                    ZStep = DeltaZ / Width
                    
                    //Clip the scan line
                    ClipHLine(XStart, XEnd, Z, ZStep)
                    Width = XEnd - XStart
                    DPtr = Dest[YIndex + XStart]
                    ZPtr = ZBuffer[YIndex + XStart]
                    
                    //loop for width of scan-LINE_MAX
                    while ( Width > 0 ) {
                        Width -= 1
                        if (ZPtr < Z) {
                            ZPtr = ZPtr
                            DPtr = (Z >> 18) // bit shift
                        }
                        Z += ZStep
                        DPtr += 1
                        ZPtr += 1
                    }
                }
                RightSeg += 1
                LeftSeg += 1
                Index += 320
                    
            }
            
        }
            
    }
    
}

        
