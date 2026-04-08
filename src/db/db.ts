import { CamelCasePlugin, Kysely } from 'kysely';
import { PGliteDialect } from 'kysely-pglite-dialect';
import { SoftDeletePlugin } from '../../db/soft-delete-plugin';
import pglite from './pglite';
import type { DB } from './types';

export const softDeletePlugin = new SoftDeletePlugin();
export const camelCasePlugin = new CamelCasePlugin();

const db = new Kysely<DB>({
  dialect: new PGliteDialect(pglite),
  plugins: [softDeletePlugin, camelCasePlugin],
});

export { db, pglite };
export default db;
