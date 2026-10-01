open QueryBuilder_Select_Executable

let projectionToSQL = (projection, subqueryToSQL, params) => {
  let rec getFields = (projection, path) => {
    projection
    ->Dict.toArray
    ->Array.flatMap(((alias, node)) => {
      let node = Node.fromUnknown(node)
      let fullAlias = `${path}${alias}`

      switch node {
      | ProjectionGroup(group) => getFields(group, `${fullAlias}.`)
      | _ => {
          let nodeAsSQL = SQLBuilder_Node.toSQL(node, subqueryToSQL, params)

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

  `SELECT ${Array.join(fields, ", ")}`
}

let fromToSQL = (source: QueryBuilder_Source.t) => {
  switch source.alias {
  | Some(alias) => `FROM ${source.name} AS ${alias}`
  | None => `FROM ${source.name}`
  }
}

let joinsToSQL = (joins: array<QueryBuilder_Join.t>, subqueryToSQL, params) => {
  joins->Array.map(join => {
    open StringBuilder

    make()
    ->addS(0, (join.joinType :> string))
    ->addS(0, "JOIN")
    ->addS(0, join.table.name)
    ->addSO(0, join.table.alias->Option.map(alias => `AS ${alias}`))
    ->addS(0, "ON")
    ->addS(0, SQLBuilder_Expr.toSQL(join.on, subqueryToSQL, params))
    ->build(" ")
  })
}

let whereToSQL = (where, subqueryToSQL, params) => {
  where->Option.map(expr => `WHERE ${SQLBuilder_Expr.toSQL(expr, subqueryToSQL, params)}`)
}

let groupByToSQL = (groupBys: array<QueryBuilder_GroupBy.t>, subqueryToSQL, params) => {
  switch groupBys {
  | [] => None
  | _ => {
      let parts =
        groupBys->Array.map(SQLBuilder_Unknown.toSQL(subqueryToSQL, params))->Array.join(", ")

      Some(`GROUP BY ${parts}`)
    }
  }
}

let havingToSQL = (having, subqueryToSQL, params) => {
  having->Option.map(expr => `HAVING ${SQLBuilder_Expr.toSQL(expr, subqueryToSQL, params)}`)
}

let orderByToSQL = (orderBys: array<QueryBuilder_OrderBy.t>, subqueryToSQL, params) => {
  switch orderBys {
  | [] => None
  | _ => {
      let parts =
        orderBys
        ->Array.map(orderBy => {
          let node = SQLBuilder_Unknown.toSQL(subqueryToSQL, params)(orderBy.node)
          let direction = (orderBy.direction :> string)

          `${node} ${direction}`
        })
        ->Array.join(", ")

      Some(`ORDER BY ${parts}`)
    }
  }
}

let rec toSQLWithIndentation = (q, params, indentation) => {
  open StringBuilder

  let operandToSQL = SQLBuilder_Unknown.toSQL(subqueryToSQL, params)

  let limitToSQL = limit => {
    limit->Option.map(l => `LIMIT ${operandToSQL(l)}`)
  }

  let offsetToSQL = offset => {
    offset->Option.map(o => `OFFSET ${operandToSQL(o)}`)
  }

  make()
  ->addS(indentation, projectionToSQL(q.projection, subqueryToSQL, params))
  ->addS(indentation, fromToSQL(q.from))
  ->addM(indentation, joinsToSQL(q.joins, subqueryToSQL, params))
  ->addSO(indentation, whereToSQL(q.where, subqueryToSQL, params))
  ->addSO(indentation, groupByToSQL(q.groupBy, subqueryToSQL, params))
  ->addSO(indentation, havingToSQL(q.having, subqueryToSQL, params))
  ->addSO(indentation, orderByToSQL(q.orderBy, subqueryToSQL, params))
  ->addSO(indentation, limitToSQL(q.limit))
  ->addSO(indentation, offsetToSQL(q.offset))
  ->build("\n")
}
and subqueryToSQL = (q, params) => `(\n${toSQLWithIndentation(q, params, 2)}\n)`

let toSQL = (q: t<_>): SQLBuilder_SQL.t => {
  let params = []

  let sql = toSQLWithIndentation(q, params, 0)

  {sql, params}
}
