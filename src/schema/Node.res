type t = Column(Column.t)

let makeColumn = (column: Column.t) => Column(column)->Obj.magic
