type t<'columns> = {
  tableName: string,
  columns: 'columns,
}

type tx<'columns> = {
  tableName: string,
  columns: 'columns,
  values: array<'columns>,
}

let insertInto = (table: Table.t<_>) => {
  tableName: table.name,
  columns: table.insert,
}

let values = (q: t<_>, values) => {
  tableName: q.tableName,
  columns: q.columns,
  values,
}
