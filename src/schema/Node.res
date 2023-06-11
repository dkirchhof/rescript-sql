type t<'a> = Column(Column.t) | Subquery(Select_Executable.t<'a>)

let makeColumn = (column: Column.t) => Column(column)->Obj.magic
