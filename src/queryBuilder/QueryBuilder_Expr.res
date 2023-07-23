type rec t =
  | And(array<t>)
  | Or(array<t>)
  | Equal(Unknown.t, Unknown.t)
  | NotEqual(Unknown.t, Unknown.t)
  | GreaterThan(Unknown.t, Unknown.t)
  | GreaterThanEqual(Unknown.t, Unknown.t)
  | LessThan(Unknown.t, Unknown.t)
  | LessThanEqual(Unknown.t, Unknown.t)
  | Between(Unknown.t, Unknown.t, Unknown.t)
  | NotBetween(Unknown.t, Unknown.t, Unknown.t)
  | In(Unknown.t, array<Unknown.t>)
  | NotIn(Unknown.t, array<Unknown.t>)
  | Like(Unknown.t, string)
  | NotLike(Unknown.t, string)
  | ILike(Unknown.t, string)
  | NotILike(Unknown.t, string)

let and_ = expressions => And(expressions)
let or_ = expressions => Or(expressions)
let eq = (left: 't, right: 't) => Equal(Unknown.make(left), Unknown.make(right))
let ne = (left: 't, right: 't) => NotEqual(Unknown.make(left), Unknown.make(right))
let gt = (left: 't, right: 't) => GreaterThan(Unknown.make(left), Unknown.make(right))
let gte = (left: 't, right: 't) => GreaterThanEqual(Unknown.make(left), Unknown.make(right))
let lt = (left: 't, right: 't) => LessThan(Unknown.make(left), Unknown.make(right))
let lte = (left: 't, right: 't) => LessThanEqual(Unknown.make(left), Unknown.make(right))

let between = (left: 't, min: 't, max: 't) => Between(
  Unknown.make(left),
  Unknown.make(min),
  Unknown.make(max),
)

let notBetween = (left: 't, min: 't, max: 't) => NotBetween(
  Unknown.make(left),
  Unknown.make(min),
  Unknown.make(max),
)

let inArray = (left: 't, array: array<'t>) => In(Unknown.make(left), Array.map(array, Unknown.make))

let notInArray = (left: 't, array: array<'t>) => NotIn(
  Unknown.make(left),
  Array.map(array, Unknown.make),
)

let like = (left: 't, right: string) => Like(Unknown.make(left), right)
let notLike = (left: 't, right: string) => NotLike(Unknown.make(left), right)

let ilike = (left: 't, right: string) => ILike(Unknown.make(left), right)
let notILike = (left: 't, right: string) => NotILike(Unknown.make(left), right)
