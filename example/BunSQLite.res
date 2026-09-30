type connection
type statement

type mutationResult = {changes: int, lastInsertRowId: int}

@module("bun") @new external createConnection: string => connection = "SQL"

@send external close: connection => unit = "close"
@send external exec: (connection, string, array<unknown>) => promise<_> = "unsafe"

/* @send external getWithParams: (statement, 'a) => _ = "get" */
/* @send external all: statement => array<'row> = "all" */
/* @send external allWithParams: (statement, 'a) => array<_> = "all" */
/* @send external run: statement => mutationResult = "run" */
/* @send external runWithParams: (statement, 'a) => mutationResult = "run" */
