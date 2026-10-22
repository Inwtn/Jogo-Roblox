// Procedural source for a reusable Aurora oak mesh and a local visual preview.
import fs from 'node:fs/promises';
import path from 'node:path';
import zlib from 'node:zlib';

const root = path.resolve(import.meta.dirname, '..');
const output = path.join(root, 'assets', 'models');
await fs.mkdir(output, { recursive: true });

const add = (a, b) => a.map((v, i) => v + b[i]);
const sub = (a, b) => a.map((v, i) => v - b[i]);
const mul = (a, s) => a.map(v => v * s);
const dot = (a, b) => a.reduce((sum, v, i) => sum + v * b[i], 0);
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const norm = a => mul(a, 1 / (Math.hypot(...a) || 1));
const clamp = x => Math.max(0, Math.min(1, x));

function geometry() {
  return { positions: [], normals: [], colors: [], uvs: [], indices: [] };
}
function vertex(g, position, normal, color, uv) {
  const index = g.positions.length / 3;
  g.positions.push(...position);
  g.normals.push(...normal);
  g.colors.push(...color, 1);
  g.uvs.push(...uv);
  return index;
}
function tube(g, points, radii, seed) {
  const sides = 10;
  const rings = [];
  for (let ring = 0; ring < points.length; ring++) {
    const tangent = norm(sub(points[Math.min(ring + 1, points.length - 1)], points[Math.max(0, ring - 1)]));
    const guide = Math.abs(dot(tangent, [0, 1, 0])) > .92 ? [1, 0, 0] : [0, 1, 0];
    const u = norm(cross(tangent, guide));
    const v = norm(cross(tangent, u));
    const ids = [];
    for (let side = 0; side < sides; side++) {
      const theta = side * Math.PI * 2 / sides;
      const radial = add(mul(u, Math.cos(theta)), mul(v, Math.sin(theta)));
      const rough = 1 + .035 * Math.sin(side * 2.1 + ring * 1.3 + seed);
      const position = add(points[ring], mul(radial, radii[ring] * rough));
      const variation = .94 + .06 * Math.sin(side * 1.7 + seed);
      const color = [.41 * variation, .28 * variation, .17 * variation];
      ids.push(vertex(g, position, radial, color, [side / sides, ring / (points.length - 1)]));
    }
    rings.push(ids);
  }
  for (let ring = 0; ring < rings.length - 1; ring++) {
    for (let side = 0; side < sides; side++) {
      const next = (side + 1) % sides;
      const a = rings[ring][side], b = rings[ring][next];
      const c = rings[ring + 1][side], d = rings[ring + 1][next];
      g.indices.push(a, c, b, b, c, d);
    }
  }
}
function canopyUnion(g) {
  const lobes = [
    [[-3.1, 13.9, -2.5], [4.6, 3.8, 4]],
    [[3.5, 13.7, -2.4], [4.4, 3.6, 3.8]],
    [[-3.7, 13.4, 2.6], [4.3, 3.5, 3.8]],
    [[3.6, 13.7, 2.6], [4.5, 3.7, 3.9]],
    [[0, 15.8, 0], [5.2, 4.2, 4.6]],
    [[.2, 18, -.3], [3.8, 3.1, 3.6]],
    [[-1.7, 18.1, 2], [2.9, 2.6, 2.8]],
  ];
  const smoothMin = (a, b, k) => {
    const h = Math.max(k - Math.abs(a - b), 0) / k;
    return Math.min(a, b) - h * h * k * .25;
  };
  const field = p => {
    let value = Infinity;
    for (const [center, radius] of lobes) {
      const x = (p[0] - center[0]) / radius[0];
      const y = (p[1] - center[1]) / radius[1];
      const z = (p[2] - center[2]) / radius[2];
      value = smoothMin(value, x * x + y * y + z * z - 1, .27);
    }
    return value + .025 * Math.sin(p[0] * 1.8 + p[2]) * Math.cos(p[1] * 1.5 + p[2] * 1.1);
  };
  const normalAt = p => {
    const d = .04;
    return norm([
      field([p[0] + d, p[1], p[2]]) - field([p[0] - d, p[1], p[2]]),
      field([p[0], p[1] + d, p[2]]) - field([p[0], p[1] - d, p[2]]),
      field([p[0], p[1], p[2] + d]) - field([p[0], p[1], p[2] - d]),
    ]);
  };
  const emit = (a, b, c) => {
    const outward = norm(add(add(normalAt(a), normalAt(b)), normalAt(c)));
    if (dot(cross(sub(b, a), sub(c, a)), outward) < 0) [b, c] = [c, b];
    for (const p of [a, b, c]) {
      const y = clamp((p[1] - 9) / 13);
      const tint = .95 + .05 * Math.sin(p[0] * 1.4 + p[2] * 1.1);
      vertex(g, p, normalAt(p), [(.88 + .12 * y) * tint, (.9 + .1 * y) * tint, (.84 + .16 * y) * tint],
        [(Math.atan2(p[2], p[0]) / (Math.PI * 2) + .5) * 3, y * 2]);
    }
    const end = g.positions.length / 3;
    g.indices.push(end - 3, end - 2, end - 1);
  };
  const tetrahedra = [[0, 5, 1, 6], [0, 1, 2, 6], [0, 2, 3, 6], [0, 3, 7, 6], [0, 7, 4, 6], [0, 4, 5, 6]];
  const step = 1.2;
  for (let x = -9.6; x < 9.6; x += step) for (let y = 8.8; y < 23.2; y += step) for (let z = -9.6; z < 9.6; z += step) {
    const corners = [
      [x, y, z], [x + step, y, z], [x + step, y + step, z], [x, y + step, z],
      [x, y, z + step], [x + step, y, z + step], [x + step, y + step, z + step], [x, y + step, z + step],
    ];
    const values = corners.map(field);
    if (values.every(v => v >= 0) || values.every(v => v < 0)) continue;
    for (const tetra of tetrahedra) {
      const inside = tetra.filter(i => values[i] < 0), outside = tetra.filter(i => values[i] >= 0);
      if (inside.length === 0 || outside.length === 0) continue;
      const cut = (i, j) => {
        const t = values[i] / (values[i] - values[j]);
        return add(corners[i], mul(sub(corners[j], corners[i]), t));
      };
      if (inside.length === 1) emit(cut(inside[0], outside[0]), cut(inside[0], outside[1]), cut(inside[0], outside[2]));
      else if (outside.length === 1) emit(cut(outside[0], inside[0]), cut(outside[0], inside[1]), cut(outside[0], inside[2]));
      else {
        const a = cut(inside[0], outside[0]), b = cut(inside[0], outside[1]);
        const c = cut(inside[1], outside[0]), d = cut(inside[1], outside[1]);
        emit(a, b, c); emit(b, d, c);
      }
    }
  }
}

