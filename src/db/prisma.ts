import { PrismaPGlite } from 'pglite-prisma-adapter';
import { PrismaClient } from '@prisma/client/edge';
import pglite from './pglite';

const adapter = new PrismaPGlite(pglite);
const baseClient = new PrismaClient({ adapter });

const READ_OPS = new Set(['findMany', 'findFirst', 'findFirstOrThrow', 'count', 'aggregate', 'groupBy']);

const prisma = baseClient.$extends({
  query: {
    $allModels: {
      async $allOperations({ model, operation, args, query }: any): Promise<any> {
        if (READ_OPS.has(operation)) {
          args.where = { deletedAt: null, ...args.where };
          return query(args);
        }
        if (operation === 'delete') {
          return (baseClient as any)[model].update({ where: args.where, data: { deletedAt: new Date() } });
        }
        if (operation === 'deleteMany') {
          return (baseClient as any)[model].updateMany({ where: args.where, data: { deletedAt: new Date() } });
        }
        return query(args);
      },
    },
  },
});

export { prisma };
export default prisma;
