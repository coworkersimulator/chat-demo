import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { uuid_ossp } from '@electric-sql/pglite/contrib/uuid_ossp';
import { Kysely } from 'kysely';
import { generate, PostgresDialect } from 'kysely-codegen';
import { PGliteDialect } from 'kysely-pglite-dialect';
import fs from 'node:fs';

const pglite = await PGlite.create({
  extensions: { pgcrypto, uuid_ossp },
});

const migrationDir = `${import.meta.dirname}/migrations/client`;
const files = fs
  .readdirSync(migrationDir)
  .filter((f) => f.endsWith('.sql'))
  .sort();
for (const file of files) {
  const sql = fs.readFileSync(`${migrationDir}/${file}`).toString();
  await pglite.exec(sql);
}

const db = new Kysely<any>({ dialect: new PGliteDialect(pglite) });

await generate({
  db,
  dialect: new PostgresDialect(), // this is kysely-codegen's dialect, not Kysely's
  outFile: 'src/kysely/db.d.ts',
});

await db.destroy();
console.log('Kysely code generated for client');
