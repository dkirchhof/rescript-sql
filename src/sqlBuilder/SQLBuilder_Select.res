open QueryBuilder_Select_Executable

let projectionToSQL = (projection, subqueryToSQL) => {
  let rec getFields = (projection, path) => {
    projection
    ->Dict.toArray
    ->Array.flatMap(((alias, node)) => {
      let node = Node.fromUnknown(node)
      let fullAlias = `${path}${alias}`

      switch node {
      | ProjectionGroup(group) => getFields(group, `${fullAlias}.`)
      | _ => {
          let nodeAsSQL = SQLBuilder_Node.toSQL(node, subqueryToSQL)

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

let joinsToSQL = (joins: array<QueryBuilder_Join.t>, subqueryToSQL) => {
  joins->Array.map(join => {
    open StringBuilder

    make()
    ->addS(0, (join.joinType :> string))
    ->addS(0, "JOIN")
    ->addS(0, join.table.name)
    ->addSO(0, join.table.alias->Option.map(alias => `AS ${alias}`))
    ->addS(0, "ON")
    ->addS(0, SQLBuilder_Expr.toSQL(join.on, subqueryToSQL))
    ->build(" ")
  })
}

let whereToSQL = (where, subqueryToSQL) => {
  where->Option.map(expr => `WHERE ${SQLBuilder_Expr.toSQL(expr, subqueryToSQL)}`)
}

let groupByToSQL = (groupBys: array<QueryBuilder_GroupBy.t>, subqueryToSQL) => {
  switch groupBys {
  | [] => None
  | _ => {
      let parts =
        groupBys->Array.map(SQLBuilder_Unknown.toSQL(_, subqueryToSQL))->Array.joinWith(", ")

      Some(`GROUP BY ${parts}`)
    }
  }
}

let havingToSQL = (having, subqueryToSQL) => {
  having->Option.map(expr => `HAVING ${SQLBuilder_Expr.toSQL(expr, subqueryToSQL)}`)
}

let orderByToSQL = (orderBys: array<QueryBuilder_OrderBy.t>, subqueryToSQL) => {
  switch orderBys {
  | [] => None
  | _ => {
      let parts =
        orderBys
        ->Array.map(orderBy => {
          let node = SQLBuilder_Unknown.toSQL(orderBy.node, subqueryToSQL)
          let direction = (orderBy.direction :> string)

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

let rec toSQL = q => {
  toSQLWithIndentation(q, 0)
}
and toSQLWithIndentation = (q, indentation) => {
  open StringBuilder

  make()
  ->addS(indentation, projectionToSQL(q.projection, subqueryToSQL))
  ->addS(indentation, fromToSQL(q.from))
  ->addM(indentation, joinsToSQL(q.joins, subqueryToSQL))
  ->addSO(indentation, whereToSQL(q.where, subqueryToSQL))
  ->addSO(indentation, groupByToSQL(q.groupBy, subqueryToSQL))
  ->addSO(indentation, havingToSQL(q.having, subqueryToSQL))
  ->addSO(indentation, orderByToSQL(q.orderBy, subqueryToSQL))
  ->addSO(indentation, limitToSQL(q.limit))
  ->addSO(indentation, offsetToSQL(q.offset))
  ->build("\n")
}
and subqueryToSQL = q => `(\n${toSQLWithIndentation(q, 2)}\n)`
