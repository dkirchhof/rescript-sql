type t<'select, 'update> = {
  tableName: string,
  columns: 'select,
}

type tx<'select, 'update> = {
  tableName: string,
  columns: 'select,
  patch: 'update,
  where: option<QueryBuilder_Expr.t>,
}

let update = (table: Table.t<'select, _, 'update>): t<'select, 'update> => {
  tableName: table.name,
  columns: table.select,
}

let set = (q: t<_, 'update>, patch: 'update) => {
  tableName: q.tableName,
  columns: q.columns,
  patch,
  where: None,
}

let where = (q: tx<'select, _>, getWhere) => {
  ...q,
  where: q.columns->getWhere->Some,
}
