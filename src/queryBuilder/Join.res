type joinType = INNER | LEFT

type t = {
  table: Source.t,
  joinType,
  on: Expr.t,
}
