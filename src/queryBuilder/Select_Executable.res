type source = {
  name: string,
  alias: option<string>,
}

type join = {
  table: source,
  joinType: JoinType.t,
  on: Expr.t,
}

type t<'projection> = {
  from: source,
  joins: array<join>,
  where: option<Expr.t>,
  projection: 'projection,
}
