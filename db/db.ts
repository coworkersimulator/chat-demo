import { CamelCasePlugin, Kysely } from 'kysely';
import { PGliteDialect } from 'kysely-pglite-dialect';
import type { DB } from '../src/db/types';
import { pglite } from './pglite';
import { SoftDeletePlugin } from './soft-delete-plugin';

export const softDeletePlugin = new SoftDeletePlugin();
export const camelCasePlugin = new CamelCasePlugin();

const kysely = new Kysely<DB>({
  dialect: new PGliteDialect(pglite),
  plugins: [softDeletePlugin, camelCasePlugin],
});

export { kysely };

export default kysely;
