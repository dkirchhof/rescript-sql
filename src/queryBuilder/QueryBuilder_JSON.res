let jsonExtract = (node: string, path: string): JSON.t => {
  Node.JsonExtract(Node.normalize(node), Node.normalize(path))->Obj.magic
}
