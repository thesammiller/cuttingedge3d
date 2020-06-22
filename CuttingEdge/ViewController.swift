//
//  ViewController.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

class ViewController: NSViewController {
    var metalView : MTKView {
           return view as! MTKView
       }
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        renderer = Renderer(metalView: metalView)

        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

