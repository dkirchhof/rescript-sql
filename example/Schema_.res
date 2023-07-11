open SchemaBuilder

let artistsTable = table({
  moduleName: "Artists",
  tableName: "artists",
  columns: {
    "id": integerColumn({skipInInsertQuery: true}),
    "name": textColumn({size: 100}),
    "genre": textColumn({size: 100, nullable: true}),
  },
  constraints: c =>
    {
      "pk": primaryKey({columns: [c["id"]]}),
      "uniq": unique({columns: [c["name"]]}),
    },
})

let songsTable = tableWithoutConstraints({
  moduleName: "Songs",
  tableName: "songs",
  columns: {
    "id": integerColumn({skipInInsertQuery: true}),
    "artistId": integerColumn({}),
    "name": textColumn({size: 100}),
  },
  // constraints: c => 
    // {
    //   "pk": primaryKey({columns: [c["id"]]}),
    //   "fkArtist": foreignKey({
    //     columns: [c["artistId"]],
    //     foreignTable: artistsTable,
    //     foreignColumns: c2 => [c2["id"]],
    //     onUpdate: NoAction,
    //     onDelete: Cascade,
    //   }),
    // },
})
