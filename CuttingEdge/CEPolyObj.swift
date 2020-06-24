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
            let myStrings = data.components(separatedBy: .newlines)
            //TextView.text = myStrings.joined(separator: ", ")
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
        for v in VList {
            M.Transform(v)
        }
        for p in PList {
            p.Update(M: M)
        }
    }
    
    func Display(_ M: Matrix3d)  -> [simd_float3]// a display function
    {
        Transform(M)
        var data: [simd_float3] = []
        
        for p in PList {
            if p.Invis == 0 {
                if p.CalcVisible3d() == 1 {
                    p.Project()
                    
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
        var DXFLines = DXFLoadFile(FileName)
        
        //load list of panels
        po.PList = DXFLoadFaces(DXFLines)
        
        print(po.PList)
        
        return po
    }
    
    func DXFLoadFile (_ FileName: String) -> [String] {
        return GetFile(FileName, "DXF")
    }
    
    func DXFLoadFaces(_ Lines: [String]) -> [Panel3d] {
        var panelList: [Panel3d] = []
        var tempPoints: [Point3d]
        var tempPanel = Panel3d()
        
        //Split Faces into array of string arrays (each string array is a 3d Face (4 points) )
        var SplitFaces = DXFSplitFace(Lines)
        
        // for each face
        for s in SplitFaces {
            
            //split the face into an array of string arrays
            tempPoints = DXFLoadPoints(s)
            if tempPoints.isEmpty {continue}
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
        
        for _ in 0...4 {
            Points.append(Point3d())
        }
        
        var lineCount = 0
        var lS = ""
        var intS: Int = 0
        
        for l in Lines {
            if l.starts(with: " ") {
                var lineSplit = l.split(separator: " ")
                lS = String(lineSplit[0])
            }
            else {lS = l}
            print(lS)
            print("****************************************")
            
            intS = Int(lS)
            while (PCount < 12) {
            
                switch(intS) {
                    case 10:
                        Points[0].local[x] = Float(Lines[lineCount+1])!
                        PCount += 1
                        print("x")
                    case 11:
                        Points[1].local[x] = Float(Lines[lineCount+1])!
                        PCount += 1
                        print("y")
                    case 12:
                        Points[2].local[x] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case 13:
                        Points[3].local[x] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "20":
                        Points[0].local[y] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "21":
                        Points[1].local[y] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "22":
                        Points[2].local[y] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "23":
                        Points[3].local[y] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "30":
                        Points[0].local[z] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "31":
                        Points[1].local[z] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "32":
                        Points[2].local[z] = Float(Lines[lineCount+1])!
                        PCount += 1
                    case "33":
                        Points[3].local[z] = Float(Lines[lineCount+1])!
                        PCount += 1
                    default:
                        print("Default... CEPolyObj DXFLoadCoord.")
                        PCount = 12
                        break
                } // close switch
            
            } //close while
            lineCount += 1
        } // close for
        for p in Points {
            print(p.local)
        }
        //return the points of the panel!
        return Points
    
    }
    
    
    
    func DXFSplitFace (_ Lines: [String]) -> [[String]] {
        var tempFaces: [[String]] = []
        var tFace: [String] = []
        var tempLine = ""
        var lineCount = 0
        var tl = ""
        
        for l in Lines {
            
            tempLine = l.trimmingCharacters(in: .whitespaces)
            //if tempLine == "" {continue}
            
            // break at end of file
            if tempLine == "EOF" {
                print("End of file!")
                break
            }
            // if we encounter a 3dface
            if tempLine == "3DFACE" {
                //print("Found a face...")
                
                // can discard the first 6 items
                for c in 0...30 {
                    tl = Lines[lineCount+c+1]
                    
                    //if we are at the end of the face, break
                    if tl == "3DFACE" {break}
                    
                    //otherwise, add this string to our tempface
                    tFace.append(Lines[lineCount+c])
                }
                
                tempFaces.append(tFace)
                tFace = []
            }
            lineCount += 1
        }//for loop end
        
        // this is our array of string arrays [each inner array is a 3dface]
        return tempFaces
    }
    
    
/*

     var clean = S[0]
     clean.trimmingCharacters(in: .whitespaces)
     
     if clean == "EOF" {
         return Point3d()
     }
     
    
    func DXFCountPanels(_ FileName: String) -> Int {
        var PanelCount: Int = 0
        let S = GetFile(FileName, "DXF")
        
        for s in S {
            if s == "3DFace" {
                PanelCount += 1
            }
        }
        return PanelCount
    }
    
    func DXFLoadVerts(_ FileName: String) -> [Point3d] {
        //load all vertices from a DXF text file
        
        //Might not need to count panels since Swift allocates memory differently
        //var PCount = DXFCountPanels(FileName)
        
        var VIndex = 0
        var S = GetFile(FileName, "DXF")
        var copyS = S
        
        for s in S {
            
            if (s == String(EOF)) {
                break
            }
            
            // FIND A FACE, OR PANEL, IN THE DXF FILE
            if ("3DFACE" == s) {
                
                // Clear the Temp List of Coordinates
                TList = []
                
                // Polygon has a maximum of four vertexes
                for _ in 0...4 {
                    
                    // Create a Temporary Point
                    var TPoint3d = DXFLoadCoord(S)
                    
                    //Remove the first two lines, which were just read in from the file
                    //S.remove(at: 0)
                    //S.remove(at: 1)
                    
                    TList.append(TPoint3d) // temp list to turn into panel
                    VList.append(TPoint3d) // master list
                }
                
                var UList: [Point3d] = []
                for c in TList {
                    if (UniqueVert(V: c, List: VList, Range: VCount)) {
                        VList[VCount] = c
                        UList.append(c)
                        VCount += 1
                    }
                
                }
                var Face = DXFLoadPanel(Face)
                PList.append(Face)
        
            }
            
        }
    }
    
    // MAGIC --> LOADING THE PANELS
    func DXFLoadPanel(VertList: [Point3d]) -> Panel3d {
        //load a panel from a DXF text file
        
        var TempPanel = Panel3d()
        
        //var vertexIndex = GetVertexIndex(V: TList[vi], List: VList, Range: VCount)
        
        for v in VertList {
            TempPanel.VPoint.append(v)
        // PList[Index].InitPosition --> we can init the class through init() function
        }
        TempPanel.CalcRadius()
        TempPanel.CalcNormal()
        TempPanel.CalcInten()
        
        print("Verts -> \(VertList.count).")
            
        return TempPanel
    }
    
    func LoadDXF(_ FileName: String) {
        DXFLoadVerts(FileName)
        print("Master Vertex -> \(VList.count)")
        
        
        PList.append(DXFLoadPanel(VertList: TList))
    }
    
 
 */
}
