import { generate, PostgresDialect } from 'kysely-codegen';
import db from './kysely';

await generate({
  db,
  dialect: new PostgresDialect(),
  outFile: 'src/kysely/db.d.ts',
});

await db.destroy();
console.log('Kysely code generated for client');
