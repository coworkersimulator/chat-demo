import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { uuid_ossp } from '@electric-sql/pglite/contrib/uuid_ossp';
import fs from 'node:fs';

const pglite = await PGlite.create({
  extensions: { pgcrypto, uuid_ossp },
});

const migrationDir = `${import.meta.dirname}/migrations/client`;
const files = fs
  .readdirSync(migrationDir)
  .filter((f) => f.endsWith('.sql'))
  .sort();
let currentVersion = '0000';
try {
  const result = await pglite.query<{ version: string }>(
    'SELECT version FROM migration ORDER BY version DESC LIMIT 1',
  );
  if (result.rows.length > 0) currentVersion = result.rows[0].version;
} catch {
  // migration table doesn't exist yet — run all migrations
}

for (const file of files) {
  const fileVersion = file.slice(0, 4);
  if (fileVersion <= currentVersion) continue;
  const sql = fs.readFileSync(`${migrationDir}/${file}`).toString();
  await pglite.exec(sql);
}

export { pglite };

export default pglite;
