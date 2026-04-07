import { CamelCasePlugin, Kysely } from 'kysely';
import { PGliteDialect } from 'kysely-pglite-dialect';
import { pglite } from './pglite';
import type { DB } from './types';

const kysely = new Kysely<DB>({
  dialect: new PGliteDialect(pglite),
  plugins: [new CamelCasePlugin()],
});

export { kysely };

export default kysely;
