module Expr = QueryBuilder_Expr
module GroupBy = QueryBuilder_GroupBy
module OrderBy = QueryBuilder_OrderBy
module Agg = QueryBuilder_Agg

module Insert = {
  include QueryBuilder_Insert
  include SQLBuilder_Insert
}

module Update = {
  include QueryBuilder_Update
  include SQLBuilder_Update
}

module Delete = {
  include QueryBuilder_Delete
  include SQLBuilder_Delete
}

module Select = {
  include QueryBuilder_Select
  include SQLBuilder_Select
}
