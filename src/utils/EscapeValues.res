@unboxed
type t =
  | String(string)
  | Number(float)
  | @as(true) True
  | @as(false) False
  | @as(null) Null

let fromUnknown: unknown => t = %raw(`
  function(value) {
    if (value === null || typeof value === "string" || typeof value === "boolean"
        || (typeof value === "number" && Number.isFinite(value))) {
      return value;
    }

    throw new TypeError("literal() expects a string, finite number, boolean, or null");
  }
`)

let escape = value =>
  switch value {
  | String(string) => `'${String.replaceAll(string, "'", "''")}'`
  | Number(float) => Float.toString(float)
  | True => "TRUE"
  | False => "FALSE"
  | Null => "NULL"
  }
