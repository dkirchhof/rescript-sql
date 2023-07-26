# rescript-sql

Write typesafe sql queries in rescript for relational databases.

## Installation

1. Install the library:

```sh
# npm / yarn / pnpm / ...
$ npm install dkirchhof/rescript-sql

# install nodejs bindings for the database like better-sqlite3, pg or mysql2
```

2. Add `rescript-sql`, `rescript-async-result` and `@rescript/core` to your `bsconfig.json`:

```json
 {
   "bs-dependencies": [
+    "rescript-sql"
   ]
 }
```

## Usage

The usage of this library is splitted into four parts:

1. Use the schema builder dsl to define the schema of all tables.
2. Generate a sql script with the corresponding ddl queries.
3. Generate a res file with the corresponding rescript types.
4. Use the query builder dsl to create dql and dml queries.

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
```

> For tables without constraints use `tableWithoutConstraints` instead of the `table` function.

### 2. Generate the sql script:

```sh
# rescript-sql <src>.[m]js <destination>.sql
$ npx rescript-sql src/Schema_.mjs src/Schema.sql
```

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
```

### 3. Generate the res types:

```sh
# rescript-sql <src>.[m]js <destination>.res
$ npx rescript-sql src/Schema_.mjs src/Schema.res
```

> You have to compile the src file before generating the res file.

Example output:

```res
// src/Schema.res 

open RescriptSQL

module Artists = {
  type columns = {
    id: int,
    name: string,
    genre: NULL.t<string>,
  }

  type insert = {
    id?: int,
    name: string,
    genre: NULL.t<string>,
  }

  type update = {
    id?: int,
    name?: string,
    genre?: NULL.t<string>,
  }

  type t = Table.t<columns, insert, update>

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

  type t = Table.t<columns, insert, update>

  let table: t = {
    name: "songs",
    columns: Obj.magic({
      "id": Node.Column({name: "id"}),
      "artistId": Node.Column({name: "artistId"}),
      "name": Node.Column({name: "name"}),
    }),
  }
}
```

### 4. Create your queries:

Before using the dsl for dql and dml queries, you have to create an adapter for the underlying database technology.
To simplify the usage of different libraries, use the `Make` functor. The shape of an adapter looks like this:

```res
module type Adapter = {
  type connection
  type error

  let execute: (connection, string) => AsyncResult.t<unit, error>
  let getRows: (connection, string) => AsyncResult.t<array<'row>, error>
}
```

The following example uses `better-sqlite3`:

```res
module DB = RescriptSQL.Make({
  type connection = BetterSQLite3.connection
  type error = option<string>

  let execute = (connection, sql) => {
    try {
      BetterSQLite3.exec(connection, sql)->AsyncResult.ok
    } catch {
    | Exn.Error(e) => e->Exn.message->AsyncResult.error
    }
  }

  let getRows = (connection, sql) => {
    try {
      BetterSQLite3.prepare(connection, sql)->BetterSQLite3.all->AsyncResult.ok
    } catch {
    | Exn.Error(e) => e->Exn.message->AsyncResult.error
    }
  }
})
```

> There are no rescript bindings for different nodejs database libraries included. Write your own or find them on npm, github, etc.

Now you can use the `DB` module to write `select`, `insert`, `update` and `delete` queries.

```res
open DB.Select
open DB.Expr

from(Schema.Artists.table)
->leftJoin1(Schema.Songs.table, c => eq(c.t2.artistId, c.t1.id))
->select(c => {"artistName": c.t1.name, "songName": Option.map(c.t2, t2 => t2.name)})
->execute(connection)

// return type: AsyncResult<array<{"artistName": string, "songName": option<string>}>>
```

## Examples
There is a full working example in the `example` folder.
Use the npm scripts to generate the schema files, create a sqlite db and to run some predefined queries.
