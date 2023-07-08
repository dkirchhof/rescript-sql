open SchemaBuilder

let artistsTable = table({
  moduleName: "Artists",
  tableName: "artists",
  columns: {
    "id": column({dbType: "INTEGER", resType: "int", skipInInsertQuery: true}),
    "name": column({dbType: "TEXT", resType: "string", size: 100}),
  },
  constraints: c =>
    {
      "pk": primaryKey({columns: [c["id"]]}),
      "uniq": unique({columns: [c["name"]]}),
    },
})

let songsTable = table({
  moduleName: "Songs",
  tableName: "songs",
  columns: {
    "id": column({dbType: "INTEGER", resType: "int", skipInInsertQuery: true}),
    "artistId": column({dbType: "INTEGER", resType: "int"}),
    "name": column({dbType: "TEXT", resType: "string", size: 100}),
  },
  constraints: c =>
    {
      "pk": primaryKey({columns: [c["id"]]}),
      "fkArtist": foreignKey({
        columns: [c["artistId"]],
        foreignTable: artistsTable,
        foreignColumns: c2 => [c2["id"]],
        onUpdate: NoAction,
        onDelete: Cascade,
      }),
    },
})
