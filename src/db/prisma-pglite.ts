import type { PGlite } from '@electric-sql/pglite';
import { PrismaClient } from '@prisma/client/edge';
import type { SqlMigrationAwareDriverAdapterFactory } from '@prisma/driver-adapter-utils';
import { PrismaPGlite } from 'pglite-prisma-adapter';
import { softDeleteExtension } from './prisma-soft-delete';

export function createPrismaPglite(pgliteWorker: PGlite, getUserId: () => string) {
  const factory = new PrismaPGlite(pgliteWorker);
  const adapter: SqlMigrationAwareDriverAdapterFactory = {
    provider: factory.provider,
    adapterName: factory.adapterName,
    async connect() {
      const conn = await factory.connect();
      const origStartTransaction = conn.startTransaction.bind(conn);
      conn.startTransaction = async (
        isolationLevel?: Parameters<typeof origStartTransaction>[0],
      ) => {
        const tx = await origStartTransaction(isolationLevel);
        const userId = getUserId();
        if (userId) {
          await tx.executeRaw({
            sql: `SET LOCAL app.user_id = '${userId}'`,
            args: [],
            argTypes: [],
          });
        }
        return tx;
      };
      return conn;
    },
    connectToShadowDb: () => factory.connectToShadowDb(),
  };
  const base = new PrismaClient({ adapter });
  return base.$extends(softDeleteExtension(base));
}
