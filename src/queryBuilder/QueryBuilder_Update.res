type t<'columns, 'update> = {
  tableName: string,
  columns: 'columns,
}

type tx<'columns, 'update> = {
  tableName: string,
  columns: 'columns,
  patch: 'update,
  where: option<QueryBuilder_Expr.t>,
}

let update = (table: Table.t<'columns, _, 'update>): t<'columns, 'update> => {
  tableName: table.name,
  columns: table.columns,
}

let set = (q: t<_, 'update>, patch: 'update) => {
  tableName: q.tableName,
  columns: q.columns,
  patch,
  where: None,
}

let where = (q: tx<'columns, _>, getWhere) => {
  ...q,
  where: q.columns->getWhere->Some,
}
