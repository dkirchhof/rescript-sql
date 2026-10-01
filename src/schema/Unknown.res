type t

let make: 'a => t = %raw(`
  function(any) {
    if (any !== null && typeof any === "object") {
      if (any.TAG) {
        return any;
      }

      return {
        TAG: "ProjectionGroup",
        _0: Object.fromEntries(
          Object.entries(any).map(([key, value]) => [key, make(value)])
        ),
      };
    }

    return {
      TAG: "Value",
      _0: any,
    };
  }
`)
