open Select_Executable

let projectionToSQL = projection => {
  let projection = Obj.magic(projection)

  let fields =
    projection
    ->Dict.toArray
    ->Array.map(((alias, node)) => {
      let nodeAsSQL = SQL_Node.toSQL(node)

      if nodeAsSQL === alias {
        nodeAsSQL
      } else {
        `${nodeAsSQL} AS ${alias}`
      }
    })

  `SELECT ${Array.joinWith(fields, ", ")}`
}

let fromToSQL = source => {
  switch source.alias {
  | Some(alias) => `FROM ${source.name} AS ${alias}`
  | None => `FROM ${source.name}`
  }
}

external joinTypeToString: JoinType.t => string = "%identity"

let joinsToSQL = (joins: array<join>) => {
  joins->Array.map(join => {
    open StringBuilder

    make()
    ->addS(0, joinTypeToString(join.joinType))
    ->addS(0, "JOIN")
    ->addS(0, join.table.name)
    ->addSO(0, join.table.alias->Option.map(alias => `AS ${alias}`))
    ->addS(0, "ON")
    ->addS(0, SQL_Expr.toSQL(join.on))
    ->build(" ")
  })
}

let whereToSQL = where => {
  where->Option.map(expr => `WHERE ${SQL_Expr.toSQL(expr)}`)
}

let toSQL = q => {
  open StringBuilder

  make()
  ->addS(0, projectionToSQL(q.projection))
  ->addS(0, fromToSQL(q.from))
  ->addM(0, joinsToSQL(q.joins))
  ->addSO(0, whereToSQL(q.where))
  // ->addSO(0, groupByToSQL(q.groupBy))
  // ->addSO(0, havingToSQL(q.having))
  // ->addSO(0, orderByToSQL(q.orderBy))
  // ->addSO(0, limitToSQL(q.limit))
  // ->addSO(0, offsetToSQL(q.offset))
  ->build("\n")
}
