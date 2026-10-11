#version 460 core

#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

// Uniforms
uniform vec2 uSize;
uniform float uDistortionStrength;
uniform float uHighlightIntensity;
uniform vec4 uTintColor; // R, G, B, A (not pre-multiplied passed from Dart)

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // iOS glass depth: Stronger diffuse highlight at the top-left to simulate light direction
    float diagonal = clamp(1.0 - (uv.x + uv.y) * 0.5, 0.0, 1.0);
    float specular = smoothstep(0.4, 1.0, diagonal);
    
    // Simulate glass thickness / edge volume
    float edgeDistX = min(uv.x, 1.0 - uv.x);
    float edgeDistY = min(uv.y, 1.0 - uv.y);
    float minEdgeDist = min(edgeDistX, edgeDistY);
    
    // Soft inner rim (glows more on the lighter side)
    float rim = smoothstep(0.08, 0.0, minEdgeDist);
    float directionalRim = rim * (diagonal * 0.8 + 0.2);
    
    float totalHighlight = (directionalRim * 0.6 + specular * 0.5) * uHighlightIntensity;
    
    vec3 baseColor = uTintColor.rgb;
    vec3 finalColor = baseColor + vec3(totalHighlight);
    
    finalColor = clamp(finalColor, 0.0, 1.0);
    float alpha = uTintColor.a;
    
    // Flutter expects pre-multiplied alpha
    fragColor = vec4(finalColor * alpha, alpha);
}
