type t<'a, 'b> = {
  ...AST.selectQuery,
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

let from = (table: Table.t<'columns, _, _, _>): t<'columns, 'columns> => {
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

let innerJoin1 = (q: t<'p1, 's1>, table: Table.t<'columns, _, _, _>, getOn): t<
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

let leftJoin1 = (q: t<'p1, 's1>, table: Table.t<'columns, 'nullColumns, _, _>, getOn): t<
  columns2<'p1, 'nullColumns>,
  columns2<'s1, 'columns>,
> =>
  _join1(
    q,
    table,
    getOn,
    LEFT,
    {
      t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: QueryBuilder_Utils.getColumnsWithTableAlias(Obj.magic(table.columns), "t2"),
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

let limit = (q, limit: int) => {
  ...q,
  limit: Some(Node.normalize(limit)),
}

let offset = (q, offset: int) => {
  ...q,
  offset: Some(Node.normalize(offset)),
}

let finalize = (q: t<_, _>, projection: 'result): QueryBuilder_Select_Executable.t<'result> => {
  ast: {
    selectQuery: {
      from: q.from,
      joins: q.joins,
      where: q.where,
      groupBy: q.groupBy,
      having: q.having,
      orderBy: q.orderBy,
      limit: q.limit,
      offset: q.offset,
    },
    projection: Projection.normalize(projection),
  },
}

let selectAll = (q: t<'projectables, _>): QueryBuilder_Select_Executable.t<'projectables> => {
  finalize(q, q._projectables)
}

let select = (
  q: t<'projectables, _>,
  getProjection: 'projectables => ({..} as 'projection),
): QueryBuilder_Select_Executable.t<'projection> => {
  finalize(q, getProjection(q._projectables))
}

let selectAsSubquery = (q, getProjection: _ => {"value": 'value}): 'value => {
  finalize(q, getProjection(q._projectables))->Node.makeSubquery
}
