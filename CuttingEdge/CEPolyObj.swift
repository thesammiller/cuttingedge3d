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
func GetLine(_ InFile: String, _ FileType: String) -> [String] {
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

class PanelObject {
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
    
    func Display(_ M: Matrix3d, _ Buffer: Int )  // a display function
    {
        Transform(M)
        
        for p in PList {
            if p.Invis == 0 {
                if p.CalcVisible3d() == 1 {
                    p.Project()
                    
                    if p.CalcVisible2d() == 1 {
                        p.Display(Dest: Buffer)
                    }
                }
            }
        }
    }
    
    func DXFLoadCoord(_ InFile: [String]) -> Point3d {
        var S: [String] = []
        var Coord = Point3d()
        
        S = GetLine(InFile, "dxf")
        
        for PCount in 0...3 {
            
            if (GetLine(InFile, "dxf") == [String(EOF)] ) {
                //return default coord
                break
            }
            switch(S[0]) {
            case "10":
                Coord.local[x] = Float(S[1])
                PCount += 1
            case "11":
                Coord.local[x] = Float(S[1])
                PCount += 1
            case "12":
                Coord.local[x] = Float(S[1])
                PCount += 1
            case "13":
                Coord.local[x] = Float(S[1])
                PCount += 1
            case "20":
                Coord.local[y] = Float(S[1])
                PCount += 1
            case "21":
                Coord.local[y] = Float(S[1])
                PCount += 1
            case "22":
                Coord.local[y] = Float(S[1])
                PCount += 1
            case "23":
                Coord.local[y] = Float(S[1])
                PCount += 1
            case "30":
                Coord.local[z] = Float(S[1])
                PCount += 1
            case "31":
                Coord.local[z] = Float(S[1])
                PCount += 1
            case "32":
                Coord.local[z] = Float(S[1])
                PCount += 1
            case "33":
                Coord.local[z] = Float(S[1])
                PCount += 1
            default:
                print("Hit default in Switch statement on CEPolyObj DXFLoadCoord.")
                break
            }
            
        }
        
        return Coord
    }
    
    func DXFCountPanels(_ FileName: String) -> Int {
        var PanelCount: Int = 0
        let S = GetLine(FileName, "dxf")
        
        for s in S {
            if s == "3DFace" {
                PanelCount += 1
            }
        }
        return PanelCount
    }
    
    func DXFLoadVerts(_ FileName: String) -> Int {
        //load all vertices from a DXF text file
        
        //Might not need to count panels since Swift allocates memory differently
        //var PCount = DXFCountPanels(FileName)
        TList = []
        var VIndex = 0
        var S = GetLine(FileName, "dxf")
        
        for s in S {
            if (s == String(EOF)) {
                break
            }
            if ("3DFACE" == s) {
                for _ in 0...4 {
                    var TPoint3d = DXFLoadCoord(S)
                    S.remove(at: 0)
                    S.remove(at: 1)
                    TList[VIndex] = TPoint3d
                    VIndex += 1
                }
            }
        }
        VCount = 0
        
        var VList: [Point3d] = []
        
        for c in 0...VIndex {
            if (UniqueVert(V: TList[c], List: VList, Range: VCount)) {
                VList[VCount] = TList[c]
                
                VCount += 1
            }
        
        }
        return 1
    }
    
    func DXFLoadPanelData() -> Int {
        //read the panel data from a dxf file
        //assumes vertices loaded through LoadVerts
        
        PList = []
        var VIndex = 0
        
        for PIndex in 0...PCount {
            DXFLoadPanel(VIndex: VIndex, Index: PIndex)
        }
        
        return 1
    }
    
    
    // MAGIC --> LOADING THE PANELS
    func DXFLoadPanel(VIndex: Int, Index: Int) -> Int {
        //load a panel from a DXF text file
        //VIndex is a let so we set up a var
        var vi = VIndex
        
        for c in 0...4 {
            PList[Index].VPoint[c] =
                VList[GetVertexIndex(V: TList[vi], List: VList, Range: VCount)]
            vi += 1
        }
        // PList[Index].InitPosition --> we can init the class through init() function
        PList[Index].CalcInten()
        
        return 1
    }
    
    func LoadDXF(_ FileName: String) {
        DXFLoadVerts(FileName)
        DXFLoadPanelData()
    }
    
    
    // loading object from binary... we'll do it when we have to
    func ReadBIN(_ FileName: String) {}
    func WriteBIN(_ FileName: String) {}
    
    
    
    
    
    
}
