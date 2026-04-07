import type {
  ComparisonOperatorExpression,
  OperandValueExpressionOrList,
  ReferenceExpression,
  SelectQueryBuilder,
  SelectQueryBuilderWithInnerJoin,
} from 'kysely';
import type { Note, Tag } from './types';

type WithAlias<DB, A extends string, T> = DB & { [K in A]: T };

// toTag(qb, 't1', 't1.name', '=', ':dm:') — with tag alias, default relation alias
export function toTag<
  DB extends { tag: Tag },
  TB extends keyof DB,
  O,
  A extends string,
  RE extends ReferenceExpression<WithAlias<DB, A, Tag>, TB | A>,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  alias: A,
  lhs: RE,
  op: ComparisonOperatorExpression,
  rhs: OperandValueExpressionOrList<WithAlias<DB, A, Tag>, TB | A, RE>,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, `tag as ${A}`>;

// toTag(qb, 't1', 't1.name', '=', ':dm:', 'r1') — with tag alias and explicit relation alias
export function toTag<
  DB extends { tag: Tag },
  TB extends keyof DB,
  O,
  A extends string,
  RE extends ReferenceExpression<WithAlias<DB, A, Tag>, TB | A>,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  alias: A,
  lhs: RE,
  op: ComparisonOperatorExpression,
  rhs: OperandValueExpressionOrList<WithAlias<DB, A, Tag>, TB | A, RE>,
  relationAlias: TB & string,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, `tag as ${A}`>;

// toTag(qb, 'tag.name', '=', ':dm:') — no alias, default relation alias
export function toTag<
  DB extends { tag: Tag },
  TB extends keyof DB,
  O,
  RE extends ReferenceExpression<DB, TB | 'tag'>,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  lhs: RE,
  op: ComparisonOperatorExpression,
  rhs: OperandValueExpressionOrList<DB, TB | 'tag', RE>,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, 'tag'>;

// toTag(qb, 'tag.name', '=', ':dm:', 'r1') — no alias, explicit relation alias
export function toTag<
  DB extends { tag: Tag },
  TB extends keyof DB,
  O,
  RE extends ReferenceExpression<DB, TB | 'tag'>,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  lhs: RE,
  op: ComparisonOperatorExpression,
  rhs: OperandValueExpressionOrList<DB, TB | 'tag', RE>,
  relationAlias: TB & string,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, 'tag'>;

export function toTag<
  DB extends { tag: Tag },
  TB extends keyof DB,
  O,
  A extends string,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  aliasOrLhs: A | ReferenceExpression<DB, TB>,
  opOrLhs: ComparisonOperatorExpression | ReferenceExpression<DB, TB>,
  rhsOrOp: ComparisonOperatorExpression | unknown,
  rhsOrRelation?: unknown,
  relationAlias = 'relation',
) {
  const hasAlias =
    typeof rhsOrRelation !== 'string' && rhsOrRelation !== undefined;
  const [table, refId, lhs, op, value, rel] = hasAlias
    ? [
        `tag as ${aliasOrLhs}`,
        `${aliasOrLhs}.id`,
        opOrLhs,
        rhsOrOp as ComparisonOperatorExpression,
        rhsOrRelation,
        relationAlias,
      ]
    : [
        'tag',
        'tag.id',
        aliasOrLhs,
        opOrLhs as ComparisonOperatorExpression,
        rhsOrOp,
        (rhsOrRelation as string) ?? relationAlias,
      ];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return qb.innerJoin(table as any, (join: any) =>
    join.onRef(refId, '=', `${rel}.toTagId`).on(lhs, op, value),
  );
}

// onNote(qb, 'n1', 'r1') — explicit relation alias
export function onNote<
  DB extends { note: Note },
  TB extends keyof DB,
  O,
  A extends string,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  alias: A,
  relationAlias: TB & string,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, `note as ${A}`>;

// onNote(qb) — no alias, joins as 'note'
export function onNote<DB extends { note: Note }, TB extends keyof DB, O>(
  qb: SelectQueryBuilder<DB, TB, O>,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, 'note'>;

// onNote(qb, 'n1') — explicit alias, default relation alias
export function onNote<
  DB extends { note: Note },
  TB extends keyof DB,
  O,
  A extends string,
>(
  qb: SelectQueryBuilder<DB, TB, O>,
  alias: A,
): SelectQueryBuilderWithInnerJoin<DB, TB, O, `note as ${A}`>;

export function onNote<
  DB extends { note: Note },
  TB extends keyof DB,
  O,
  A extends string,
>(qb: SelectQueryBuilder<DB, TB, O>, alias?: A, relationAlias = 'relation') {
  const table = alias ? `note as ${alias}` : 'note';
  const ref = alias ?? 'note';
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return qb.innerJoin(table as any, (join: any) =>
    join.onRef(`${ref}.id`, '=', `${relationAlias}.onNoteId`),
  );
}
