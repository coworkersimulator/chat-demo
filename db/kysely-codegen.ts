import { generate, PostgresDialect } from 'kysely-codegen';
import db from './db';

await generate({
  db,
  dialect: new PostgresDialect(),
  outFile: 'src/db/types.d.ts',
});

await generate({
  db,
  dialect: new PostgresDialect(),
  outFile: 'db/types.d.ts',
});

await db.destroy();
console.log('Kysely code generated for client');
