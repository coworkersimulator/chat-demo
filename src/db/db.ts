import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { uuid_ossp } from '@electric-sql/pglite/contrib/uuid_ossp';
import { Kysely } from 'kysely';
import { PGliteDialect } from 'kysely-pglite-dialect';
import type { DB } from '../../db/types';

const pglite = await PGlite.create({
  extensions: { pgcrypto, uuid_ossp },
});

const migrations = import.meta.glob('../../db/migrations/client/*.sql', {
  query: '?raw',
  import: 'default',
  eager: true,
}) as Record<string, string>;

for (const path of Object.keys(migrations).sort()) {
  await pglite.exec(migrations[path]);
}

const db = new Kysely<DB>({ dialect: new PGliteDialect(pglite) });

export { db, pglite };
export default db;
