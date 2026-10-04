type t<'a, 'b> = {
  ...AST.selectQuery,
  _projectables: 'a,
  _selectables: 'b,
}

type columns2<'a, 'b> = {
  t1: 'a,
  t2: 'b,
}

type columns3<'a, 'b, 'c> = {
  t1: 'a,
  t2: 'b,
  t3: 'c,
}

let from = (source: Source.t<'columns, _, _, _>): t<'columns, 'columns> => {
  from: {name: source.name, alias: None},
  joins: [],
  where: None,
  groupBy: [],
  having: None,
  orderBy: [],
  limit: None,
  offset: None,
  _projectables: source.columns,
  _selectables: source.columns,
}

let _join1 = (q, source: Source.t<_, _, _, _>, getOn, joinType, _projectables) => {
  let _selectables = {
    t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._selectables, "t1"),
    t2: QueryBuilder_Utils.getColumnsWithTableAlias(source.columns, "t2"),
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
          name: source.name,
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

let _join2 = (
  q: t<columns2<_>, columns2<_>>,
  source: Source.t<_, _, _, _>,
  getOn,
  joinType,
  _projectables,
) => {
  let _selectables = {
    t1: q._selectables.t1,
    t2: q._selectables.t2,
    t3: QueryBuilder_Utils.getColumnsWithTableAlias(source.columns, "t3"),
  }

  {
    ...q,
    joins: [
      ...q.joins,
      {
        table: {
          name: source.name,
          alias: Some("t3"),
        },
        joinType,
        on: getOn(_selectables),
      },
    ],
    _projectables,
    _selectables,
  }
}

let innerJoin1 = (q: t<'p1, 's1>, source: Source.t<'columns, _, _, _>, getOn): t<
  columns2<'p1, 'columns>,
  columns2<'s1, 'columns>,
> =>
  _join1(
    q,
    source,
    getOn,
    INNER,
    {
      t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: QueryBuilder_Utils.getColumnsWithTableAlias(source.columns, "t2"),
    },
  )

let innerJoin2 = (
  q: t<columns2<'p1, 'p2>, columns2<'s1, 's2>>,
  source: Source.t<'columns, _, _, _>,
  getOn,
): t<columns3<'p1, 'p2, 'columns>, columns3<'s1, 's2, 'columns>> =>
  _join2(
    q,
    source,
    getOn,
    INNER,
    {
      t1: q._projectables.t1,
      t2: q._projectables.t2,
      t3: QueryBuilder_Utils.getColumnsWithTableAlias(Obj.magic(source.columns), "t3"),
    },
  )

let leftJoin1 = (q: t<'p1, 's1>, source: Source.t<'columns, 'nullColumns, _, _>, getOn): t<
  columns2<'p1, 'nullColumns>,
  columns2<'s1, 'columns>,
> =>
  _join1(
    q,
    source,
    getOn,
    LEFT,
    {
      t1: QueryBuilder_Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: QueryBuilder_Utils.getColumnsWithTableAlias(Obj.magic(source.columns), "t2"),
    },
  )

let leftJoin2 = (
  q: t<columns2<'p1, 'p2>, columns2<'s1, 's2>>,
  source: Source.t<'columns, 'nullColumns, _, _>,
  getOn,
): t<columns3<'p1, 'p2, 'nullColumns>, columns3<'s1, 's2, 'columns>> =>
  _join2(
    q,
    source,
    getOn,
    LEFT,
    {
      t1: q._projectables.t1,
      t2: q._projectables.t2,
      t3: QueryBuilder_Utils.getColumnsWithTableAlias(Obj.magic(source.columns), "t3"),
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
  getProjection: 'projectables => 'projection,
): QueryBuilder_Select_Executable.t<'projection> => {
  finalize(q, getProjection(q._projectables))
}

let selectAsSubquery = (q, getProjection: _ => {"value": 'value}): 'value => {
  finalize(q, getProjection(q._projectables))->Node.makeSubquery
}
