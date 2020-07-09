//
//  Panel3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

// this is << XSTEP_PREC, not sure what it really is doing
let CEIL_FRACT = Float(1)


// CLIP A HORIZONTAL Z-BUFFERED LINE
func ClipHLine (X1: Float, X2: Float, Z: Float, ZStep: Float ) -> simd_float4 {
    var f: simd_float4 = simd_make_float4(0)
    var x1, x2, z, zstep: Float
    x1 = X1
    x2 = X2
    z = Z
    zstep = ZStep
    
    if ( x1 < MINX ) {
           // Take advantage of the fact that ( a * ( b * f ) / f )
           // is equal to ( a * b );
        z += zstep * ( MINX - x1 )
        x1 = MINX
    }
    
    //if point x1 is greater than the max, x1 becomes the max
    if ( x1 > MAXX ) {
        x1 = MAXX}
    //if point x2 is less than the min, then x2 becomes the min
    if ( x2 < MINX ) {
        x2 = MINX}
    
    if  ( x2 > MAXX ) {
        x2 = MAXX}
        
    f[0] = x1
    f[1] = x2
    f[2] = z
    f[3] = zstep
    return f
}


public class Panel3d {
    
    //points in 3d space (original points)
    var VPoint: [Point3d] = []
    
    //Clipped Point Array (clipping)
    var ZClipPoint: [Point3d] = []

    //points in 2d space (for display) (rasterize)
    var SPoint: [Point2d] = []
    var SPCount: Int = 0
    
    //initialized properties
    var Radius: Float = 0
    var Normal: Vector = Vector()
    
    var Invis: Float = 0
    var Color: Float = 0
    var Padding: Float = 0
    
    var XMinInVis: Int = 0
    var XMaxInVis: Int = 0
    var YMinInVis: Int = 0
    var YMaxInVis: Int = 0
    var Visible: Int = 1
    var AveX: Float = 0
    var AveY: Float = 0
    
    
    init (Verteces: [Point3d]) {
        self.VPoint = Verteces
        self.CalcRadius()
        self.CalcNormal()
        self.CalcFloaten()
    }
    
    func HasVert(P: Point3d) -> Bool {
        return self.VPoint.contains(P)
    }
    
    func Update(M: Matrix3d) {
        
        M.Transform(Normal)
        
        if (Invis > 0) {
            Invis -= 1
        }
    }
    
}

extension Panel3d {
    
    func CalcRadius() {
        //calculate the radius of the panel
        var TempPoint: [Point3d] = []
        var Center: Point3d = Point3d()
        var Distance: [Float] = []
        var Dist = Float(0)
        
        for Count in VPoint {
            TempPoint.append(Count)
        }
        
        for Count in TempPoint {
            Center += Count
        }
        
        Center /= Float(4.0)
        
        var tPoint: [Point3d] = []
        
        for Count in TempPoint {
            tPoint.append(Count - Center)
        }
        
        for Count in tPoint {
            Dist = Count.Mag()
            Distance.append(Dist)
        }
        
        for d in Distance {Dist = d; break}
        
        for Count in Distance {
            if Count > Dist {
                Dist = Count
            }
        }
        
        Radius = Dist
        
    }
        
    func CalcFloaten() {
        var Mag: Float
        Mag = sqrt(Light.X * Light.X +
            Light.Y * Light.Y +
            Light.Z * Light.Z  )
        
        var CosA: Float
        CosA = ( (Normal.direction[x] - VPoint[0].local[x]) * Light.X +
            (Normal.direction[y] - VPoint[0].local[y]) * Light.Y +
            (Normal.direction[z] - VPoint[0].local[z]) * Light.Z ) / Mag
            
        Color = CosA * Float(COLOR_RANGE) + Float(COLOR_START)
    }
    
