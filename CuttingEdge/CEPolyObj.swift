//
//  PolyObj.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/22/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//
import Foundation
import MetalKit


// TODO: Returns a list, but the other side expects a string... Need to middle manage.
// reads a line of text from a text file
func GetFile(_ InFile: String, _ FileType: String) -> [String] {
    if let path = Bundle.main.path(forResource: InFile, ofType: FileType) {
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            var myStrings = data.components(separatedBy: .newlines)
            // join...
            return myStrings
        } catch {
            print(error)
        }
    }
    print("No data from GetLine in PolyObj.")
    return [String(EOF)]
}

public class PanelObject {
    var TList: [Point3d] = []
    var VList: [Point3d] = []
    var PList: [Panel3d] = []
    var PCount: Int = 0
    var VCount: Int = 0
    var Visible: Int = 0
    var Radius: Float = 0
    
    
    init () {
        
    }
    
    func CalcRadius() -> Float {
        print("CEPolyObj->CalcRadius not implemented in book.")
        return 0
    }
    
    func Transform(_ M: Matrix3d) {
        //translates/rotates entire vertex list
        var TList: [Point3d] = []
        
        for v in VList {
            print(v)
            var w = M.Transform(v)
            print(w)
            TList.append(w)
            
        }
        VList = TList
        print(VList)
        for p in PList {
            p.Update(M: M)
        }
    }
    
    func Display(_ M: Matrix3d)  -> [simd_float3]// a display function
    {
        self.Transform(M)
        
        var data: [simd_float3] = []
        
        for p in PList {
            for v in p.VPoint {
                VList.append(v)
            }
        }
        
        
        for p in PList {
            if p.Invis == 0 {
                //is panel object visible?
                if p.CalcVisible3d() == 1 {
                    print("CalcVisible")
                    p.Project()
                    print("Project")
                    
                    if p.CalcVisible2d() == 1 {
                        data.append(p.Display())
                        print("Poly displayed")
                    }
                }
            }
        }
        return data
    }
}


// LOADING DXF FILES...
extension PanelObject {
    
    func DXFLoadModel(_ FileName: String) -> PanelObject {
        var po = PanelObject()
        
        //Load the DXF File into a String Array
        let DXFLines = DXFLoadFile(FileName)
        
        //load list of panels
        po.PList = DXFLoadFaces(DXFLines)
        
        return po
    }
    
    func DXFLoadFile (_ FileName: String) -> [String] {
        return GetFile(FileName, "DXF")
    }
    
    func DXFLoadFaces(_ Lines: [String]) -> [Panel3d] {
        var panelList: [Panel3d] = []
        var tempPoints: [Point3d]
        let tempPanel = Panel3d()
        
        //Split Faces into array of string arrays (each string array is a 3d Face (4 points) )
        let SplitFaces = DXFSplitFaces(Lines)
        
        // for each face
        for s in SplitFaces {
            
            
            //split the face into an array of string arrays
            if s.count > 1 {
                tempPoints = DXFLoadPoints(s) }
            else { tempPoints = [] }
            if tempPoints.isEmpty {continue}
            
            //print(tempPoints)
            tempPanel.VPoint = tempPoints
            
            //calculate data for the new panel
            tempPanel.CalcRadius()
            tempPanel.CalcNormal()
            tempPanel.CalcInten()
            
            panelList.append(tempPanel)
        
        }
        return panelList
    }
    
    //Pass in the lines between one 3DFACE and ANOTHER
    func DXFLoadPoints(_ Lines: [String]) -> [Point3d] {
        var Points: [Point3d] = []
        
        for _ in 0...3 {
            Points.append(Point3d())
        }
        
        //print(Lines.count)
        
        // some magic for the DXF files
        let XOffset = 7
        let YOffset = 11
        let ZOffset = 15
        let DXFStride = 12
        
        for c in 0...3 {
            let XValue = c*DXFStride+XOffset
            let YValue = c*DXFStride+YOffset
            let ZValue = c*DXFStride+ZOffset
            
            if Float(Lines[XValue]) != nil {
                Points[c].local[x] = Float(Lines[XValue])!
            } else {Points[c].local[x] = 0.0}
            if Float(Lines[YValue]) != nil {
                Points[c].local[y] = Float(Lines[YValue])!
            } else {Points[c].local[y] = 0.0}
            if Float(Lines[ZValue]) != nil {
                Points[c].local[z] = Float(Lines[ZValue])!
            } else {Points[c].local[z] = 0.0}
            
            Points[c].world = simd_make_float4(1)
        
        }
        //return the points of the panel!
        return Points
    
    }
    
    func DXFSplitFaces(_ Lines: [String]) -> [[String]] {
        var tempFaces: [[String]] = []
        var tFace: [String] = []
        var tempLine = ""
        var lineCount = 0
        var tl = ""
        
        for l in Lines {
            
            //stop when we have gone far enough
            tempLine = l
            
            // break at end of file
            if tempLine == "EOF" {
                //print("End of file!")
                break
            }
            // if we encounter a 3dface
            if tempLine == "3DFACE" {
                //print("Found a face...")
                
                // can discard the first 6 items
                if lineCount+56 < Lines.count {
                    for c in 0...56 {
                        tl = Lines[lineCount+c+1]
                        //if we are at the end of the face, break
                        if tl == "3DFACE" {break}
                        //var splitLine = tl.split(separator: " ")
                        //otherwise, add this string to our tempface
                        tFace.append(Lines[lineCount+c+1])
                    } // inner for
                } // if
                
                tempFaces.append(tFace)
            }
                
            tFace = []
            lineCount += 1
        }
        //print(tempFaces)
        return tempFaces
    }//for loop end
        

        
}
    
