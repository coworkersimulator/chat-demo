import type { PGlite } from '@electric-sql/pglite';
import { PrismaClient } from '@prisma/client/edge';
import type { SqlMigrationAwareDriverAdapterFactory } from '@prisma/driver-adapter-utils';
import { PrismaPGlite } from 'pglite-prisma-adapter';
import { softDeleteExtension } from './prisma-soft-delete';

export function createPrismaPglite(
  pgliteWorker: PGlite,
  getUserId: () => string,
) {
  // The PGlite shared worker maintains a single PostgreSQL session shared
  // across all browser tabs. A plain SET app.user_id would be session-scoped
  // and is therefore a race condition — tab B can overwrite tab A's value
  // between the SET and the query it was meant to accompany.
  //
  // The fix: wrap every query in an explicit transaction and use SET LOCAL,
  // which scopes the value to the current transaction and reverts automatically
  // on commit or rollback. No other tab can see or clobber it mid-flight.
  //
  // Two interception points are needed because Prisma reaches PGlite through
  // two different code paths:
  //
  //   1. pgliteWorker.query  — used by the pglite-prisma-adapter's performIO
  //      for every plain model operation (findMany, create, update, …).
  //
  //   2. pgliteWorker.transaction — used by the adapter's startTransaction for
  //      explicit db.$transaction([...]) calls, where performIO then executes
  //      each statement against the in-progress transaction object directly and
  //      so bypasses the query patch above.
  //
  // origTransaction is captured before either patch is applied so the patches
  // can call the real implementation without recursing into each other.
  const origTransaction = pgliteWorker.transaction.bind(pgliteWorker);

  // SET LOCAL is only valid inside a transaction block, which is guaranteed by
  // the time this helper is called.
  const injectUserId = async (tx: { exec: (sql: string) => Promise<unknown> }) => {
    const userId = getUserId();
    if (userId) await tx.exec(`SET LOCAL app.user_id = '${userId}'`);
  };

  // PGlite's query and transaction are not declared on PGliteWorker's public
  // type surface, so we widen the type here to allow in-place patching.
  const w = pgliteWorker as unknown as {
    query: (sql: string, params?: unknown[], opts?: unknown) => Promise<unknown>;
    transaction: typeof pgliteWorker.transaction;
  };

  // Intercept path 1: every individual Prisma model operation.
  w.query = (sql, params, opts) =>
    origTransaction(async (tx) => {
      await injectUserId(tx);
      return tx.query(sql, params as never, opts as never);
    });

  // Intercept path 2: explicit db.$transaction([...]) blocks. SET LOCAL is
  // injected once at the start; all statements inside the block share it.
  w.transaction = <T>(callback: Parameters<PGlite['transaction']>[0]) =>
    origTransaction<T>(async (tx) => {
      await injectUserId(tx);
      return callback(tx) as Promise<T>;
    });

  // Build the Prisma client using a thin factory wrapper so the adapter type
  // satisfies Prisma's SqlMigrationAwareDriverAdapterFactory interface.
  const factory = new PrismaPGlite(pgliteWorker);
  const adapter: SqlMigrationAwareDriverAdapterFactory = {
    provider: factory.provider,
    adapterName: factory.adapterName,
    connect: () => factory.connect(),
    connectToShadowDb: () => factory.connectToShadowDb(),
  };
  const base = new PrismaClient({ adapter });
  return base.$extends(softDeleteExtension(base));
}
