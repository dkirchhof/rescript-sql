type rec t<'a> =
  | ProjectionGroup(Dict.t<Unknown.t>)
  | Column(Column.t)
  | Subquery(Select_Executable.t<'a>)
  | StringLiteral(string)
  | NumberLiteral(float)
  | BooleanLiteral(bool)

external fromUnknown: Unknown.t => t<_> = "%identity"

let makeColumn = (column: Column.t) => Column(column)->Obj.magic
let makeSubquery = (subquery: Select_Executable.t<_>) => Subquery(subquery)->Obj.magic
