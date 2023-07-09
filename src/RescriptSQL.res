module type SyncAdapter = {
  type connection

  let execute: (connection, string) => unit
  let getRows: (connection, string) => array<'row>
}

module MakeSync = (SyncAdapter: SyncAdapter) => {
  module Expr = QueryBuilder_Expr
  module GroupBy = QueryBuilder_GroupBy
  module OrderBy = QueryBuilder_OrderBy
  module Agg = QueryBuilder_Agg

  module InsertInto = {
    include QueryBuilder_InsertInto
    include SQLBuilder_InsertInto

    let execute = (query, connection) => {
      let sql = toSQL(query)

      SyncAdapter.execute(connection, sql)
    }
  }

  module Update = {
    include QueryBuilder_Update
    include SQLBuilder_Update

    let execute = (query, connection) => {
      let sql = toSQL(query)

      SyncAdapter.execute(connection, sql)
    }
  }

  module DeleteFrom = {
    include QueryBuilder_DeleteFrom
    include SQLBuilder_DeleteFrom

    let execute = (query, connection) => {
      let sql = toSQL(query)

      SyncAdapter.execute(connection, sql)
    }
  }

  module Select = {
    include QueryBuilder_Select
    include SQLBuilder_Select

    let execute = (query, connection) => {
      let sql = toSQL(query)
      let rows = SyncAdapter.getRows(connection, sql)

      Array.map(rows, row => ResultMapper.map(query.projection, row))
    }
  }
}
