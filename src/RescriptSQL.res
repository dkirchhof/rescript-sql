module type Result = {
  type result<'a>
}

module Adapter = (Result: Result) => {
  module type Adapter = {
    type connection

    let execute: (connection, string) => Result.result<unit>
    let getRows: (connection, string) => Result.result<array<'row>>
  }

  module Make = (Adapter: Adapter) => {
    module Expr = QueryBuilder_Expr
    module GroupBy = QueryBuilder_GroupBy
    module OrderBy = QueryBuilder_OrderBy
    module Agg = QueryBuilder_Agg

    module InsertInto = {
      include QueryBuilder_InsertInto
      include SQLBuilder_InsertInto

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
      include QueryBuilder_DeleteFrom
      include SQLBuilder_DeleteFrom

      let execute = (query, connection) => {
        let sql = toSQL(query)

        Adapter.execute(connection, sql)
      }
    }

    module Select = {
      include QueryBuilder_Select
      include SQLBuilder_Select

      let execute = (query, connection) => {
        let sql = toSQL(query)
        let rows = Adapter.getRows(connection, sql)

        Array.map(rows, row => ResultMapper.map(query.projection, row))
      }
    }
  }
}

module SyncAdapter = Adapter({
  type result<'a> = 'a
})

module AsyncAdapter = Adapter({
  type result<'a> = promise<'a>
})

module DB = SyncAdapter.Make({
  type connection

  let execute = Obj.magic()
  let getRows = (connection, sql) => Obj.magic()
})

module DB2 = AsyncAdapter.Make({
  type connection

  let execute = Obj.magic()
  let getRows = Obj.magic()
})

DB.test()
DB2.test()

module type Adapter = {
  type connection

  let execute: (connection, string) => unit
  let getRows: (connection, string) => array<'row>
}

module MakeSync = (Adapter: Adapter) => {
  module Expr = QueryBuilder_Expr
  module GroupBy = QueryBuilder_GroupBy
  module OrderBy = QueryBuilder_OrderBy
  module Agg = QueryBuilder_Agg

  module InsertInto = {
    include QueryBuilder_InsertInto
    include SQLBuilder_InsertInto

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
    include QueryBuilder_DeleteFrom
    include SQLBuilder_DeleteFrom

    let execute = (query, connection) => {
      let sql = toSQL(query)

      Adapter.execute(connection, sql)
    }
  }

  module Select = {
    include QueryBuilder_Select
    include SQLBuilder_Select

    let execute = (query, connection) => {
      let sql = toSQL(query)
      let rows = Adapter.getRows(connection, sql)

      Array.map(rows, row => ResultMapper.map(query.projection, row))
    }
  }
}
