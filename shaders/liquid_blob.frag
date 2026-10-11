#version 460 core

#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

uniform vec2 uResolution;
uniform float uTime;
uniform vec4 uTintColor;
uniform float uWobble;
uniform float uNoiseIntensity;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  vec2 uv = coord / uResolution;
  vec2 p = (uv - 0.5) * 2.0;

  float angle = atan(p.y, p.x);
  float wobble = uWobble * (0.08 * sin(angle * 3.0 + uTime) + 0.05 * sin(angle * 5.0 - uTime * 0.7));
  float radius = length(p);

  float edge = smoothstep(1.0 + wobble, 0.94 + wobble, radius);
  float rim = smoothstep(0.12, 0.0, abs(radius - (0.91 + wobble)));

  float noise = 0.0;
  if (uNoiseIntensity > 0.001) {
    noise = (hash(floor(uv * uResolution * 0.08)) - 0.5) * uNoiseIntensity;
  }

  vec3 color = clamp(uTintColor.rgb + vec3(rim * 0.2 + noise), 0.0, 1.0);
  float alpha = clamp(uTintColor.a * edge + rim * 0.15, 0.0, 1.0);

  fragColor = vec4(color * alpha, alpha);
}
