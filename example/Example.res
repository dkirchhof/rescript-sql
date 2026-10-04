let connection = BunSQLite.createConnection("sqlite://example/db.db")

let insertExample = async () => {
  open Insert

  let logAndExecute = async query => {
    let sql = toSQL(query)

    Logger.log(sql.sql)
    Logger.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  await insertInto(Schema.Artists.table)
  ->values([
    {name: "Artist 1", genre: Value("Rock")},
    {name: "Artist 2", genre: Null},
    {name: "Artist 3", genre: Null},
  ])
  ->logAndExecute

  await insertInto(Schema.Songs.table)
  ->values([
    {id: 11, artistId: 1, name: "Song 1_1"},
    {id: 12, artistId: 1, name: "Song 1_2"},
    {id: 13, artistId: 1, name: "Song 1_3"},
    {id: 21, artistId: 2, name: "Song 2_1"},
  ])
  ->logAndExecute

  await insertInto(Schema.Test.table)
  ->values([{json: "{\"hello\": \"world\"}"}])
  ->logAndExecute
}

let crudExample = async () => {
  let create = async () => {
    open Insert

    let query = insertInto(Schema.Artists.table)->values([{id: 100, name: "DELETEME", genre: Null}])
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  let read = async () => {
    open Select

    let query = from(Schema.Artists.table)->selectAll
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  let update = async () => {
    open Update

    let query = update(Schema.Artists.table)->set({name: "DELETEME!!!"})->where(a => eq(a.id, 100))
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  let delete = async () => {
    open Delete

    let query = deleteFrom(Schema.Artists.table)->where(a => eq(a.id, 100))
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  await create()
  await read()
  await update()
  await read()
  await delete()
  await read()
}

let dql = async () => {
  open! Select

  let logAndExecute = async query => {
    let sql = toSQL(query)

    Logger.log(sql.sql)
    Logger.log(sql.params)

    let rows = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(rows)

    let mappedResult = RowsMapper.mapRows(query, rows)

    Logger.log(mappedResult)
  }

  await from(Schema.Artists.table)->selectAll->logAndExecute

  await from(Schema.Artists.table)
  ->where(_ => like(Node.makeColumn({name: "name"}), "%Artist%"))
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->where(a => eq(a.id, 1))
  ->select(a =>
    {
      "name": a.name,
      "someNumber": 1,
      "someString": "hello world",
      "someBoolean": true,
    }
  )
  ->logAndExecute

  await from(Schema.Artists.table)
  ->select(a => {"a": {"c": a.name, "d": 1, "e": {"someBoolean": true}}})
  ->logAndExecute

  await from(Schema.Artists.table)->select(a => {"count": count(a.id)})->logAndExecute
  await from(Schema.Artists.table)->select(a => {"sum": sum(a.id)})->logAndExecute
  await from(Schema.Artists.table)->select(a => {"avg": avg(a.id)})->logAndExecute
  await from(Schema.Artists.table)->select(a => {"min": min(a.id)})->logAndExecute
  await from(Schema.Artists.table)->select(a => {"max": max(a.id)})->logAndExecute

  await from(Schema.Artists.table)
  ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->select(((a, s)) => {"artistName": a.name, "songName": s.name})
  ->logAndExecute

  await from(Schema.Artists.table)
  ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->select(((a, s)) => {"artist": {"name": a.name}, "song": {"name": s.name}})
  ->logAndExecute

  await from(Schema.Artists.table)
  ->leftJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->leftJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->select(((a, s)) => {"artistName": a.name, "songName": s.name})
  ->logAndExecute

  await from(Schema.Artists.table)
  ->leftJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->select(((a, s)) => {"artist": {"name": a.name}, "song": {"name": s.name}})
  ->logAndExecute

  await from(Schema.Artists.table)
  ->where(a => eq(a.id, 1))
  ->groupBy(a => [group(a.id), group(a.name)])
  ->having(a => eq(a.id, 1))
  ->orderBy(a => [asc(a.id), desc(a.name)])
  ->limit(1)
  ->offset(1)
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->where(((a, _s)) => eq(a.id, 1))
  ->groupBy(((a, s)) => [group(a.id), group(s.name)])
  ->having(((a, _s)) => eq(a.id, 1))
  ->orderBy(((a, s)) => [asc(a.id), desc(s.name)])
  ->limit(1)
  ->offset(1)
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->where(a =>
    and_([
      ne(a.id, a.id),
      between(a.id, 1, 2),
      or_([inArray(a.id, [1, 2, 3]), like(a.name, "%test%")]),
    ])
  )
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->where(a => eq(a.id, from(Schema.Artists.table)->selectAsSubquery(a2 => {"value": a2.id})))
  ->selectAll
  ->logAndExecute

  await from(Schema.Test.table)
  ->where(t => eq(jsonExtract(t.json, "$.hello"), String("world")))
  ->selectAll
  ->logAndExecute

  await from(Schema.Test.table)
  ->select(t => {"helloCount": count(jsonExtract(t.json, "$.hello"))})
  ->logAndExecute

  await from(Schema.Artists.table)
  ->where(a => eq(a.id, literal(1)))
  ->limit(literal(1))
  ->offset(literal(0))
  ->selectAll
  ->logAndExecute

  await from(Schema.Artists.table)
  ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
  ->innerJoin2(Schema.Artists.table, "a", ((_, s, a2)) => eq(a2.id, s.artistId))
  ->selectAll
  ->logAndExecute
}

await insertExample()
await crudExample()
await dql()

BunSQLite.close(connection)
