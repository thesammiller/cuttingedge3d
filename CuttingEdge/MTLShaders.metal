//
//  Shaders.metal
//  CuttingEdge
//
//  Created by brogrammer on 6/21/20.
//  Copyright © 2020 brogrammer. All rights reserved.
//

 /*#include <metal_stdlib>
 using namespace metal;



 vertex float4 vertex_main(const device packed_float3 *vertices [[ buffer(0)]],
                             uint vertexId [[ vertex_id ]] ) {
     
     return float4(vertices[vertexId], 1);
 }

 fragment half4 fragment_main() {
     return half4(1, 1, 1, 1);
 }
*/


#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

struct VertexOut {
    vector_float4 position [[position]];
    vector_float4 color;
};


vertex VertexOut vertexShader(const constant vector_float3 *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]){
    vector_float3 currentVertex = vertexArray[vid]; //fetch the current vertex we're on using the vid to index into our buffer data which holds all of our vertex points that we passed in
    VertexOut output;
    
    output.position = vector_float4(vertexArray[vid], 1); //populate the output position with the x and y values of our input vertex data
    output.color = vector_float4(1,1,1,1); //set the color
    
    return output;
}

fragment vector_float4 fragmentShader(VertexOut interpolated [[stage_in]]){
    return interpolated.color;
}
