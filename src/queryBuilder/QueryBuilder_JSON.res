let jsonExtract = (node: string, path: string): JSON.t => {
  Node.JsonExtract(Unknown.make(node), Unknown.make(path))->Obj.magic
}
