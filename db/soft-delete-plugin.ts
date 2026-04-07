import {
  AndNode,
  BinaryOperationNode,
  ColumnNode,
  ColumnUpdateNode,
  FunctionNode,
  OperationNodeTransformer,
  OperatorNode,
  ReferenceNode,
  TableNode,
  UpdateQueryNode,
  ValueNode,
  WhereNode,
  type AliasNode,
  type DeleteQueryNode,
  type IdentifierNode,
  type KyselyPlugin,
  type OperationNode,
  type PluginTransformQueryArgs,
  type PluginTransformResultArgs,
  type QueryResult,
  type RootOperationNode,
  type SelectQueryNode,
  type UnknownRow,
} from 'kysely';

function isNullFilter(tableAlias: string): OperationNode {
  return BinaryOperationNode.create(
    ReferenceNode.create(
      ColumnNode.create('deletedAt'),
      TableNode.create(tableAlias),
    ),
    OperatorNode.create('is'),
    ValueNode.createImmediate(null),
  );
}

function withWhere(
  where: WhereNode | undefined,
  condition: OperationNode,
): WhereNode {
  if (!where) return WhereNode.create(condition);
  return WhereNode.create(AndNode.create(where.where, condition));
}

function tableAliasOf(node: OperationNode): string | null {
  if (node.kind === 'TableNode') {
    return (node as TableNode).table.identifier.name;
  }
  if (node.kind === 'AliasNode') {
    const { node: inner, alias } = node as AliasNode;
    if (inner.kind !== 'TableNode') return null;
    return (alias as IdentifierNode).name;
  }
  return null;
}

class SoftDeleteTransformer extends OperationNodeTransformer {
  protected override transformSelectQuery(
    node: SelectQueryNode,
  ): SelectQueryNode {
    node = super.transformSelectQuery(node);

    const aliases: string[] = [];

    if (node.from) {
      const froms = Array.isArray(node.from.froms)
        ? node.from.froms
        : [node.from.froms];
      for (const from of froms) {
        const alias = tableAliasOf(from);
        if (alias) aliases.push(alias);
      }
    }

    if (node.joins) {
      for (const join of node.joins) {
        const alias = tableAliasOf(join.table);
        if (alias) aliases.push(alias);
      }
    }

    if (aliases.length === 0) return node;

    let where = node.where;
    for (const alias of aliases) {
      where = withWhere(where, isNullFilter(alias));
    }

    return { ...node, where };
  }
}

function softDeleteFromDelete(node: DeleteQueryNode): RootOperationNode {
  const froms = node.from?.froms;
  const tableNode = froms
    ? Array.isArray(froms)
      ? froms[0]
      : froms
    : undefined;

  if (!tableNode || tableNode.kind !== 'TableNode') return node;

  const name = (tableNode as TableNode).table.identifier.name;

  let updateNode = UpdateQueryNode.create(tableNode as TableNode, false);
  updateNode = UpdateQueryNode.cloneWithUpdates(updateNode, [
    ColumnUpdateNode.create(
      ColumnNode.create('deletedAt'),
      FunctionNode.create('now', []),
    ),
  ]);

  const where = withWhere(node.where, isNullFilter(name));
  return { ...updateNode, where };
}

export class SoftDeletePlugin implements KyselyPlugin {
  readonly #transformer = new SoftDeleteTransformer();

  transformQuery(args: PluginTransformQueryArgs): RootOperationNode {
    if (args.node.kind === 'DeleteQueryNode') {
      return softDeleteFromDelete(args.node as DeleteQueryNode);
    }
    return this.#transformer.transformNode(args.node);
  }

  async transformResult(
    args: PluginTransformResultArgs,
  ): Promise<QueryResult<UnknownRow>> {
    return args.result;
  }
}
