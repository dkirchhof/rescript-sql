type t<'projection> = {
  from: Source.t,
  joins: array<Join.t>,
  where: option<Expr.t>,
  orderBys: array<OrderBy.t>,
  limit: option<int>,
  offset: option<int>,
  projection: 'projection,
}
