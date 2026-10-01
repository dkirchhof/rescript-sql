type t<'projection> = {
  from: QueryBuilder_Source.t,
  joins: array<QueryBuilder_Join.t>,
  where: option<QueryBuilder_Expr.t>,
  groupBy: array<QueryBuilder_GroupBy.t>,
  having: option<QueryBuilder_Expr.t>,
  orderBy: array<QueryBuilder_OrderBy.t>,
  limit: option<Unknown.t>,
  offset: option<Unknown.t>,
  projection: 'projection,
}
