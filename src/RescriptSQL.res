module type SyncAdapter = {
  type connection

  let execute: (connection, string) => unit
  let getRows: (connection, string) => array<'row>
}

module MakeSync = (SyncAdapter: SyncAdapter) => {
  module Expr = QueryBuilder_Expr
  module GroupBy = QueryBuilder_GroupBy
  module OrderBy = QueryBuilder_OrderBy

  module CreateTable = {
    include QueryBuilder_CreateTable
    include SQLBuilder_CreateTable

    let execute = (query, connection) => {
      let sql = SQLBuilder_CreateTable.toSQL(query)

      SyncAdapter.execute(connection, sql)
    }
  }

  module InsertInto = {
    include QueryBuilder_InsertInto
    include SQLBuilder_InsertInto

    let execute = (query, connection) => {
      let sql = SQLBuilder_InsertInto.toSQL(query)

      SyncAdapter.execute(connection, sql)
    }
  }

  module Select = {
    include QueryBuilder_Select
    include SQLBuilder_Select

    let execute = (query, connection) => {
      let sql = SQLBuilder_Select.toSQL(query)
      let rows = SyncAdapter.getRows(connection, sql)

      Array.map(rows, row => ResultMapper.map(query.projection, row))
    }
  }
}
