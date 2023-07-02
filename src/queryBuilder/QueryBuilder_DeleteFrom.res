type t<'columns> = {
  tableName: string,
  columns: 'columns,
  where: option<QueryBuilder_Expr.t>,
}

let deleteFrom = (table: Table.t<_>) => {
  tableName: table.name,
  columns: table.columns,
  where: None,
}

let where = (q, getWhere) => {
  ...q,
  where: q.columns->getWhere->Some,
}
