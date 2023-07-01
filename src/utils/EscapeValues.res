@unboxed
type t = String(string) | Number(float) | @as(true) True | @as(false) False

let escape = value =>
  switch value {
  | String(string) => `'${string}'`
  | Number(float) => Float.toString(float)
  | True => "TRUE"
  | False => "FALSE"
  }
