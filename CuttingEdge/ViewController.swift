//
//  ViewController.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

class ViewController: NSViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("metal view not set up in storyboard.")
        }
        
        var renderer: Renderer?
        
        
        renderer = Renderer(metalView: metalView)
        
        
        var p: Point3d
        var q: Point3d
        var pl: simd_float4
        var ql: simd_float4
        pl = simd_make_float4(2, 1, 1, 1)
        ql = simd_make_float4(1, 1, 1, 1)
        p = Point3d(pl)
        q = Point3d(ql)
        
        print(p.DotUnit(q))

        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

