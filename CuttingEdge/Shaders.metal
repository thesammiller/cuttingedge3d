//
//  Shaders.metal
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

 
 #include <metal_stdlib>
 using namespace metal;

 struct VertexIn {
     float4 position [[ attribute(0) ]];
 };

 vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
     return vertex_in.position;
 }

 fragment float4 fragment_main() {
     return float4(0, 0.4, 0.21, 1);
 }
 
