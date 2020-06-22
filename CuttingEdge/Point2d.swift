//
//  Point2d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

struct Point2d: Equatable {
    var X: Float = 0
    var Y: Float = 0
    var Z: Float = 0
    
    static func == (left: Point2d, right: Point2d) -> Bool {
        return ( ( left.X == right.X) && (left.Y == right.Y) )
    }
    
}


