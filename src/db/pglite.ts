import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { uuid_ossp } from '@electric-sql/pglite/contrib/uuid_ossp';

const migrations = import.meta.glob('../../db/migrations/client/*.sql', {
  query: '?raw',
  import: 'default',
  eager: true,
}) as Record<string, string>;

export async function createPglite() {
  const pglite = await PGlite.create({
    extensions: { pgcrypto, uuid_ossp },
  });

  let currentVersion = '0000';
  try {
    const result = await pglite.query<{ version: string }>(
      'SELECT version FROM migration ORDER BY version DESC LIMIT 1',
    );
    if (result.rows.length > 0) currentVersion = result.rows[0].version;
  } catch {
    // migration table doesn't exist yet — run all migrations
  }

  for (const path of Object.keys(migrations).sort()) {
    const fileVersion = (path.split('/').pop() ?? '').slice(0, 4);
    if (fileVersion <= currentVersion) continue;
    await pglite.exec(migrations[path]);
  }

  return pglite;
}
