type t<'columns, 'update> = {
  tableName: string,
  columns: 'columns,
}

type tx<'columns, 'update> = {
  tableName: string,
  columns: 'columns,
  patch: 'update,
  where: option<AST.predicate>,
}

let update = (table: Table.t<'columns, _, _, 'update>): t<'columns, 'update> => {
  tableName: table.name,
  columns: table.columns,
}

let set = (q: t<_, 'update>, patch: 'update) => {
  tableName: q.tableName,
  columns: q.columns,
  patch,
  where: None,
}

let setAll = (q: t<'columns, _>, patch: 'columns) => {
  tableName: q.tableName,
  columns: q.columns,
  patch,
  where: None,
}

let where = (q: tx<'columns, _>, getWhere) => {
  ...q,
  where: q.columns->getWhere->Some,
}
