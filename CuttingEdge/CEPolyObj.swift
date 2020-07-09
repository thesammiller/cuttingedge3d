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
    var PCount: Float = 0
    var VCount: Float = 0
    var Visible: Float = 0
    var Radius: Float = 0
    
    
    init () {
        //calculate data for the new panel
        
        
    }
    
    func CalcRadius() -> Float {
        print("CEPolyObj->CalcRadius not implemented in book.")
        return 0
    }
    
    func Transform(_ M: Matrix3d) {
        //translates/rotates entire vertex list
        var TList: [Point3d] = []
        
        for v in VList {
            TList.append(M.Transform(v))
        }
        
        VList = TList
        
        for p in PList {
            p.Update(M: M)
        }
    }
    
    func Display(_ M: Matrix3d)  -> [simd_float3]// a display function
    {
        self.Transform(M)
        
        var data: [simd_float3] = []
        
        //generate a VECTOR LIST so we can (in other functions) go through all the vectors in this poly object
        for p in PList {
            for v in p.VPoint {
                VList.append(v)
            }
        }
        
        //for each panel in the List
        for p in PList {
            
            // if the object is not already invisible
            if p.Invis == 0 {
                
                //check whether it is visible in 3d space
                if p.CalcVisible3d() == 1 {
                    //Clip
                    p.Project()
                    //Rasterize to screen coordinates
                    p.Rasterize()
                    
                    //check if the Screen Points are Visible
                    if p.CalcVisible2d() == 1 {
                        data.append(p.Display())
                        print(data)
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
        var newVerts: [Point3d]
        
        //Split Faces into array of string arrays (each string array is a 3d Face (4 points) )
        let SplitFaces = DXFSplitFaces(Lines)
        
        // for each face
        for s in SplitFaces {
        
            //split the face into an array of string arrays
            if s.count > 1 {
                newVerts = DXFLoadPoints(s) }
            else { continue }
            
            //add the new vertices to a new panel
            let newPanel = Panel3d(Verteces: newVerts)
            //add each panel to the list
            panelList.append(newPanel)
        
        }
        
        return panelList
    }
    
    //Pass in the lines between one 3DFACE and ANOTHER
    func DXFLoadPoints(_ Lines: [String]) -> [Point3d] {
        var Points: [Point3d] = []
        
        for _ in 0...3 {
            Points.append(Point3d())
        }
        
        // some magic for the DXF files parsing
        // DO NOT TOUCH
        let XOffset = 7
        let YOffset = 11
        let ZOffset = 15
        let DXFStride = 12
        
        for c in 0...3 {
            let XValue = c*DXFStride+XOffset
            let YValue = c*DXFStride+YOffset
            let ZValue = c*DXFStride+ZOffset
            
            
            //convert the line at index to a float value
            // these are points in 3d space
            
            if Float(Lines[XValue]) != nil {
                Points[c].local[x] = Float(Lines[XValue])!
            } else {Points[c].local[x] = 0.0}
            
            if Float(Lines[YValue]) != nil {
                Points[c].local[y]   = Float(Lines[YValue])!
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
    
