open AST

let and_ = expressions => And(expressions)
let or_ = expressions => Or(expressions)
let eq = (left: 't, right: 't) => Equal(Node.normalize(left), Node.normalize(right))
let ne = (left: 't, right: 't) => NotEqual(Node.normalize(left), Node.normalize(right))
let gt = (left: 't, right: 't) => GreaterThan(Node.normalize(left), Node.normalize(right))
let gte = (left: 't, right: 't) => GreaterThanEqual(Node.normalize(left), Node.normalize(right))
let lt = (left: 't, right: 't) => LessThan(Node.normalize(left), Node.normalize(right))
let lte = (left: 't, right: 't) => LessThanEqual(Node.normalize(left), Node.normalize(right))

let between = (left: 't, min: 't, max: 't) => Between(
  Node.normalize(left),
  Node.normalize(min),
  Node.normalize(max),
)

let notBetween = (left: 't, min: 't, max: 't) => NotBetween(
  Node.normalize(left),
  Node.normalize(min),
  Node.normalize(max),
)

let inArray = (left: 't, array: array<'t>) => In(Node.normalize(left), Array.map(array, Node.normalize))

let notInArray = (left: 't, array: array<'t>) => NotIn(
  Node.normalize(left),
  Array.map(array, Node.normalize),
)

let like = (left: string, right: string) => Like(Node.normalize(left), Node.normalize(right))
let notLike = (left: string, right: string) => NotLike(Node.normalize(left), Node.normalize(right))

let ilike = (left: string, right: string) => ILike(Node.normalize(left), Node.normalize(right))
let notILike = (left: string, right: string) => NotILike(Node.normalize(left), Node.normalize(right))
