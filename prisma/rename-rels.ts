import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const schemaPath = resolve(import.meta.dirname, 'schema.prisma');
let schema = readFileSync(schemaPath, 'utf-8');

// Back-ref arrays (Type[]) → {direction}_rels
// e.g. rel_rel_as_file_idTofile Rel[] → as_rels
//      other_rel_rel_as_rel_idTorel Rel[] → as_rels  (self-ref back-ref)
schema = schema.replace(
  /^(\s+)\w+(\s+\w+\[\]\s+@relation\("rel_(as|on|by)[^"]*"\)[^\n]*)$/gm,
  (_, indent, rest, dir) => `${indent}${dir}_rels${rest}`,
);

// FK-side singulars (Type?) → {direction}_{target}
// e.g. file_rel_as_file_idTofile File? → as_file
//      rel_rel_as_rel_idTorel rel? → as_rel  (self-ref FK side)
//      user_rel_byTouser user? → by_user
schema = schema.replace(
  /^(\s+)\w+(\s+\w+\?\s+@relation\("rel_(as|on|by)[^"]*To(\w+)"[^)]*\)[^\n]*)$/gm,
  (_, indent, rest, dir, target) => `${indent}${dir}_${target}${rest}`,
);

writeFileSync(schemaPath, schema);
console.log('Renamed relation fields in prisma/schema.prisma');
