//
//  Panel3d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

public class Panel3d {
    
    //points in 3d space (original points)
    var VPoint: [Point3d] = []
    
    //Clipped Point Array (clipping)
    var ZClipPoint: [Point3d] = []

    //points in 2d space (for display) (rasterize)
    var SPoint: [Point2d] = []
    //var SPCount: Int = 0 --> replaced by Swift/s SPoint.count
    
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
        
        Dist = Distance[0]
        
        for Count in Distance {
            if Count > Dist {
                Dist = Count
            }
        }
        
        self.Radius = Dist
        
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


//*********************************************************************
//**** DISPLAY --> CLIP/PROJECT (Functions called in Poly.Display() ***
//*********************************************************************

extension Panel3d {
    
    func CalcVisible3d() -> Float {
        //perform 3d culling
        //assume panel is visible
        var Visible: Float = 1
        
        //CalcBFace and CheckExtents in next class extension
        Visible = CalcBFace()
        
        //If Panel still visible perform extent test
        //is there a better way to bool an int in swift? WTF is this language.
        if (Visible == 1) {
            Visible = CheckExtents()
        }
        return Visible
    }
    
    //TODO: Fix this
    //----------------------------------------------------------------
    //CLIPS THE 3D POINTS BASED ON MINZ
    //creates the values for SPoint array --> 2d projections
    //this will all have to be revised to Metal's 2D coordinate system
    //COMBINED CLIPPING AND PROJECTION FUNCTION
    //CAN I UNCOMBINE?
    func ProjectClips() {
        //perform front Z-clippng and project the panel's 3d points onto the screen
      /*
        
        //reset the ZClipBuffer
        ZClipPoint = []
        var StartI = VPoint.count-2
        
        //loop through all edges of panel using Sutherland-Hodgman algorithm
        for EndI in 0...VPoint.count-1 {
            
            if (VPoint[StartI].world[z] >= MINZ ) {
                
                //CASE 1 --> WHOLE LINE VISIBLE, APPEND POINT AS IS
                if (VPoint[EndI].world[z] >= MINZ) {
                    ZClipPoint.append(VPoint[EndI])
                
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
                }
            }
            
            //STARTI is OUT OF BOUNDS --> WE NEED TO ADD TWO POINTS OR NO POINTS
            //EITHER ENDI IS ALSO OUT OR IT IS IN
            else {
                    //CASE 3 --> Add an original point and a clipped point
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
                        
                        //Add the original END POINT (since it's greater than MINZ)
                        ZClipPoint.append(VPoint[EndI])
                    } else {
                        // entire vertex out of frame, nothing to project
                    }
                }
            //advance to next vertex
            StartI = EndI
        }*/
       ZClipPoint = VPoint
        
    }
    
    //SCREEN PROJECTION
    //Load up the Screen Points parameter SPoints
    /*func DisplayPoints() {
        //reset our screen points
        SPoint = []
        
        
        for zc in ZClipPoint {
            //calculate 1/z for vector normalization
            let OneOverZ = Float(1)/zc.world[z]
            var screenPoint = Point2d()
            
            let screenX = zc.world[x] * XSCALE * OneOverZ
            let screenY = zc.world[y] * YSCALE * OneOverZ
            
            screenPoint.X = screenX + Float(WIDTH)/2
            screenPoint.Y = screenY + Float(HEIGHT)/2
            screenPoint.Z = OneOverZ
            
            SPoint.append(screenPoint)
        }*/
  
      func DisplayPoints() {
          SPoint = []
          let m = Matrix3d.perspectiveProjection(70, fieldOfViewY: 10, near: 10, far: 100)
        
          for z in ZClipPoint {
            var p2d = Point2d()
            let t = z.local * m.Matrix
            p2d.X = t.x
            p2d.Y = t.y
            p2d.Z = t.z
            SPoint.append(p2d)
        }
        
      }
    

