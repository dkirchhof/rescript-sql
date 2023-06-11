let mapColumns = (columns: 'a, fn): 'a => {
  let columns: Dict.t<Column.t> = Obj.magic(columns)

  columns
  ->Dict.toArray
  // ->Array.map(((columnName, column)) => (
  //   columnName,
  //   {
  //     ...column,
  //     tableAlias,
  //   },
  // ))
  ->Array.map(((columnName, column)) => (columnName, fn(column)))
  ->Dict.fromArray
  ->Obj.magic
}
