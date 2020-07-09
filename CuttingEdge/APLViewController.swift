//
//  ViewController.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

import MetalKit

public var MouseX = CGFloat(0.0)
public var MouseY = CGFloat(0.0)
public var MouseClick = false


class ViewController: NSViewController {
    
    //Metal properties
    var device: MTLDevice!
    var mtkView: MTKView!
    
    //Renderer file class
    public var renderer: Renderer!
    
    //mouse properties
    var trackingArea: NSTrackingArea?
    var cursor: NSCursor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        
        
        //this frame thing is an issue... a bad hack for now.
        mtkView = MTKView(frame: NSMakeRect(0, 0, CGFloat(WIDTH*2), CGFloat(HEIGHT*2)))
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mtkView)
        /*
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
        */
        mtkView.device = device
        
        mtkView.colorPixelFormat = .bgra8Unorm
        
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
        renderer = Renderer(metalView: mtkView, device: device)
        mtkView.delegate = renderer
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
        MouseClick = true
        
        debugMsg("click")
    }
    
    override func mouseUp(with event: NSEvent) {
        MouseClick = false
    }
    
}

