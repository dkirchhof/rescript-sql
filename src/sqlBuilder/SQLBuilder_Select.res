open QueryBuilder_Select_Executable

let projectionToSQL = projection => {
  let rec getFields = (projection, path) => {
    projection
    ->Dict.toArray
    ->Array.flatMap(((alias, node)) => {
      let node = Node.fromUnknown(node)
      let fullAlias = `${path}${alias}`

      switch node {
      | ProjectionGroup(group) => getFields(group, `${fullAlias}.`)
      | _ => {
          let nodeAsSQL = SQLBuilder_Node.toSQL(node)

          if nodeAsSQL === alias {
            [nodeAsSQL]
          } else {
            [`${nodeAsSQL} AS "${fullAlias}"`]
          }
        }
      }
    })
  }

  let fields = projection->Obj.magic->getFields("")

  `SELECT ${Array.joinWith(fields, ", ")}`
}

let fromToSQL = (source: QueryBuilder_Source.t) => {
  switch source.alias {
  | Some(alias) => `FROM ${source.name} AS ${alias}`
  | None => `FROM ${source.name}`
  }
}

let joinsToSQL = (joins: array<QueryBuilder_Join.t>) => {
  joins->Array.map(join => {
    open StringBuilder

    make()
    ->addS(0, join.joinType :> string)
    ->addS(0, "JOIN")
    ->addS(0, join.table.name)
    ->addSO(0, join.table.alias->Option.map(alias => `AS ${alias}`))
    ->addS(0, "ON")
    ->addS(0, SQLBuilder_Expr.toSQL(join.on))
    ->build(" ")
  })
}

let whereToSQL = where => {
  where->Option.map(expr => `WHERE ${SQLBuilder_Expr.toSQL(expr)}`)
}

let groupByToSQL = (groupBys: array<QueryBuilder_GroupBy.t>) => {
  switch groupBys {
  | [] => None
  | _ => {
      let parts = groupBys->Array.map(SQLBuilder_Unknown.toSQL)->Array.joinWith(", ")

      Some(`GROUP BY ${parts}`)
    }
  }
}

let havingToSQL = having => {
  having->Option.map(expr => `HAVING ${SQLBuilder_Expr.toSQL(expr)}`)
}

let orderByToSQL = (orderBys: array<QueryBuilder_OrderBy.t>) => {
  switch orderBys {
  | [] => None
  | _ => {
      let parts =
        orderBys
        ->Array.map(orderBy => {
          let node = SQLBuilder_Unknown.toSQL(orderBy.node)
          let direction = orderBy.direction :> string

          `${node} ${direction}`
        })
        ->Array.joinWith(", ")

      Some(`ORDER BY ${parts}`)
    }
  }
}

let limitToSQL = limit => {
  limit->Option.map(l => `LIMIT ${Int.toString(l)}`)
}

let offsetToSQL = offset => {
  offset->Option.map(o => `OFFSET ${Int.toString(o)}`)
}

let toSQL = q => {
  open StringBuilder

  make()
  ->addS(0, projectionToSQL(q.projection))
  ->addS(0, fromToSQL(q.from))
  ->addM(0, joinsToSQL(q.joins))
  ->addSO(0, whereToSQL(q.where))
  ->addSO(0, groupByToSQL(q.groupBy))
  ->addSO(0, havingToSQL(q.having))
  ->addSO(0, orderByToSQL(q.orderBy))
  ->addSO(0, limitToSQL(q.limit))
  ->addSO(0, offsetToSQL(q.offset))
  ->build("\n")
}
