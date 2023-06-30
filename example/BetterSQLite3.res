type connection
type statement

type mutationResult = {changes: int, lastInsertRowId: int}

@new @module("better-sqlite3") external createConnection: string => connection = "default"

@send external close: connection => unit = "close"
@send external exec: (connection, string) => unit = "exec"
@send external prepare: (connection, string) => statement = "prepare"

/* @send external getWithParams: (statement, 'a) => _ = "get" */
@send external all: statement => array<'row> = "all"
/* @send external allWithParams: (statement, 'a) => array<_> = "all" */
/* @send external run: statement => mutationResult = "run" */
/* @send external runWithParams: (statement, 'a) => mutationResult = "run" */
