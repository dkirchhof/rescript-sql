type t<'projection> = {
  from: Source.t,
  joins: array<Join.t>,
  where: option<Expr.t>,
  groupBy: array<GroupBy.t>,
  having: option<Expr.t>,
  orderBy: array<OrderBy.t>,
  limit: option<int>,
  offset: option<int>,
  projection: 'projection,
}
