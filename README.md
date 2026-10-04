# rescript-sql

Write typesafe sql queries in rescript for relational databases.

## Installation

1. Install the library:

```sh
# npm / yarn / pnpm / ...
$ npm install dkirchhof/rescript-sql
```

2. Add `rescript-sql` to your `rescript.json`:

```json
 {
   "bs-dependencies": [
+    "rescript-sql"
   ]
 }
```

## Usage

### 1. Create the schema:

```res
// src/Schema_.res
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

let songsTable = table({
  moduleName: "Songs",
  tableName: "songs",
  columns: {
    "id": integerColumn({skipInInsertQuery: true}),
    "artistId": integerColumn({}),
    "name": textColumn({size: 100}),
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

let artistNamesView = view({
  moduleName: "ArtistNames",
  viewName: "artistNames",
  columns: {
    "name": textColumn({}),
  },
  sql: "SELECT name FROM artists",
})
```

> [!TIP]
> For tables without constraints use `tableWithoutConstraints` instead of the `table` function.

### 2. Generate the sql script:

```sh
# rescript-sql <src>.[m]js <destination>.sql
$ npx rescript-sql src/Schema_.res.mjs src/Schema.sql
```

> [!IMPORTANT]
> You have to compile the src file before generating the sql script.

Example output:

```sql
-- src/Schema.sql

CREATE TABLE artists (
  id INTEGER NOT NULL,
  name TEXT(100) NOT NULL,
  genre TEXT(100),
  CONSTRAINT pk PRIMARY KEY (id),
  CONSTRAINT uniq UNIQUE (name)
);

CREATE TABLE songs (
  id INTEGER NOT NULL,
  artistId INTEGER NOT NULL,
  name TEXT(100) NOT NULL,
  CONSTRAINT pk PRIMARY KEY (id),
  CONSTRAINT fkArtist FOREIGN KEY (artistId) REFERENCES artists (id)
);

CREATE VIEW artistNames AS
SELECT name FROM artists;
```

### 3. Generate the res types:

```sh
# rescript-sql <src>.[m]js <destination>.res
$ npx rescript-sql src/Schema_.res.mjs src/Schema.res
```

> [!IMPORTANT]
> You have to compile the src file before generating the res file.

Example output:

```res
// src/Schema.res

open RescriptSQL

module Artists = {
  type columns = {
    id: int,
    name: string,
    genre: null<string>,
  }

  type nullColumns = {
    id: null<int>,
    name: null<string>,
    genre: null<string>,
  }

  type insert = {
    id?: int,
    name: string,
    genre: null<string>,
  }

  type update = {
    id?: int,
    name?: string,
    genre?: null<string>,
  }

  type t = Table.t<columns, nullColumns, insert, update>

  let table: t = {
    name: "artists",
    columns: Obj.magic({
      "id": Node.Column({name: "id"}),
      "name": Node.Column({name: "name"}),
      "genre": Node.Column({name: "genre"}),
    }),
  }
}

module Songs = {
  type columns = {
    id: int,
    artistId: int,
    name: string,
  }

  type nullColumns = {
    id: null<int>,
    artistId: null<int>,
    name: null<string>,
  }

  type insert = {
    id?: int,
    artistId: int,
    name: string,
  }

  type update = {
    id?: int,
    artistId?: int,
    name?: string,
  }

  type t = Table.t<columns, nullColumns, insert, update>

  let table: t = {
    name: "songs",
    columns: Obj.magic({
      "id": Node.Column({name: "id"}),
      "artistId": Node.Column({name: "artistId"}),
      "name": Node.Column({name: "name"}),
    }),
  }
}

module ArtistNames = {
  type columns = {
    name: string,
  }

  type nullColumns = {
    name: null<string>,
  }

  type t = View.t<columns, nullColumns>

  let view: t = {
    name: "artistNames",
    columns: Obj.magic({
      "name": Node.Column({name: "name"}),
    }),
  }
}
```

### 4. Create your queries:

Now you can use the query builder to generate typesafe queries.

```res
open RescriptSQL.Select

let query =
  from(Schema.Artists.table)
  ->innerJoin1(Schema.Songs.table, "song", ((artist, song)) => eq(song.artistId, artist.id))
  ->select(((artist, song)) => {"artistName": artist.name, "songName": song.name})
  ->toSQL


// query.sql

SELECT artists.name AS "artistName", song.name AS "songName"
FROM artists AS artists
INNER JOIN songs AS song ON song.artistId = artists.id

// query.params

[]
```

### 5. Use the resulting sql and params to get data from your database:

[!IMPORTANT]
> This library doesn't provide any bindings for databases. Use your own bindings to connect to your database and execute the queries.

```res
// exec and connection doesn't exist
let rows = await exec(connection, query.sql, query.params)

// result:

[
  { artistName: 'Artist 1', songName: 'Song 1_1' },
  { artistName: 'Artist 1', songName: 'Song 1_2' },
  { artistName: 'Artist 1', songName: 'Song 1_3' },
  { artistName: 'Artist 2', songName: 'Song 2_1' }
]
```

## Nested results

Joins will use aliases to avoid column name conflicts and to simplify further processing.
Use the `RowsMapper` utilities to create nested results from flat rows.

Example 1:

```res
let query =
  from(Schema.Artists.table)
    ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
    ->selectAll

let rows = await ...

// [
//   { '0.id': 1, '0.name': 'Artist 1', '0.genre': 'Rock', '1.id': 11, '1.artistId': 1, '1.name': 'Song 1_1' },
//   { '0.id': 1, '0.name': 'Artist 1', '0.genre': 'Rock', '1.id': 12, '1.artistId': 1, '1.name': 'Song 1_2' },
// ]

let result = RowsMapper.mapRows(query, rows)

// mapped row type = (Schema.Artists.columns, Schema.Songs.columns)

// [
//   {
//     '0': { id: 1, name: 'Artist 1', genre: 'Rock' },
//     '1': { id: 11, artistId: 1, name: 'Song 1_1' }
//   },
//   {
//     '0': { id: 1, name: 'Artist 1', genre: 'Rock' },
//     '1': { id: 12, artistId: 1, name: 'Song 1_2' }
//   }
// ]
```

Example 2:

```res
// let query =
//   from(Schema.Artists.table)
//     ->innerJoin1(Schema.Songs.table, "s", ((a, s)) => eq(s.artistId, a.id))
//     ->select(((a, s)) => {"artist": {"name": a.name}, "song": {"name": s.name}})
//     ->logAndExecute

let rows = await ...

// [
//   { 'artist.name': 'Artist 1', 'song.name': 'Song 1_1' },
//   { 'artist.name': 'Artist 1', 'song.name': 'Song 1_2' },
// ]

let result = RowsMapper.mapRows(query, rows)

// mapped row type = {"artist": {"name": string}, "song": {"name: string}}

[
  { artist: { name: 'Artist 1' }, song: { name: 'Song 1_1' } },
  { artist: { name: 'Artist 1' }, song: { name: 'Song 1_2' } },
]
```

## Examples
There is a full working example in the `example` folder.
Use the npm scripts to generate the schema files, create a sqlite db and run some predefined queries.
