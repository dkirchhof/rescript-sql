// type singleColumnProjection<'a> = {value: 'a}

//   let toSubquery = (q: t<'p1, _, 'p2, _>, getProjection: columns<'p1, 'p2> => 'p): 'p =>
//     Node.makeSubquery({
//       from: {name: q.from.name, alias: q.from.alias},
//       joins: [
//         {
//           table: {
//             name: q.join.table.name,
//             alias: q.join.table.alias,
//           },
//           joinType: q.join.joinType,
//           on: q.join.on,
//         },
//       ],
//       where: q.where,
//       limit: q.limit,
//       offset: q.offset,
//       projection: {
//         value: {
//           t1: Obj.magic(q.from.columns),
//           t2: Obj.magic(q.join.table.columns),
//         }->getProjection,
//       },
//     })
// }

//   let toSubquery = (q: t<'p1, _>, getProjection: 'p1 => 'p): 'p =>
//     Node.makeSubquery({
//       from: {name: q.from.name, alias: q.from.alias},
//       joins: [],
//       where: q.where,
//       limit: q.limit,
//       offset: q.offset,
//       projection: {
//         value: q.from.columns->getProjection,
//       },
//     })
// }

type t<'a, 'b> = {
  from: Source.t,
  joins: array<Join.t>,
  where: option<Expr.t>,
  groupBy: array<GroupBy.t>,
  having: option<Expr.t>,
  orderBy: array<OrderBy.t>,
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

let from = (table: Table.t<_>) => {
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
    t1: Utils.getColumnsWithTableAlias(q._selectables, "t1"),
    t2: Utils.getColumnsWithTableAlias(table.columns, "t2"),
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

let innerJoin1 = (q, table, getOn) =>
  _join1(
    q,
    table,
    getOn,
    INNER,
    {
      t1: Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: Utils.getColumnsWithTableAlias(table.columns, "t2"),
    },
  )

let leftJoin1 = (q, table, getOn) =>
  _join1(
    q,
    table,
    getOn,
    LEFT,
    {
      t1: Utils.getColumnsWithTableAlias(q._projectables, "t1"),
      t2: Some(Utils.getColumnsWithTableAlias(table.columns, "t2")),
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
  Select_Executable.from: q.from,
  joins: q.joins,
  where: q.where,
  groupBy: q.groupBy,
  having: q.having,
  orderBy: q.orderBy,
  limit: q.limit,
  offset: q.offset,
  projection: q._projectables->Utils.ensureNodes,
}

let select = (q, getProjection) => {
  Select_Executable.from: q.from,
  joins: q.joins,
  where: q.where,
  groupBy: q.groupBy,
  having: q.having,
  orderBy: q.orderBy,
  limit: q.limit,
  offset: q.offset,
  projection: q._projectables->getProjection->Utils.ensureNodes,
}
