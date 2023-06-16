type t

let make: 'a => t = %raw(`
  function(any) {
    if (any.TAG) {
      return any;
    }

    if (typeof any === "string") {
      return {
        TAG: "StringLiteral",
        _0: any,
      }
    }

    if (typeof any === "number") {
      return {
        TAG: "NumberLiteral",
        _0: any,
      }
    }

    if (typeof any === "boolean") {
      return {
        TAG: "BooleanLiteral",
        _0: any,
      }
    }
  }
`)
