import { generate, PostgresDialect } from 'kysely-codegen';
import { kysely as db } from './kysely';

await generate({
  db,
  dialect: new PostgresDialect(), // this is kysely-codegen's dialect, not Kysely's
  outFile: 'src/kysely/db.d.ts',
});

await db.destroy();
console.log('Kysely code generated for client');