    func CalcNormal() {
        var X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3, Distance, A, B, C: Float
        var UniqueVerts: [Point3d] = []
        var Range: Int = 0
        
        for Count in VPoint {
            if (Range == 0) {
                UniqueVerts.append(Count)
                Range+=1
            } else {
                if UniqueVert(V: Count, List: UniqueVerts, Range: Range) {
                    UniqueVerts.append(Count)
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
        Normal.direction[x] = (A/Distance) + self.VPoint[0].local[x]
        Normal.direction[y] = (B/Distance) + self.VPoint[0].local[y]
        Normal.direction[z] = (C/Distance) + self.VPoint[0].local[z]
        
    }
    
    
    
    
}


//********************************************
//**** CLIPPING
//*********************************************

extension Panel3d {
    
    public func ResetCalc2dData() {
        self.XMinInVis = 0 // < MinX -- left bound
        self.XMaxInVis = 0 // > MaxX -- right bound
        self.YMinInVis = 0 // < MinY -- lower bound
        self.YMaxInVis = 0 // > MaxY -- upper bound
        
        self.Visible = 1
        self.AveX = 0
        self.AveY = 0
        
    }
    
    
    //CLIPS AND PROJECTS
    //CLIPS THE 3D POINTS BASED ON MINZ
    
    //creates the values for SPoint array --> 2d projections
    //this will all have to be revised to Metal's 2D coordinate system
    //COMBINED CLIPPING AND PROJECTION FUNCTION
    //CAN I UNCOMBINE?
    func Project() {
        //perform front Z-clippng and project the panel's 3d points onto the screen
        SPCount = VPoint.count-1
        
        //holds the number of screen project points
        var OutCount: Int = 0 // equivalent to ZClipPoint.count?
        var StartI = Int(SPCount - 1)
        
        //loop through all edges of panel using Sutherland-Hodgman algorithm
        for EndI in 0...SPCount {
            
            if (VPoint[StartI].world[z] >= MINZ ) {
                
                //CASE 1 --> WHOLE LINE VISIBLE, APPEND POINT AS IS
                if (VPoint[EndI].world[z] >= MINZ) {
                    ZClipPoint.append(VPoint[EndI])
                    OutCount += 1
                
                //CASE 2 --> EDGE IS LEAVING BOUNDARY, WE JUST NEED THE INTERSECTION POINT WITH MINZ (IN 3D SPACE)
                } else {
                    let newPoint = Point3d()
                    var DeltaZ: Float
                    DeltaZ = (VPoint[EndI].world[z] - VPoint[StartI].world[z])
                    
                    //parametric percentage of line that breaks boundary
                    var t: Float
                    t = (MINZ - VPoint[StartI].world[z])/DeltaZ
                    
                    //CLIP THE X AND Y BY THE PERCENTAGE
                    //see De Goes p. 170
                    newPoint.world[x] = VPoint[StartI].world[x] + (VPoint[EndI].world[x] - VPoint[StartI].world[x]) * t
                    newPoint.world[y] = VPoint[StartI].world[y] + (VPoint[EndI].world[y] - VPoint[StartI].world[y]) * t
                    //BECAUSE WE CROSSED Z BOUNDARY Z = MINZ
                    newPoint.world[z] = MINZ
                    
                    ZClipPoint.append(newPoint)
                        
                    OutCount += 1
                }
                //CASE 3 -->
            }
            //STARTI is OUT OF BOUNDS --> WE NEED TO ADD TWO POINTS OR NO POINTS
            //EITHER ENDI IS ALSO OUT OR IT IS IN
            else {
                    if (VPoint[EndI].world[z] >= MINZ) {
                        let newPoint = Point3d()
                        var DeltaZ: Float
                        
                        //SPoint is entering view volume - clip
                        DeltaZ = (VPoint[EndI].world[z] - VPoint[StartI].world[z])
                        var t: Float
                        t = (MINZ - VPoint[StartI].world[z]) / DeltaZ
                        
                        newPoint.world[x] = VPoint[StartI].world[x] + (VPoint[EndI].world[x] - VPoint[StartI].world[x]) * t
                        newPoint.world[y] = VPoint[StartI].world[y] + (VPoint[EndI].world[y] - VPoint[StartI].world[y]) * t
                        newPoint.world[z] = MINZ
                        
                        //add the new STARTING POINT
                        ZClipPoint.append(newPoint)
                        OutCount += 1
                        
                        //Add the original END POINT (since it's greater than MINZ)
                        ZClipPoint.append(VPoint[EndI])
                        OutCount += 1
                    } else {
                        // entire vertex out of frame, nothing to project
                    }
                }
            //advance to next vertex
            StartI = EndI
        }
        
        //Store the number of vertices in outcount
        SPCount = OutCount
        //print(ZClipPoint)
    }
    
    
    //Load up the Screen Points
    
    func Rasterize() {
        let OutCount = SPCount
        var OneOverZ: Float
        
        //Project panel points
        for Count in 0...OutCount-1 {
            //calculate 1/z for vector normalization
            OneOverZ = Float(1)/ZClipPoint[Count].world[z]
            
            let zclip = OneOverZ * Float(XSCALE) * ZClipPoint[Count].world[z]
            
            var screenPoint = Point2d()
            screenPoint.X = zclip + Float(WIDTH)/2.0
            screenPoint.Y = zclip + Float(HEIGHT)/2.0
            SPoint.append(screenPoint)
            
            //print("Hard coded data Panel3d -> SPoint for 2D Projected Point.")
            
            //NOT SURE WHAT TO DO FOR LOGIC HERE
            SPoint[Count].Z = OneOverZ
            
        }
        print(SPCount)
        //returns nothing,
        //need to reset ZClipCount here
        
        for _ in 0...ZClipPoint.count {
            ZClipPoint.popLast()
        }
        
        
    }
    
    
    
    func CalcVisible3d() -> Float {
        //perform 3d culling
        
        //assume panel is visible
        var Visible: Float = 1
        
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
        ResetCalc2dData()
        
        // make sure the panel has more than two points --> not just a line!
        if (SPCount < 3) {
            //if not, flag panel as invisible
            Visible = 0
            // Assume Panel will remain Invisible for four more frames
            Invis = 4
            return Visible
        }
        
        for p in SPoint {
            if (p.X < MINX) {
                XMinInVis += 1
            }
            else {
                if (p.X > MAXX) {
                    XMaxInVis += 1
                }
            }
            if (p.Y < MINY) {
                YMinInVis += 1
            }
            else {
                if (p.Y > MAXY) {
                    YMaxInVis += 1}
            }
        
            AveX += Float(p.X)
            AveY += Float(p.Y)
        }
        
        //do we have as many invisible x components as points?
        if (XMinInVis >= SPCount) {
            print("XMinInVis")
            //Assume panel will remain invisible for a time proportional to the distance from the edge of viewport
            AveX /= Float(SPCount)
            Invis = Float(abs(AveX)/(Float(WIDTH)*26))
            Visible = 0
        }
        if (YMinInVis >= SPCount) {
            debugMsg("YMinInVis")
            AveY /= Float(SPCount)
            Invis = Float(abs(AveY)*(Float(HEIGHT)*26))
            
            Visible = 0
            }
        if (XMaxInVis >= SPCount) {
            print("XMaxInVis")
            //assume panel will remain invisible for a time
            AveX /= Float(SPCount)
            let num = (AveX-Float(MAXX))
            let den = Float(WIDTH*26)
            Invis = Float( num/den )
            Visible = 0
        }
        if (YMaxInVis >= SPCount) {
            AveY/=Float(SPCount)
            let num = (AveY-Float(MAXY))
            let den = Float(HEIGHT*26)
            Invis = Float(num/den)
            Visible = 0
            print(AveY, SPCount, num, den, Invis)
        }

        return Visible
    }
    
    func CheckExtents() -> Float {
        
        var Visible: Float = 0
        var MinZ: Float
        
        // PROBLEM HERE IS THAT COUNT.WORLD[Z} is ALWAYS ZERO
        
        for Count in VPoint {
            if (Count.world[z] > MINZ) {
                Visible = 1
                Invis = 0
                break
            }
        }
        
        if (Visible == 1) {
            MinZ = VPoint[0].world[z]
            for Count in VPoint {
                if(Count.world[z] < MinZ) {
                    MinZ = Count.world[z]
                }
            }
            if (MinZ > MAXZ)
            {
                // set the invisible flag for this frame
                Visible = 0
                // assume panel will remain invisible for time proportional
                Invis = Float((MinZ-MAXZ)/50)
            }
        }
        else {
            //make invisible
            Invis = Float((abs(CalcCenterZ()))/50)
        }
        
        return Visible
    }

    
    
    func CalcBFace() -> Float {
        //determine if polygon is a backface
        var Visible: Float = 1
        var Invis: Float = 0
        var Direction: Float
        
        var V: Point3d = self.VPoint[0]
        
        Direction = V.world[x] * (Normal.transformed[x] - VPoint[0].world[x]) +
        V.world[y] * (Normal.transformed[y] - VPoint[0].world[y]) +
        V.world[z] * (Normal.transformed[z] - VPoint[0].world[z])
        
        if Direction > Float(0) {
            //get the cosine of the angle between the viewer and the polygon normal
            Direction /= V.Mag()
            //assume panel will remain time proportional to the angle between the viewer to the normal
            Invis = Float(Direction * Float(25))
            Visible = 0
            
        }
        return Visible
    }
    
    func Display() -> simd_float3 {
        // could this entire function be shortcut by Metal? Yes.

           var RColor: Float // color of the panel
           var DPtr: Float // pointer to the off-screen buffer (!)
           var ZPtr: Float // Zbuffer ptr
           
           var LeftSeg: CeilLine = CeilLine()
           var RightSeg: CeilLine = CeilLine() // used for interpolating values along sides
           
           var  Height,  Width, XStart, XEnd, DeltaZ, ZStep, Z: Float
           var YIndex, RightPos, LeftPos, Top, EdgeCount, NewRightPos, NewLeftPos: Int
           Top = 0
           
           RColor = Color
           EdgeCount = SPCount
           
           //Search for lowest Y Coordinate (top of polyon)
           for N in 0...SPCount-1 {
               if (SPoint[N].Y < SPoint[Top].Y) {
                   Top = N
               }
           }
           RightPos = Top
           LeftPos = Top
           
           //Calculate the index to the buffer
           YIndex = Int(SPoint[Top].Y * WIDTH)
           print("Hard coded 320 in Panel3d -> Display")
           
           //loop for all Polygon edges
           while (EdgeCount > 0) {
               //determine if the right side of the polygon needs (re)initializing
               if (RightSeg.Height() <= 0) {
                   NewRightPos = RightPos + 1
                   if (NewRightPos >= SPCount ) {
                       NewRightPos = 0}
                   RightSeg = CeilLine(P1: SPoint[RightPos], P2: SPoint[NewRightPos])
                   RightPos = NewRightPos
                   EdgeCount -= 1
                   //perform object precision clip on top edge
                   //(if necessary)
                   if (RightSeg.GetY() < MINY) {
                       RightSeg.ClipTop(MINY)
                       YIndex = Int(MINY * WIDTH)
                       print("Hard coded value 320 in Panel3d->Display->RightSegGetY Conditional")
                   }
               }
               //determine if the left side of the polygon needs (re)initializing
               if (LeftSeg.Height() <= 0) {
                   NewLeftPos = LeftPos - 1
                   if (NewLeftPos < 0) {
                       NewLeftPos = (SPCount - 1 )
                   }
                   LeftSeg = CeilLine(P1: SPoint[LeftPos], P2: SPoint[NewLeftPos])
                   LeftPos = NewLeftPos
                   EdgeCount -= 1
                   // perform object precision clip if neccessary
                   if (LeftSeg.GetY() < MINY) {
                       LeftSeg.ClipTop(MINY)
                    YIndex = Int(MINY * WIDTH)
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
                       var f: simd_float4
                       f = ClipHLine(X1: XStart, X2: XEnd, Z: Z, ZStep: ZStep)
                       XStart = Float(f[0])
                       XEnd = Float(f[1])
                       Z = Float(f[2])
                       ZStep = Float(f[3])
                       Width = XEnd - XStart
                       
                       //DPtr = Dest[YIndex + XStart]
                       //DPtr is assigned the buffer location
                       //We need to do the opposite -- assign the vertix to the buffer
                       
                       //Pass Along the 2D Point ????
                       
                       let X = Float(Width)
                       let Y = Float(Height)
                       ZPtr = ZBuffer[YIndex + Int(XStart)]
                       
                       
                       vCount += 1
                       print("Panel3d-> Display")
                       
                       
                       //loop for width of scan-LINE_MAX
                       while ( Width > 0 ) {
                           Width -= 1
                           if (ZPtr < Z) {
                               ZPtr = Z
                               //DPtr = (Z >> 18) // bit shift
                           }
                           Z += ZStep
                           //DPtr += 1
                           ZPtr += 1
                       }
                        return (simd_make_float3(X, Y, Float(Z)))
                   }
                   YIndex += 320
                       
               }
               
           }
           
           //if 2d point was not created, return an empty float
           return simd_make_float3(0)
       }
        
    }

        
///OLD DISPLAY FUNCTION
        /*
 
 
 for s in SPoint {
     dataDisplay2d.append(simd_make_float3(Float(s.X), Float(s.Y), Float(s.Z)))
 }
 
 return dataDisplay2d
 
    
    */


        
