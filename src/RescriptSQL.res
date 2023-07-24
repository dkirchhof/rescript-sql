module type Adapter = {
  type connection
  type error

  let execute: (connection, string) => AsyncResult.t<unit, error>
  let getRows: (connection, string) => AsyncResult.t<array<'row>, error>
}

module Make = (Adapter: Adapter) => {
  let execute = Adapter.execute
  let getRows = Adapter.getRows

  module Expr = QueryBuilder_Expr
  module GroupBy = QueryBuilder_GroupBy
  module OrderBy = QueryBuilder_OrderBy
  module Agg = QueryBuilder_Agg

  module InsertInto = {
    include QueryBuilder_Insert
    include SQLBuilder_Insert

    let execute = (query, connection) => {
      let sql = toSQL(query)

      Adapter.execute(connection, sql)
    }
  }

  module Update = {
    include QueryBuilder_Update
    include SQLBuilder_Update

    let execute = (query, connection) => {
      let sql = toSQL(query)

      Adapter.execute(connection, sql)
    }
  }

  module DeleteFrom = {
    include QueryBuilder_Delete
    include SQLBuilder_Delete

    let execute = (query, connection) => {
      let sql = toSQL(query)

      Adapter.execute(connection, sql)
    }
  }

  module Select = {
    include QueryBuilder_Select
    include SQLBuilder_Select

    let execute = (query: QueryBuilder_Select_Executable.t<'a>, connection): AsyncResult.t<array<'a>, Adapter.error> => {
      let sql = toSQL(query)
      let result = Adapter.getRows(connection, sql)

      result->AsyncResult.map(rows => Array.map(rows, row => ResultMapper.map(query.projection, row)))->Obj.magic
    }
  }
}
