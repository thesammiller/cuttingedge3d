//
//  Point2d.swift
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

public struct Point2d: Equatable {
    var X: Int = 0
    var Y: Int = 0
    var Z: Int = 0
    
    public static func == (left: Point2d, right: Point2d) -> Bool {
        return ( ( left.X == right.X) && (left.Y == right.Y) )
    }
    
}