const bark = geometry(), leaves = geometry();
tube(bark, [[0, 0, 0], [.1, 2.5, 0], [.2, 5.5, .1], [.35, 8.5, .1], [.55, 11.8, .2]], [1.45, 1.15, .95, .73, .44], 1);
for (let i = 0; i < 5; i++) {
  const angle = i * Math.PI * 2 / 5 + .25;
  const dx = Math.cos(angle), dz = Math.sin(angle);
  tube(bark, [[dx * .25, 2.1, dz * .25], [dx * 1.15, .8, dz * 1.15], [dx * 2.7, .15, dz * 2.7]], [.62, .48, .12], i + 2);
}
const branches = [
  [[.15, 8.2, 0], [-1.6, 10.5, -1.6], [-3.6, 12.5, -2.3]],
  [[.2, 8.6, .1], [1.8, 10.8, -1.5], [3.7, 12.8, -2.7]],
  [[.25, 8.7, .15], [-1.9, 10.5, 1.5], [-3.8, 12.6, 3.1]],
  [[.3, 9, .1], [1.8, 11.2, 1.7], [3.7, 13.2, 2.7]],
];
branches.forEach((points, i) => tube(bark, points, [.55, .4, .1], i + 9));
canopyUnion(leaves);

function toGltf(meshes) {
  const chunks = [], bufferViews = [], accessors = [];
  let byteLength = 0;
  function accessor(data, type, componentType, target, withBounds = false) {
    const array = componentType === 5123 ? new Uint16Array(data) : new Float32Array(data);
    const bytes = Buffer.from(array.buffer, array.byteOffset, array.byteLength);
    const offset = byteLength;
    chunks.push(bytes);
    byteLength += bytes.length;
    const padding = (4 - byteLength % 4) % 4;
    if (padding) { chunks.push(Buffer.alloc(padding)); byteLength += padding; }
    const view = bufferViews.length;
    bufferViews.push({ buffer: 0, byteOffset: offset, byteLength: bytes.length, target });
    const count = data.length / ({ SCALAR: 1, VEC2: 2, VEC3: 3, VEC4: 4 })[type];
    const result = { bufferView: view, componentType, count, type };
    if (withBounds) {
      result.min = [0, 1, 2].map(axis => Math.min(...data.filter((_, i) => i % 3 === axis)));
      result.max = [0, 1, 2].map(axis => Math.max(...data.filter((_, i) => i % 3 === axis)));
    }
    accessors.push(result);
    return accessors.length - 1;
  }
  const primitives = meshes.map((g, material) => ({
    attributes: {
      POSITION: accessor(g.positions, 'VEC3', 5126, 34962, true),
      NORMAL: accessor(g.normals, 'VEC3', 5126, 34962),
      COLOR_0: accessor(g.colors, 'VEC4', 5126, 34962),
      TEXCOORD_0: accessor(g.uvs, 'VEC2', 5126, 34962),
    },
    indices: accessor(g.indices, 'SCALAR', 5123, 34963),
    material,
  }));
  const binary = Buffer.concat(chunks);
  return {
    asset: { version: '2.0', generator: 'Ilha da Aurora procedural oak' },
    scene: 0, scenes: [{ nodes: [0] }],
    nodes: [
      { name: 'CarvalhoDaAurora', children: [1, 2] },
      { name: 'Tronco', mesh: 0 },
      { name: 'Copa', mesh: 1 },
    ],
    meshes: [
      { name: 'Tronco', primitives: [primitives[0]] },
      { name: 'Copa', primitives: [primitives[1]] },
    ],
    materials: [
      { name: 'Casca', pbrMetallicRoughness: { baseColorFactor: [1, 1, 1, 1], metallicFactor: 0, roughnessFactor: 1 }, doubleSided: true },
      { name: 'Folhagem', pbrMetallicRoughness: { baseColorFactor: [1, 1, 1, 1], baseColorTexture: { index: 0 }, metallicFactor: 0, roughnessFactor: 1 }, doubleSided: true },
    ],
    samplers: [{ magFilter: 9729, minFilter: 9987, wrapS: 10497, wrapT: 10497 }],
    images: [{ uri: 'CarvalhoDaAurora-foliage.png', mimeType: 'image/png' }],
    textures: [{ sampler: 0, source: 0 }],
    buffers: [{ byteLength: binary.length, uri: 'data:application/octet-stream;base64,' + binary.toString('base64') }],
    bufferViews, accessors,
  };
}

