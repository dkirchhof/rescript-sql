let getColumnsWithTableAlias = (columns: 'a, tableAlias): 'a => {
  let columns: Dict.t<Node.t<_>> = Obj.magic(columns)

  columns
  ->Dict.toArray
  ->Array.map(((columnName, column)) => {
    switch column {
    | Column(column) => (columnName, Node.Column({...column, tableAlias}))
    | _ => panic("only available for columns")
    }
  })
  ->Dict.fromArray
  ->Obj.magic
}