    public func ResetCalc2dData() {
        self.XMinInVis = 0 // < MinX -- left bound
        self.XMaxInVis = 0 // > MaxX -- right bound
        self.YMinInVis = 0 // < MinY -- lower bound
        self.YMaxInVis = 0 // > MaxY -- upper bound
        
        self.Visible = 1
        self.AveX = 0
        self.AveY = 0
        
    }
    
    func CalcVisible2d() -> Int {
        // perform 2d culling
        /*
        ResetCalc2dData()
        
        // make sure the panel has more than two points --> not just a line!
        if (SPoint.count < 3) {
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
            if (p.X > MAXX) {
                XMaxInVis += 1
            }
            if (p.Y < MINY) {
                YMinInVis += 1
            }
            if (p.Y > MAXY) {
                YMaxInVis += 1
            }
            
            AveX += Float(p.X)
            AveY += Float(p.Y)
        }
        
        //do we have as many invisible x components as points?
        if (XMinInVis >= SPoint.count) {
            //debugMsg("XMinInVis")
            //Assume panel will remain invisible for a time proportional to the distance from the edge of viewport
            AveX /= Float(SPoint.count)
            Invis = Float(abs(AveX)/(Float(WIDTH)*26))
            Visible = 0
        }
        if (YMinInVis >= SPoint.count) {
            //debugMsg("YMinInVis")
            AveY /= Float(SPoint.count)
            Invis = Float(abs(AveY)*(Float(HEIGHT)*26))
            Visible = 0
            }
        if (XMaxInVis >= SPoint.count) {
            //print("XMaxInVis")
            //assume panel will remain invisible for a time
            AveX /= Float(SPoint.count)
            let num = (AveX-Float(MAXX))
            let den = Float(WIDTH*26)
            Invis = Float( num/den )
            Visible = 0
        }
        if (YMaxInVis >= SPoint.count) {
            //print("Ymaxinvis \(YMaxInVis)")
            AveY/=Float(SPoint.count)
            let num = (AveY-Float(MAXY))
            let den = Float(HEIGHT*26)
            Invis = Float(num/den)
            Visible = 0
        }*/
        var Visible = 1
        return Visible
    }
    
