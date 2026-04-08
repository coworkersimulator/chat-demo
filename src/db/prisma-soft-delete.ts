import type { PrismaClient } from '@prisma/client/edge';

const READ_OPS = new Set(['findMany', 'findFirst', 'findFirstOrThrow', 'count', 'aggregate', 'groupBy']);

type OperationParams = {
  model: string;
  operation: string;
  args: Record<string, unknown>;
  query: (args: Record<string, unknown>) => Promise<unknown>;
};

export function softDeleteExtension(baseClient: PrismaClient) {
  return {
    query: {
      $allModels: {
        async $allOperations({ model, operation, args, query }: OperationParams): Promise<unknown> {
          if (READ_OPS.has(operation)) {
            args.where = { deletedAt: null, ...args.where as object };
            return query(args);
          }
          const m = (baseClient as unknown as Record<string, Record<string, (a: unknown) => unknown>>)[model];
          if (operation === 'delete') {
            return m.update({ where: args.where, data: { deletedAt: new Date() } });
          }
          if (operation === 'deleteMany') {
            return m.updateMany({ where: args.where, data: { deletedAt: new Date() } });
          }
          return query(args);
        },
      },
    },
  };
}