function decodePngRgb(png) {
  const width = png.readUInt32BE(16), height = png.readUInt32BE(20);
  if (png[24] !== 8 || png[25] !== 2) throw new Error('Expected 8-bit RGB foliage PNG');
  const compressed = [];
  for (let offset = 8; offset < png.length;) {
    const length = png.readUInt32BE(offset), type = png.toString('ascii', offset + 4, offset + 8);
    if (type === 'IDAT') compressed.push(png.subarray(offset + 8, offset + 8 + length));
    offset += length + 12;
  }
  const raw = zlib.inflateSync(Buffer.concat(compressed));
  const pixels = Buffer.alloc(width * height * 3);
  const stride = width * 3;
  let input = 0;
  for (let y = 0; y < height; y++) {
    const filter = raw[input++];
    for (let x = 0; x < stride; x++) {
      const left = x >= 3 ? pixels[y * stride + x - 3] : 0;
      const above = y > 0 ? pixels[(y - 1) * stride + x] : 0;
      const upperLeft = y > 0 && x >= 3 ? pixels[(y - 1) * stride + x - 3] : 0;
      let predictor = 0;
      if (filter === 1) predictor = left;
      else if (filter === 2) predictor = above;
      else if (filter === 3) predictor = Math.floor((left + above) / 2);
      else if (filter === 4) {
        const p = left + above - upperLeft;
        const distances = [Math.abs(p - left), Math.abs(p - above), Math.abs(p - upperLeft)];
        predictor = distances[0] <= distances[1] && distances[0] <= distances[2] ? left : distances[1] <= distances[2] ? above : upperLeft;
      } else if (filter !== 0) throw new Error('Unsupported PNG filter: ' + filter);
      pixels[y * stride + x] = (raw[input++] + predictor) & 255;
    }
  }
  return { width, height, pixels };
}

