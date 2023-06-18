type joinType = INNER | LEFT

type t = {
  table: QueryBuilder_Source.t,
  joinType,
  on: QueryBuilder_Expr.t,
}
