type t<'a> = {
  tableName: string,
  columns: 'a
}

let createTable = (table: Table.t<_>) => {tableName: table.name, columns: table.select}
