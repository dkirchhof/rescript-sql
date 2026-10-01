type renderer<'insert, 'columns, 'update, 'deleteColumns> = {
  params: array<unknown>,
  renderSelect: (AST.selectEx, int) => string,
  renderInsert: QueryBuilder_Insert.tx<'insert> => string,
  renderUpdate: QueryBuilder_Update.tx<'columns, 'update> => string,
  renderDelete: QueryBuilder_Delete.t<'deleteColumns> => string,
}

let makeRenderer = () => {
  let params = []

  let param = value => {
    Array.push(params, Obj.magic(value))

    `$${params->Array.length->Int.toString}`
  }

  let fromToSQL = (source: QueryBuilder_Source.t) => {
    switch source.alias {
    | Some(alias) => `FROM ${source.name} AS ${alias}`
    | None => `FROM ${source.name}`
    }
  }

  let rec nodeToSQL = (node: Node.t) => {
    switch node {
    | Column(column) =>
      switch column.tableAlias {
      | Some(tableAlias) => `${tableAlias}.${column.name}`
      | None => column.name
      }
    | Aggregate(aggregation, operand) => {
        let operand = nodeToSQL(operand)
        let functionName = switch aggregation {
        | Avg => "AVG"
        | Count => "COUNT"
        | Max => "MAX"
        | Min => "MIN"
        | Sum => "SUM"
        }

        `${functionName}(${operand})`
      }
    | JsonExtract(operand, path) => {
        let operand = nodeToSQL(operand)
        let path = nodeToSQL(path)

        `(${operand} ->> ${path})`
      }
    | Value(value) => param(value)
    | Literal(value) => EscapeValues.escape(value)
    | Subquery(query) => `(\n${renderSelect(query, 2)}\n)`
    | ProjectionGroup(_) => panic("projection groups must be rendered as fields")
    }
  }
  and exprToSQL = (expr: QueryBuilder_Expr.t) => {
    let groupToSQL = (expressions, operator) => {
      let parts = expressions->Array.map(exprToSQL)->Array.join(` ${operator} `)

      `(${parts})`
    }

    let simpleExprToSQL = (left, right, operator) => {
      let left = nodeToSQL(left)
      let right = nodeToSQL(right)

      `${left} ${operator} ${right}`
    }

    let betweenExprToSQL = (left, min, max, operator) => {
      let left = nodeToSQL(left)
      let min = nodeToSQL(min)
      let max = nodeToSQL(max)

      `${left} ${operator} ${min} AND ${max}`
    }

    let inExprToSQL = (left, array, operator) => {
      let left = nodeToSQL(left)
      let array = array->Array.map(nodeToSQL)->Array.join(", ")

      `${left} ${operator} (${array})`
    }

    switch expr {
    | And(expressions) => groupToSQL(expressions, "AND")
    | Or(expressions) => groupToSQL(expressions, "OR")
    | Equal(left, right) => simpleExprToSQL(left, right, "=")
    | NotEqual(left, right) => simpleExprToSQL(left, right, "!=")
    | GreaterThan(left, right) => simpleExprToSQL(left, right, ">")
    | GreaterThanEqual(left, right) => simpleExprToSQL(left, right, ">=")
    | LessThan(left, right) => simpleExprToSQL(left, right, "<")
    | LessThanEqual(left, right) => simpleExprToSQL(left, right, "<=")
    | Between(left, min, max) => betweenExprToSQL(left, min, max, "BETWEEN")
    | NotBetween(left, min, max) => betweenExprToSQL(left, min, max, "NOT BETWEEN")
    | In(left, array) => inExprToSQL(left, array, "IN")
    | NotIn(left, array) => inExprToSQL(left, array, "NOT IN")
    | Like(left, right) => simpleExprToSQL(left, right, "LIKE")
    | NotLike(left, right) => simpleExprToSQL(left, right, "NOT LIKE")
    | ILike(left, right) => simpleExprToSQL(left, right, "ILIKE")
    | NotILike(left, right) => simpleExprToSQL(left, right, "NOT ILIKE")
    }
  }
  and clauseToSQL = (keyword: string, expression) => {
    expression->Option.map(expr => `${keyword} ${exprToSQL(expr)}`)
  }
  and whereToSQL = expression => clauseToSQL("WHERE", expression)
  and havingToSQL = expression => clauseToSQL("HAVING", expression)
  and projectionToSQL = (projection: Dict.t<Node.t>) => {
    let rec getFields = (projection: Dict.t<Node.t>, path) => {
      projection
      ->Dict.toArray
      ->Array.flatMap(((alias, node)) => {
        let fullAlias = `${path}${alias}`

        switch node {
        | ProjectionGroup(group) => getFields(group, `${fullAlias}.`)
        | _ => {
            let nodeAsSQL = nodeToSQL(node)

            if nodeAsSQL === alias {
              [nodeAsSQL]
            } else {
              [`${nodeAsSQL} AS "${fullAlias}"`]
            }
          }
        }
      })
    }

    let fields = getFields(projection, "")

    `SELECT ${Array.join(fields, ", ")}`
  }
  and joinsToSQL = (joins: array<QueryBuilder_Join.t>) => {
    joins->Array.map(join => {
      open StringBuilder

      make()
      ->addS(0, (join.joinType :> string))
      ->addS(0, "JOIN")
      ->addS(0, join.table.name)
      ->addSO(0, join.table.alias->Option.map(alias => `AS ${alias}`))
      ->addS(0, "ON")
      ->addS(0, exprToSQL(join.on))
      ->build(" ")
    })
  }
  and groupByToSQL = (groupBys: array<QueryBuilder_GroupBy.t>) => {
    switch groupBys {
    | [] => None
    | _ => {
        let parts = groupBys->Array.map(nodeToSQL)->Array.join(", ")

        Some(`GROUP BY ${parts}`)
      }
    }
  }
  and orderByToSQL = (orderBys: array<QueryBuilder_OrderBy.t>) => {
    switch orderBys {
    | [] => None
    | _ => {
        let parts =
          orderBys
          ->Array.map(orderBy => {
            let node = nodeToSQL(orderBy.node)
            let direction = (orderBy.direction :> string)

            `${node} ${direction}`
          })
          ->Array.join(", ")

        Some(`ORDER BY ${parts}`)
      }
    }
  }
  and renderSelect = (q: AST.selectEx, indentation) => {
    open StringBuilder

    let limitToSQL = limit => {
      limit->Option.map(l => `LIMIT ${nodeToSQL(l)}`)
    }

    let offsetToSQL = offset => {
      offset->Option.map(o => `OFFSET ${nodeToSQL(o)}`)
    }

    make()
    ->addS(indentation, projectionToSQL(q.projection))
    ->addS(indentation, fromToSQL(q.select.from))
    ->addM(indentation, joinsToSQL(q.select.joins))
    ->addSO(indentation, whereToSQL(q.select.where))
    ->addSO(indentation, groupByToSQL(q.select.groupBy))
    ->addSO(indentation, havingToSQL(q.select.having))
    ->addSO(indentation, orderByToSQL(q.select.orderBy))
    ->addSO(indentation, limitToSQL(q.select.limit))
    ->addSO(indentation, offsetToSQL(q.select.offset))
    ->build("\n")
  }

  let renderInsert = (q: QueryBuilder_Insert.tx<_>) => {
    open StringBuilder

    let columns = q.values[0]->Option.getOrThrow->Obj.magic->Dict.keysToArray->Array.join(", ")

    let rows = q.values->Array.map(row => {
      let columns = row->Obj.magic->Dict.valuesToArray->Array.map(param)->Array.join(", ")

      `(${columns})`
    })

    let values = make()->addM(2, rows)->build(",\n")

    make()
    ->addS(0, `INSERT INTO ${q.tableName}(${columns}) VALUES`)
    ->addS(0, values)
    ->build("\n")
  }

  let renderUpdate = (q: QueryBuilder_Update.tx<_>) => {
    open StringBuilder

    let patch =
      q.patch
      ->Obj.magic
      ->Dict.toArray
      ->Array.map(((columnName, value)) => `${columnName} = ${param(value)}`)
      ->Array.join(", ")

    make()
    ->addS(0, `UPDATE ${q.tableName}`)
    ->addS(0, `SET ${patch}`)
    ->addSO(0, whereToSQL(q.where))
    ->build("\n")
  }

  let renderDelete = (q: QueryBuilder_Delete.t<_>) => {
    open StringBuilder

    make()
    ->addS(0, `DELETE FROM ${q.tableName}`)
    ->addSO(0, whereToSQL(q.where))
    ->build("\n")
  }

  {params, renderSelect, renderInsert, renderUpdate, renderDelete}
}