    func Display() -> [simd_float2:Float] {
        /*
        // color of the panel
        var RColor: Float
        
        
        //Used for interpolating values along left/right of polygon
        var LeftSeg = CeilLine()
        var RightSeg = CeilLine() // used for interpolating values along sides
        
        //Point in SPoint -> Point Closest to the Top of Screen
        var Top: Point2d
        //Point in SPoint --> Top Right Edge, Top Left Edge
        var RightPos, LeftPos: Point2d
        //Index for Point in Spoint --> bottom of right edge bottom of left edge
        var NewRightPos, NewLeftPos: Point2d
        
        //Trapezoid Height
        var  Height: Float
        //Number of edges we've left to rasterize
        var EdgeCount: Int
        
        //Left side of the current row
        var XStart: Float
        //Right side of the current row
        var XEnd: Float
        //Used with 1/Z for increment of interpolation
        var DeltaZ: Float
        //actual 1/z step used in interpolation process
        var ZStep: Float
        // 1/z value at the current pixel
        //(will be somewhere between 1 at the front and .0000000001 at the back
        //(compare to metal space..., 0 in front, 1 in back?)
        var Z: Float
        
        //unexplained for now...
        var  Width: Float
        
        //Initialize Top to starting value
        Top = SPoint[0]
        //Set Color to the panel's color
        RColor = Color
        //clear the ZBuffer --> will revisit this if it proves to be a bottleneck
        ZBuffer = [:]
        var XBuffer: [Float] = []
        var YBuffer: [Float] = []
        //set edgecount to the number of vertices in the clipped/projected 3d panel
        EdgeCount = SPoint.count
           
        //STEP 1: FIND THE INDEX FOR THE TOP VERTEX OF THE PANEL
        for p in SPoint {
            if (p.Y < Top.Y) {
                Top = p
            }
        }
        
        RightPos = Top
        LeftPos = Top
           
        //STEP 2: CALCULATE INTERPOLANTS FOR THE LEFT AND RIGHT PANEL EDGES (RightSeg, LeftSeg)
        while (EdgeCount > 0) {
            
            //determine if the right side of the polygon needs interpolation
            if (RightSeg.Height() <= 0) {
                var nrpIndex = SPoint.firstIndex(of: Top)! + 1
                //adding one might exceed the index so if so, reset
                if (nrpIndex > SPoint.count-1) {nrpIndex = 0}
                NewRightPos = SPoint[nrpIndex]
            
                //reinitialize right segment
                RightSeg = CeilLine(P1: RightPos, P2: NewRightPos)
                RightPos = NewRightPos
                EdgeCount -= 1
                //perform object precision clip on top edge
                //(if necessary)
                if (RightSeg.GetY() < MINY) {
                    RightSeg.ClipTop(MINY)
                }
            } //return to the while loop...
            
            //determine if the left side of the polygon needs initialization
            if (LeftSeg.Height() <= 0) {
                var nlpIndex = SPoint.firstIndex(of: Top)! - 1
                if (nlpIndex < 0) {nlpIndex = SPoint.count-1}
                NewLeftPos = SPoint[nlpIndex]
            
                //initialize left segment
                LeftSeg = CeilLine(P1: LeftPos, P2: NewLeftPos)
                LeftPos = NewLeftPos
                EdgeCount -= 1
                // perform object precision clip if neccessary
                if (LeftSeg.GetY() < MINY) {
                    LeftSeg.ClipTop(MINY)
                   }
            }
               
            //subdivide polygon into trapezoid
            //first -- determine the shortest segment and store the value into height
            //(include clipping for maxy)
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
                    XStart = f[0]
                    XEnd = f[1]
                    Z = f[2]
                    ZStep = f[3]
                    Width = XEnd - XStart
                    
                    let Y = Float(Height)
                    for x in 0...Int(Width) {
                        let X = Float(x)
                        if YBuffer.contains(Y) {
                            if XBuffer.contains(X) {
                                if ZBuffer.keys.contains(simd_float2(X, Y)) {
                                    if ZBuffer[simd_float2(X, Y)]! < Z {
                                        ZBuffer[simd_float2(X, Y)] = Z
                                    }
                                    else {
                                        continue
                                    }
                                }
                            }
                        }
                        
                        XBuffer.append(X)
                        YBuffer.append(Y)
                        ZBuffer[simd_float2(X, Y)] = Z
                    }
                    
                }
                LeftSeg += 1
                RightSeg += 1
               }
           } // exited main while loop
           
        
        */
        
      var factor = Float(3.0)
      for sp in SPoint {
        var key = simd_float2(sp.X / factor, sp.Y / factor)
        var value = sp.Z / factor
        ZBuffer[key] = value
      }
      return ZBuffer
      }
      

    }
        


//HELPER FUNCTIONS FOR METHOD CALVISIBLE3D
extension Panel3d {

    func CheckExtents() -> Float {
      let Visible = Float(1.0)
      /*
        
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
        }*/
        
        return Visible
    }


    func CalcBFace() -> Float {
        //determine if polygon is a backface
      
      /*
        var Visible: Float = 1
        var Invis: Float = 0
        var Direction: Float
        
        var V: Point3d = self.VPoint[0]
        
      
        //-----------------------------------------------------------------------
        
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
        return Visible*/
        return 1
    }
    
    func CalcCenterZ() -> Float {
        var CenterZ: Float
      
        var sum = Float(0)
      
        for v in VPoint {
          sum = sum + v.world[z]
        }
                
        CenterZ = sum / Float(VPoint.count)
        
        return CenterZ
        
    }
}


// CLIP A HORIZONTAL Z-BUFFERED LINE
public func ClipHLine (X1: Float, X2: Float, Z: Float, ZStep: Float ) -> simd_float4 {
    var  f = simd_make_float4(0)
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
