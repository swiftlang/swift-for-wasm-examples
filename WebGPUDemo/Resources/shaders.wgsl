
@group(0) @binding(0) var<storage, read> vertices: array<vec4f>;
@group(0) @binding(1) var<storage, read> indices: array<u32>;
@group(0) @binding(2) var<storage, read> uvs: array<vec2f>;
@group(0) @binding(3) var<storage, read> normals: array<vec4f>;
@group(0) @binding(4) var albedoTexture: texture_2d<f32>;
@group(0) @binding(5) var normalTexture: texture_2d<f32>;
@group(0) @binding(6) var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(7) var<storage, read> modelMatrix: mat4x4f;
@group(0) @binding(8) var texSampler: sampler;
@group(0) @binding(9) var<storage, read> viewProjectionMatrix: mat4x4f;

struct VSOut {
  @builtin(position) pos: vec4f,
  @location(0) worldPos: vec4f,
  @location(1) texCoord: vec2f,
  @location(2) normal: vec3f,
  @location(3) tangent: vec3f,
};

fn hash(_a: u32) -> u32 {
  var a = _a;
  a = (a+0x7ed55d16) + (a<<12);
  a = (a^0xc761c23c) ^ (a>>19);
  a = (a+0x165667b1) + (a<<5);
  a = (a+0xd3a2646c) ^ (a<<9);
  a = (a+0xfd7046c5) + (a<<3);
  a = (a^0xb55a4f09) ^ (a>>16);
  return a;
}

fn getRow(row: u32, m: mat4x4f) -> vec4f {
  return vec4(m[0][row], m[1][row], m[2][row], m[3][row]);
}

fn mat3x3f_make_row_first(a: vec3<f32>, b: vec3<f32>, c: vec3<f32>) -> mat3x3f {
  return mat3x3f(vec3(a.x, b.x, c.x),
                 vec3(a.y, b.y, c.y),
                 vec3(a.z, b.z, c.z));
}

fn adjoint(m: mat4x4f) -> mat3x3f {
  return mat3x3f_make_row_first(
    cross(getRow(1, m).xyz, getRow(2, m).xyz) * -1.0,
    cross(getRow(2, m).xyz, getRow(0, m).xyz) * -1.0,
    cross(getRow(0, m).xyz, getRow(1, m).xyz) * -1.0
  );
}

@vertex fn vs(
  @builtin(vertex_index) vertexIndex : u32
) -> VSOut {
  var out = VSOut();
  let index = vertexIndex;
  out.worldPos = modelMatrix * vertices[index];
  out.pos = viewProjectionMatrix * out.worldPos;
  out.texCoord = uvs[index];
  out.normal = normalize(adjoint(modelMatrix) * normals[index].xyz);

  var up = vec3(1.0, 0.0, 0.0);
  if (out.normal.y < 0.999) {
    up = vec3(0.0, 1.0, 0.0);
  }
  out.tangent = normalize(cross(up, out.normal));

  return out;
}

fn sqr(x: f32) -> f32 {
  return x * x;
}

fn schlickFresnel(VdotH: f32, F0: vec3f, F90: f32) -> vec3f {
  return (F0 + (1.0 - F0) * pow(1.0f - VdotH, 5));
}

fn ggxDistribution(NoH: f32, roughness: f32, h: vec3f) -> f32 {
  let oneMinusNoHSquared = 1 - NoH * NoH;
  let a = NoH * roughness;
  let k = roughness / (oneMinusNoHSquared + a * a);
  let d = k * k * (1.0 / 3.1415);

  return min(d, 65504.0);
}

fn V_SmithGGXCorrelated(alpha2: f32, NoV: f32, NoL: f32) -> f32 {
  let lambdaV = NoL * sqrt((NoV - alpha2 * NoV) * NoV + alpha2);
  let lambdaL = NoV * sqrt((NoL - alpha2 * NoL) * NoL + alpha2);
  let v = 0.5 / (lambdaV + lambdaL);
  return min(v, 65504.0);
}

fn BRDF_diffuse(F: vec3f, NoL: f32, metallic: f32) -> vec3f {
  let diffuse = (1.0 - F) * (1.0 - metallic);

  return diffuse * NoL;
}

fn BRDF_specular(roughness: f32, F: vec3f, H: vec3f, NoH: f32, NoV: f32, NoL: f32) -> vec3f {
  let D = ggxDistribution(NoH, roughness, H);
  let Vis = V_SmithGGXCorrelated(sqr(roughness), NoV, NoL);
  let specular = D * Vis * F;

  return specular * NoL;
}

struct Lighting {
  diffuse: vec3f,
  specular: vec3f,
};

fn sunLight(V: vec3f, N: vec3f, F0: vec3f, roughness: f32, metallic: f32) -> Lighting {
  let L = normalize(vec3f(0.5, -0.5, -0.5));
  let H = normalize(L + V);

  let NoH = saturate(dot(N, H));
  let NoV = saturate(dot(N, V));
  let NoL = saturate(dot(N, L));
  let VoH = saturate(dot(V, H));

  let F90 = saturate(dot(F0, vec3(0.33)));
  let F = schlickFresnel(VoH, F0, F90);

  let lightColor = vec3(1.0, 1.0, 0.984) * 2.5;

  let diffuse = lightColor * BRDF_diffuse(F, NoL, metallic);
  let specular = lightColor * BRDF_specular(roughness, F, H, NoH, NoV, NoL);

  return Lighting(diffuse, specular);
}

fn ACESToneMapping(color: vec3f) -> vec3f {
  let a = 2.51f;
  let b = 0.03f;
  let c = 2.43f;
  let d = 0.59f;
  let e = 0.14f;
  return saturate((color*(a*color+b))/(color*(c*color+d)+e));
}

@fragment fn fs(input: VSOut) -> @location(0) vec4f {
  let vertPos = input.pos;

  let N = normalize(input.normal);
  var T = normalize(input.tangent);
  var B = normalize(cross(N, T));

  var normalMap = textureSample(normalTexture, texSampler, input.texCoord).xyz * 2.0 - 1.0;
  normalMap = vec3f(normalMap.xy * 2.0, normalMap.z);
  normalMap = normalize(normalMap);
  let TBN = mat3x3(T.x, B.x, N.x, T.y, B.y, N.y, T.z, B.z, N.z);

  var worldNormal = normalize(TBN * normalMap);
  worldNormal.y *= -1;
  let albedo = textureSample(albedoTexture, texSampler, input.texCoord);
  let metalRoughness = textureSample(metallicRoughnessTexture, texSampler, input.texCoord);

  let V = normalize(input.worldPos).xyz;
  let F0 = mix(vec3f(0.04), albedo.rgb, metalRoughness.b);
  let roughness = max(0.08, metalRoughness.g);

  let lighting = sunLight(V, worldNormal, F0, roughness, metalRoughness.b);

  return vec4f(ACESToneMapping(albedo.rgb * max(lighting.diffuse, vec3(0.2, 0.2, 0.2)) + lighting.specular), 1.0);
}

