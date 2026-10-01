type aggregation = Count | Sum | Avg | Min | Max

type rec t<'a> =
  | ProjectionGroup(Dict.t<Unknown.t>)
  | Column(Column.t)
  | Subquery(QueryBuilder_Select_Executable.t<'a>)
  | Value(unknown)
  | Aggregate(aggregation, Unknown.t)
  | JsonExtract(Unknown.t, string)

external fromUnknown: Unknown.t => t<_> = "%identity"

let makeColumn = (column: Column.t) => Column(column)->Obj.magic
let makeSubquery = (subquery: QueryBuilder_Select_Executable.t<_>) => Subquery(subquery)->Obj.magic
