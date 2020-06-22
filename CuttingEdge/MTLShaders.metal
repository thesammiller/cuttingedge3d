//
//  Shaders.metal
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

 #include <metal_stdlib>
 using namespace metal;


 vertex float4 vertex_main(const device packed_float3 *vertices [[ buffer(0)]],
                             uint vertexId [[ vertex_id ]] ) {
     
     return float4(vertices[vertexId], 1);
 }

 fragment half4 fragment_main() {
     return half4(1, 1, 1, 1);
 }