function preview(meshes, foliage) {
  const width = 720, height = 720;
  const pixels = Buffer.alloc(width * height * 4), depth = new Float32Array(width * height).fill(Infinity);
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) {
    const i = (y * width + x) * 4;
    const t = y / height;
    pixels[i] = Math.round(205 + t * 24); pixels[i + 1] = Math.round(226 + t * 19);
    pixels[i + 2] = Math.round(235 - t * 4); pixels[i + 3] = 255;
  }
  const camera = [29, 22, 34], target = [0, 11, 0];
  const forward = norm(sub(target, camera)), right = norm(cross(forward, [0, 1, 0])), up = norm(cross(right, forward));
  const project = p => {
    const v = sub(p, camera), d = dot(v, forward);
    return [width / 2 + dot(v, right) * 900 / d, height / 2 - dot(v, up) * 900 / d, d];
  };
  const sun = norm([-0.55, .85, .5]);
  for (const [meshIndex, g] of meshes.entries()) {
    for (let t = 0; t < g.indices.length; t += 3) {
      const ids = g.indices.slice(t, t + 3);
      const world = ids.map(id => g.positions.slice(id * 3, id * 3 + 3));
      const pts = world.map(project);
      if (pts.some(p => p[2] <= 0)) continue;
      const n = norm(cross(sub(world[1], world[0]), sub(world[2], world[0])));
      const light = .73 + .27 * Math.max(0, dot(n, sun));
      const base = [0, 1, 2].map(channel => ids.reduce((sum, id) => sum + g.colors[id * 4 + channel], 0) / 3);
      const color = base.map(c => Math.round(clamp(c * light) * 255));
      const minX = Math.max(0, Math.floor(Math.min(...pts.map(p => p[0]))));
      const maxX = Math.min(width - 1, Math.ceil(Math.max(...pts.map(p => p[0]))));
      const minY = Math.max(0, Math.floor(Math.min(...pts.map(p => p[1]))));
      const maxY = Math.min(height - 1, Math.ceil(Math.max(...pts.map(p => p[1]))));
      const [a, b, c] = pts;
      const area = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
      if (Math.abs(area) < .0001) continue;
      for (let y = minY; y <= maxY; y++) for (let x = minX; x <= maxX; x++) {
        const px = x + .5, py = y + .5;
        const w0 = ((b[0] - px) * (c[1] - py) - (b[1] - py) * (c[0] - px)) / area;
        const w1 = ((c[0] - px) * (a[1] - py) - (c[1] - py) * (a[0] - px)) / area;
        const w2 = 1 - w0 - w1;
        if (w0 < 0 || w1 < 0 || w2 < 0) continue;
        const d = w0 * a[2] + w1 * b[2] + w2 * c[2];
        const index = y * width + x;
        if (d >= depth[index]) continue;
        depth[index] = d;
        if (meshIndex === 1) {
          const u = ids.reduce((sum, id, corner) => sum + [w0, w1, w2][corner] * g.uvs[id * 2], 0);
          const v = ids.reduce((sum, id, corner) => sum + [w0, w1, w2][corner] * g.uvs[id * 2 + 1], 0);
          const tx = Math.floor(((u % 1 + 1) % 1) * foliage.width);
          const ty = Math.floor(((v % 1 + 1) % 1) * foliage.height);
          const texel = (ty * foliage.width + tx) * 3;
          for (let channel = 0; channel < 3; channel++) pixels[index * 4 + channel] = color[channel] * foliage.pixels[texel + channel] / 255;
        } else {
          pixels[index * 4] = color[0]; pixels[index * 4 + 1] = color[1]; pixels[index * 4 + 2] = color[2];
        }
      }
    }
  }
  const crcTable = Array.from({ length: 256 }, (_, i) => {
    let c = i; for (let j = 0; j < 8; j++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    return c >>> 0;
  });
  const crc32 = data => {
    let c = 0xffffffff; for (const byte of data) c = crcTable[(c ^ byte) & 255] ^ (c >>> 8);
    return (c ^ 0xffffffff) >>> 0;
  };
  const chunk = (type, data) => {
    const tag = Buffer.from(type); const size = Buffer.alloc(4); size.writeUInt32BE(data.length);
    const checksum = Buffer.alloc(4); checksum.writeUInt32BE(crc32(Buffer.concat([tag, data])));
    return Buffer.concat([size, tag, data, checksum]);
  };
  const raw = Buffer.alloc(height * (1 + width * 4));
  for (let y = 0; y < height; y++) pixels.copy(raw, y * (1 + width * 4) + 1, y * width * 4, (y + 1) * width * 4);
  const ihdr = Buffer.alloc(13); ihdr.writeUInt32BE(width, 0); ihdr.writeUInt32BE(height, 4); ihdr[8] = 8; ihdr[9] = 6;
  return Buffer.concat([Buffer.from('89504e470d0a1a0a', 'hex'), chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

const gltf = toGltf([bark, leaves]);
const foliage = decodePngRgb(await fs.readFile(path.join(output, 'CarvalhoDaAurora-foliage.png')));
await fs.writeFile(path.join(output, 'CarvalhoDaAurora.gltf'), JSON.stringify(gltf));
await fs.writeFile(path.join(output, 'CarvalhoDaAurora-preview.png'), preview([bark, leaves], foliage));
console.log(JSON.stringify({ gltf: path.join(output, 'CarvalhoDaAurora.gltf'), vertices: (bark.positions.length + leaves.positions.length) / 3, triangles: (bark.indices.length + leaves.indices.length) / 3 }));
