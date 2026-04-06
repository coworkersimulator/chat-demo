import { Kysely } from 'kysely';
import { PGliteDialect } from 'kysely-pglite-dialect';
import { pglite } from './pglite';

const kysely = new Kysely<any>({ dialect: new PGliteDialect(pglite) });

export { kysely };

export default kysely;
