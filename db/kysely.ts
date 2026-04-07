import { Kysely } from 'kysely';
import type { DB } from 'kysely-codegen';
import { PGliteDialect } from 'kysely-pglite-dialect';
import { pglite } from './pglite';

const kysely = new Kysely<DB>({ dialect: new PGliteDialect(pglite) });

export { kysely };

export default kysely;
