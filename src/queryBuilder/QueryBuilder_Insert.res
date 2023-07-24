type t<'columns> = {
  tableName: string,
  columns: 'columns,
}

type tx<'columns> = {
  tableName: string,
  columns: 'columns,
  values: array<'columns>,
}

let insertInto = (table: Table.t<_, 'insert, _>): t<'insert> => {
  tableName: table.name,
  columns: Obj.magic(table.columns),
}

let values = (q: t<_>, values) => {
  tableName: q.tableName,
  columns: q.columns,
  values,
}
