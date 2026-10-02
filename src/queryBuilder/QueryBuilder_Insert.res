type t<'columns> = {
  tableName: string,
  columns: 'columns,
}

type conflictAction = | Nothing | Update

type tx<'columns> = {
  tableName: string,
  columns: 'columns,
  values: array<'columns>,
  onConflict: option<conflictAction>,
}

let insertInto = (table: Table.t<_, _, 'insert, _>): t<'insert> => {
  tableName: table.name,
  columns: Obj.magic(table.columns),
}

let values = (q: t<_>, values) => {
  tableName: q.tableName,
  columns: q.columns,
  values,
  onConflict: None,
}

let onConflict = (q: tx<_>, conflictAction) => {
  ...q,
  onConflict: Some(conflictAction),
}
