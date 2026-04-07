import { generate, PostgresDialect } from 'kysely-codegen';
import db from './db';

await generate({
  db,
  dialect: new PostgresDialect(),
  camelCase: true,
  outFile: 'db/types.d.ts',
});

await db.destroy();
console.log('Kysely code generated for client');
