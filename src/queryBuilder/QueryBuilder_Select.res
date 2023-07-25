type t<'a, 'b> = {
  from: QueryBuilder_Source.t,
  joins: array<QueryBuilder_Join.t>,
  where: option<QueryBuilder_Expr.t>,
  groupBy: array<QueryBuilder_GroupBy.t>,
  having: option<QueryBuilder_Expr.t>,
  orderBy: array<QueryBuilder_OrderBy.t>,
  limit: option<int>,
  offset: option<int>,
  _projectables: 'a,
  _selectables: 'b,
}

type columns3<'a, 'b, 'c> = {
  t1: 'a,
  t2: 'b,
  t3: 'c,
}

type columns2<'a, 'b> = {
  t1: 'a,
  t2: 'b,
}

let from = (table: Table.t<'columns, _, _>): t<'columns, 'columns> => {
  from: {name: table.name, alias: None},
  joins: [],
  where: None,
  groupBy: [],
  having: None,
  orderBy: [],
  limit: None,
  offset: None,
  _projectables: table.columns,
  _selectables: table.columns,
}

let _join1 = (q, table: Table.t<_>, getOn, joinType, _projectables) => {
  let _selectables = {
    t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._selectables, "t1"),
    t2: QueryBuilder_Utils.getColumnsWithTableAlias(table.columns, "t2"),
  }

  {
    ...q,
    from: {
      ...q.from,
      alias: Some("t1"),
    },
    joins: [
      {
        table: {
          name: table.name,
          alias: Some("t2"),
        },
        joinType,
        on: getOn(_selectables),
      },
    ],
    _projectables,
    _selectables,
  }
}

let innerJoin1 = (q: t<'p1, 's1>, table: Table.t<'columns, _, _>, getOn): t<
  columns2<'p1, 'columns>,
  columns2<'s1, 'columns>,
> =>
  _join1(
    q,
    table,
    getOn,
    INNER,
    {
      t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: QueryBuilder_Utils.getColumnsWithTableAlias(table.columns, "t2"),
    },
  )

let leftJoin1 = (q: t<'p1, 's1>, table: Table.t<'columns, _, _>, getOn): t<
  columns2<'p1, option<'columns>>,
  columns2<'s1, 'columns>,
> =>
  _join1(
    q,
    table,
    getOn,
    LEFT,
    {
      t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: Some(QueryBuilder_Utils.getColumnsWithTableAlias(table.columns, "t2")),
    },
  )

let where = (q, getWhere) => {
  ...q,
  where: q._selectables->getWhere->Some,
}

let groupBy = (q, getGroupBy) => {
  ...q,
  groupBy: getGroupBy(q._selectables),
}

let having = (q, getHaving) => {
  ...q,
  having: q._selectables->getHaving->Some,
}

let orderBy = (q, getOrderBy) => {
  ...q,
  orderBy: getOrderBy(q._selectables),
}

let limit = (q, limit) => {
  ...q,
  limit: Some(limit),
}

let offset = (q, offset) => {
  ...q,
  offset: Some(offset),
}

let selectAll = q => {
  QueryBuilder_Select_Executable.from: q.from,
  joins: q.joins,
  where: q.where,
  groupBy: q.groupBy,
  having: q.having,
  orderBy: q.orderBy,
  limit: q.limit,
  offset: q.offset,
  projection: q._projectables->QueryBuilder_Utils.ensureNodes,
}

let select = (q, getProjection: 'a => {..}) => {
  QueryBuilder_Select_Executable.from: q.from,
  joins: q.joins,
  where: q.where,
  groupBy: q.groupBy,
  having: q.having,
  orderBy: q.orderBy,
  limit: q.limit,
  offset: q.offset,
  projection: q._projectables->getProjection->QueryBuilder_Utils.ensureNodes,
}

let selectAsSubquery = (q, getProjection: _ => {"value": 'value}): 'value =>
  {
    QueryBuilder_Select_Executable.from: q.from,
    joins: q.joins,
    where: q.where,
    groupBy: q.groupBy,
    having: q.having,
    orderBy: q.orderBy,
    limit: q.limit,
    offset: q.offset,
    projection: q._projectables->getProjection->QueryBuilder_Utils.ensureNodes->Obj.magic,
  }
  ->Node.Subquery
  ->Obj.magic
