const READ_OPS = new Set(['findMany', 'findFirst', 'findFirstOrThrow', 'count', 'aggregate', 'groupBy']);

export function softDeleteExtension(baseClient: any) {
  return {
    query: {
      $allModels: {
        async $allOperations({ model, operation, args, query }: any): Promise<any> {
          if (READ_OPS.has(operation)) {
            args.where = { deletedAt: null, ...args.where };
            return query(args);
          }
          if (operation === 'delete') {
            return baseClient[model].update({ where: args.where, data: { deletedAt: new Date() } });
          }
          if (operation === 'deleteMany') {
            return baseClient[model].updateMany({ where: args.where, data: { deletedAt: new Date() } });
          }
          return query(args);
        },
      },
    },
  };
}
