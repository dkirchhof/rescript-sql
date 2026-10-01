let literal = (value: 'a): 'a => {
  value->Obj.magic->EscapeValues.fromUnknown->Node.Literal->Obj.magic
}
