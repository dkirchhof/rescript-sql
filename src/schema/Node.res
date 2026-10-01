include AST

type t = node

let makeColumn = (column: Column.t) => {
  Column(column)->Obj.magic
}

let makeSubquery = (subquery: QueryBuilder_Select_Executable.t<_>) => {
  Subquery(subquery.ast)->Obj.magic
}

let normalize: 'a => t = %raw(`
  function normalize(value) {
    if (value !== null && typeof value === "object") {
      if (value.TAG) {
        return value;
      }

      return {
        TAG: "ProjectionGroup",
        _0: Object.fromEntries(
          Object.entries(value).map(([key, field]) => [key, normalize(field)])
        ),
      };
    }

    return {
      TAG: "Value",
      _0: value,
    };
  }
`)
