type node

type rec t =
  // | And(array<t>)
  // | Or(array<t>)
  | EQUAL(node, node)
// | NotEqual(Schema.Column.unknownColumn, Node.unknownNode)
// | GreaterThan(Schema.Column.unknownColumn, Node.unknownNode)
// | GreaterThanEqual(Schema.Column.unknownColumn, Node.unknownNode)
// | LessThan(Schema.Column.unknownColumn, Node.unknownNode)
// | LessThanEqual(Schema.Column.unknownColumn, Node.unknownNode)
// | Between(Schema.Column.unknownColumn, Node.unknownNode, Node.unknownNode)
// | NotBetween(Schema.Column.unknownColumn, Node.unknownNode, Node.unknownNode)
// | In(Schema.Column.unknownColumn, array<Node.unknownNode>)
// | NotIn(Schema.Column.unknownColumn, array<Node.unknownNode>)

let eq = (left: 't, right: 't) => EQUAL(Obj.magic(left), Obj.magic(right))
