#version 460 core

#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

// Uniform inputs
uniform vec2 uResolution;
uniform float uTime;
uniform vec2 uTouchPos;
uniform float uTouchIntensity;
uniform float uRefractionStrength;
uniform float uThickness;
uniform float uLightAngle;
uniform float uSpecularIntensity;
uniform float uChromaticAberration;
uniform float uInnerGlow;
uniform vec4 uTintColor; // Unmultiplied R, G, B, A in range [0, 1]
uniform float uCornerSmoothing;
uniform float uNoiseIntensity;
uniform float uShapeType; // 0.0: Rect/Squircle, 1.0: Circle/Pill, 2.0: Polygon/Custom
uniform float uQuality; // 0.0: Low, 1.0: Medium, 2.0: High

float hash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  vec2 uv = coord / uResolution;

  // Normalized coordinates centered at (0, 0) in range [-1, 1]
  vec2 p = (uv - 0.5) * 2.0;
  float aspect = uResolution.x / max(uResolution.y, 0.001);
  vec2 pAspect = vec2(p.x * aspect, p.y);

  // Shape distance metric
  float dist = 0.0;
  if (uShapeType > 0.5 && uShapeType < 1.5) {
    // Circle / Pill / Ellipse
    dist = length(p);
  } else {
    // Continuous corner squircle / rounded box approximation
    float exponent = 2.0 + clamp(uCornerSmoothing, 0.0, 1.0) * 3.5;
    vec2 pAbs = abs(p);
    dist = pow(pow(pAbs.x, exponent) + pow(pAbs.y, exponent), 1.0 / exponent);
  }

  // Edge proximity [0.0 at center, 1.0 at outer boundary]
  float edgeDist = clamp(dist, 0.0, 1.0);
  float edgeSlope = smoothstep(0.6, 1.0, edgeDist);

  // Optical surface normal estimation
  vec2 radialDir = length(p) > 0.001 ? normalize(p) : vec2(0.0);
  vec2 normalXY = radialDir * edgeSlope * clamp(uRefractionStrength, 0.0, 1.0) * 1.5;
  float normalZ = sqrt(max(1.0 - dot(normalXY, normalXY), 0.01));
  vec3 normal = normalize(vec3(normalXY, normalZ));

  // Light vector derived from uLightAngle
  vec2 lightXY = vec2(cos(uLightAngle), sin(uLightAngle));
  vec3 lightDir = normalize(vec3(lightXY, 0.55));
  vec3 viewDir = vec3(0.0, 0.0, 1.0);

  // Specular Blinn-Phong reflection
  vec3 halfVec = normalize(lightDir + viewDir);
  float nDotH = max(dot(normal, halfVec), 0.0);
  float specBase = pow(nDotH, 28.0) * uSpecularIntensity;

  // Chromatic dispersion split
  float chromatic = clamp(uChromaticAberration, 0.0, 1.0) * 0.15;
  vec3 normalR = normalize(vec3(normalXY * (1.0 + chromatic), normalZ));
  vec3 normalB = normalize(vec3(normalXY * (1.0 - chromatic), normalZ));
  float specR = pow(max(dot(normalR, halfVec), 0.0), 32.0) * uSpecularIntensity;
  float specB = pow(max(dot(normalB, halfVec), 0.0), 24.0) * uSpecularIntensity;
  vec3 specularColor = vec3(specR, specBase, specB);

  // Fresnel-style rim lighting
  float nDotV = max(dot(normal, viewDir), 0.0);
  float fresnel = pow(1.0 - nDotV, 2.5) * uInnerGlow;

  // Directional edge rim: Edge facing the light source glows brighter
  float directionalRim = max(dot(radialDir, lightXY), 0.0) * fresnel * 1.2;
  float totalRim = fresnel * 0.6 + directionalRim;

  // Touch-driven interaction lighting
  float touchEffect = 0.0;
  if (uTouchIntensity > 0.001) {
    float distToTouch = length(uv - uTouchPos);
    // Radial glow under touch
    float touchGlow = smoothstep(0.28, 0.0, distToTouch) * uTouchIntensity * 0.55;
    // Ripple ring wave
    float waveDist = abs(distToTouch - 0.15 * fract(uTime * 1.2));
    float touchWave = smoothstep(0.04, 0.0, waveDist) * uTouchIntensity * 0.35;
    touchEffect = touchGlow + touchWave;
  }

  // Subtle pseudo-random noise to prevent banding on 8-bit displays
  float noise = 0.0;
  if (uNoiseIntensity > 0.001 && uQuality > 0.5) {
    noise = (hash(coord) - 0.5) * uNoiseIntensity;
  }

  // Combine highlights and tint
  vec3 baseColor = uTintColor.rgb;
  vec3 highlights = specularColor + vec3(totalRim) + vec3(touchEffect);
  vec3 finalRgb = clamp(baseColor + highlights + vec3(noise), 0.0, 1.0);

  // Translucency & alpha compositing
  float alphaGain = (specBase + totalRim) * 0.35 + touchEffect * 0.25;
  float finalAlpha = clamp(uTintColor.a + alphaGain, 0.0, 1.0);

  // Premultiplied alpha output for Flutter Skia / Impeller pipeline
  fragColor = vec4(finalRgb * finalAlpha, finalAlpha);
}
