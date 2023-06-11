type t<'a> =
  | Column(Column.t)
  | Subquery(Select_Executable.t<'a>)
  | StringLiteral(string)
  | NumberLiteral(float)
  | BooleanLiteral(bool)

let makeColumn = (column: Column.t) => Column(column)->Obj.magic
let makeSubquery = (subquery: Select_Executable.t<_>) => Subquery(subquery)->Obj.magic

@unboxed
type any<'a> =
  | @as(true) True
  | @as(false) False
  | String(string)
  | Number(float)
  | Object(Js.Dict.t<'a>)

let makeFromAny = any => {
  switch any {
  | True => BooleanLiteral(true)
  | False => BooleanLiteral(false)
  | String(value) => StringLiteral(value)
  | Number(value) => NumberLiteral(value)
  | Object(value) => switch Js.Dict.get(value, "TAG") {
    | Some("Column") => Column(Obj.magic(value))
    | Some("Subquery") => Subquery(Obj.magic(value))
    | _ => panic("unknown node")
    }
  }
}

// let makeFromAny: (t<_>) = %raw(`
//   function(maybeNode) {
//     if (maybeNode)
//   }
// `)
