//
//  ViewController.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

class ViewController: NSViewController {
    
    var metalView: MTKView {
        return view as! MTKView}
    
    var renderer: Renderer?
    
    var trackingArea: NSTrackingArea?
    public var MouseX = CGFloat(0.0)
    public var MouseY = CGFloat(0.0)
    var cursor: NSCursor?
    public var click = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mouse Functionality
        
        let trackingOptions: NSTrackingArea.Options = [
                   .activeAlways,
                   .mouseEnteredAndExited,
                   .mouseMoved,
                   .inVisibleRect
               ]
        let trackingArea = NSTrackingArea(rect: NSZeroRect, options: trackingOptions, owner: self, userInfo: nil)
        self.view.addTrackingArea(trackingArea)
        
        
        // METAL LOOP -- ANY CODE AFTER THIS SHALL NOT PASS
        renderer = Renderer(metalView: metalView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MOUSE FUNCTIONS

extension ViewController {
    
    override func awakeFromNib() {
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.hide()
        debugMsg("Mouse entered.")
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.unhide()
        debugMsg("Mouse exited.")
    }
    
    override func mouseMoved(with event: NSEvent) {
        let location = event.locationInWindow
        
        MouseX = location.x
        MouseY = location.y
        
        if DEBUGMOUSE {
            print(location)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        click = true
        
        debugMsg("click")
    }
    
    override func mouseUp(with event: NSEvent) {
        click = false
    }
    
}

