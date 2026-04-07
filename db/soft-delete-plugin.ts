import {
  AndNode,
  BinaryOperationNode,
  ColumnNode,
  ColumnUpdateNode,
  OperationNodeTransformer,
  OperatorNode,
  RawNode,
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
  type UpdateQueryNode as UpdateQueryNodeType,
} from 'kysely';

function isNullFilter(tableAlias: string, column: string): OperationNode {
  return BinaryOperationNode.create(
    ReferenceNode.create(
      ColumnNode.create(column),
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
  readonly #column: string;

  constructor(column: string) {
    super();
    this.#column = column;
  }

  protected override transformUpdateQuery(node: UpdateQueryNodeType): UpdateQueryNodeType {
    node = super.transformUpdateQuery(node);
    if (!node.table) return node;
    const alias = tableAliasOf(node.table);
    if (!alias) return node;
    return { ...node, where: withWhere(node.where, isNullFilter(alias, this.#column)) };
  }

  protected override transformSelectQuery(node: SelectQueryNode): SelectQueryNode {
    node = super.transformSelectQuery(node);

    const aliases: string[] = [];

    if (node.from) {
      for (const from of node.from.froms) {
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
      where = withWhere(where, isNullFilter(alias, this.#column));
    }

    return { ...node, where };
  }
}

function softDeleteFromDelete(
  node: DeleteQueryNode,
  column: string,
): RootOperationNode {
  const fromItem = node.from?.froms[0] as OperationNode | undefined;
  if (!fromItem) return node;

  const alias = tableAliasOf(fromItem);
  if (!alias) return node;

  let updateNode = UpdateQueryNode.create([fromItem]);

  updateNode = UpdateQueryNode.cloneWithUpdates(updateNode, [
    ColumnUpdateNode.create(
      ColumnNode.create(column),
      RawNode.createWithSql('CURRENT_TIMESTAMP'),
    ),
  ]);

  const where = withWhere(node.where, isNullFilter(alias, column));
  return { ...updateNode, where };
}

export interface SoftDeletePluginOptions {
  deletedAtColumn?: string;
}

export class SoftDeletePlugin implements KyselyPlugin {
  readonly #column: string;
  readonly #transformer: SoftDeleteTransformer;

  constructor({ deletedAtColumn = 'deletedAt' }: SoftDeletePluginOptions = {}) {
    this.#column = deletedAtColumn;
    this.#transformer = new SoftDeleteTransformer(deletedAtColumn);
  }

  transformQuery(args: PluginTransformQueryArgs): RootOperationNode {
    if (args.node.kind === 'DeleteQueryNode') {
      return softDeleteFromDelete(args.node as DeleteQueryNode, this.#column);
    }
    return this.#transformer.transformNode(args.node);
  }

  async transformResult(
    args: PluginTransformResultArgs,
  ): Promise<QueryResult<UnknownRow>> {
    return args.result;
  }
}
