#version 460 core

#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

// Uniforms
uniform vec2 uSize;
uniform float uDistortionStrength;
uniform float uHighlightIntensity;
uniform vec4 uTintColor; // R, G, B, A (pre-multiplied usually, but we will pass standard RGBA and multiply here if needed)

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Simulate a subtle internal distortion or "wobble"
    // Since we don't have a background texture, we create a fake caustics/specular effect
    float wobbleX = sin(uv.y * 10.0) * uDistortionStrength;
    float wobbleY = cos(uv.x * 10.0) * uDistortionStrength;
    vec2 distortedUv = uv + vec2(wobbleX, wobbleY);
    
    // Generate a soft edge highlight
    // Calculate distance from edges (0 at edges, 0.5 at center)
    float distX = min(distortedUv.x, 1.0 - distortedUv.x);
    float distY = min(distortedUv.y, 1.0 - distortedUv.y);
    float edgeDist = min(distX, distY);
    
    // Create a rim light effect (stronger near the edges, decaying inwards)
    float rimLight = smoothstep(0.15, 0.0, edgeDist);
    
    // Create a subtle top-left specular highlight
    float specular = smoothstep(0.3, 0.0, length(distortedUv - vec2(0.2, 0.2)));
    
    float totalHighlight = (rimLight * 0.5 + specular) * uHighlightIntensity;
    
    // Base color
    vec3 baseColor = uTintColor.rgb;
    
    // Add highlight
    vec3 finalColor = baseColor + vec3(totalHighlight);
    
    // Clamp to prevent blowout
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    // Output pre-multiplied alpha
    float alpha = uTintColor.a;
    fragColor = vec4(finalColor * alpha, alpha);
}
