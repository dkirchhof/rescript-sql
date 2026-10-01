let connection = BunSQLite.createConnection("sqlite://example/db.db")

let insertExample = async () => {
  open RescriptSQL.Insert

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
  ->values([
    {json: "{\"hello\": \"world\"}"},
  ])
  ->logAndExecute
}

let crudExample = async () => {
  let create = async () => {
    open RescriptSQL.Insert

    let query = insertInto(Schema.Artists.table)->values([{id: 100, name: "DELETEME", genre: Null}])
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  let read = async () => {
    open RescriptSQL.Select

    let query = from(Schema.Artists.table)->selectAll
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  let update = async () => {
    open RescriptSQL.Update
    open RescriptSQL.Expr

    let query = update(Schema.Artists.table)->set({name: "DELETEME!!!"})->where(c => eq(c.id, 100))
    let sql = toSQL(query)

    Console.log(sql.sql)
    Console.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    Logger.log(result)
  }

  let delete = async () => {
    open RescriptSQL.Delete
    open RescriptSQL.Expr

    let query = deleteFrom(Schema.Artists.table)->where(c => eq(c.id, 100))
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
  open RescriptSQL.Select
  open RescriptSQL.Expr
  open RescriptSQL.Literal
  open RescriptSQL.GroupBy
  open RescriptSQL.OrderBy
  open! RescriptSQL.Agg
  open RescriptSQL.JSON

  let logAndExecute = async query => {
    let sql = toSQL(query)

    Logger.log(sql.sql)
    Logger.log(sql.params)

    let result = await BunSQLite.exec(connection, sql.sql, sql.params)

    // Logger.log(result)

    let mappedResult = Array.map(result, row => ResultMapper.map(query, row))

    Logger.log(mappedResult)
  }

  // await from(Schema.Artists.table)->selectAll->logAndExecute

  // await from(Schema.Artists.table)
  // ->where(_ => like(Node.makeColumn({name: "name"}), "%Artist%"))
  // ->selectAll
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->where(c => eq(c.id, 1))
  // ->select(c =>
  //   {
  //     "name": c.name,
  //     "someNumber": 1,
  //     "someString": "hello world",
  //     "someBoolean": true,
  //   }
  // )
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->select(c => {"a": {"c": c.name, "d": 1, "e": {"someBoolean": true}}})
  // ->logAndExecute

  // await from(Schema.Artists.table)->select(c => {"count": count(c.id)})->logAndExecute
  // await from(Schema.Artists.table)->select(c => {"sum": sum(c.id)})->logAndExecute
  // await from(Schema.Artists.table)->select(c => {"avg": avg(c.id)})->logAndExecute
  // await from(Schema.Artists.table)->select(c => {"min": min(c.id)})->logAndExecute
  // await from(Schema.Artists.table)->select(c => {"max": max(c.id)})->logAndExecute

  // await from(Schema.Artists.table)
  // ->innerJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->selectAll
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->innerJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->select(c => {"artistName": c.t1.name, "songName": c.t2.name})
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->innerJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->select(c => {"artist": {"name": c.t1.name}, "song": {"name": c.t2.name}})
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->leftJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->selectAll
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->leftJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->select(c => {"artistName": c.t1.name, "songName": c.t2.name})
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->leftJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->select(c => {"artist": {"name": c.t1.name}, "song": {"name": c.t2.name}})
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->where(c => eq(c.id, 1))
  // ->groupBy(c => [group(c.id), group(c.name)])
  // ->having(c => eq(c.id, 1))
  // ->orderBy(c => [asc(c.id), desc(c.name)])
  // ->limit(1)
  // ->offset(1)
  // ->selectAll
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->innerJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
  // ->where(c => eq(c.t1.id, 1))
  // ->groupBy(c => [group(c.t1.id), group(c.t2.name)])
  // ->having(c => eq(c.t1.id, 1))
  // ->orderBy(c => [asc(c.t1.id), desc(c.t2.name)])
  // ->limit(1)
  // ->offset(1)
  // ->selectAll
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->where(c =>
  //   and_([
  //     ne(c.id, c.id),
  //     between(c.id, 1, 2),
  //     or_([inArray(c.id, [1, 2, 3]), like(c.name, "%test%")]),
  //   ])
  // )
  // ->selectAll
  // ->logAndExecute

  // await from(Schema.Artists.table)
  // ->where(c => eq(c.id, from(Schema.Artists.table)->selectAsSubquery(d => {"value": d.id})))
  // ->selectAll
  // ->logAndExecute

  await from(Schema.Test.table)
  ->where(c => eq(jsonExtract(c.json, "$.hello"), String("world")))
  ->selectAll
  ->logAndExecute

  await from(Schema.Test.table)
  ->select(c => {"helloCount": count(jsonExtract(c.json, "$.hello"))})
  ->logAndExecute

  await from(Schema.Artists.table)
  ->where(c => eq(c.id, literal(1)))
  ->limit(literal(1))
  ->offset(literal(0))
  ->selectAll
  ->logAndExecute
}

await insertExample()
await crudExample()
await dql()

BunSQLite.close(connection)
