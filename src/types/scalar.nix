{ mkType, types, ... }:
{ transformers, ... }:
{
  isAttrset,
  isBool,
  isFloat,
  isInt,
  isLambda,
  isList,
  isPath,
  isString,
  ...
}:
{
  any = mkType {
    name = "any";
    description = "any type";
    forceCheck = _: true;
  };

  attrs = types.attrset;

  attrset = mkType {
    name = "attrset";
    description = "named collection of untyped values";
    forceCheck = isAttrset;
  };

  bool = mkType {
    name = "bool";
    description = "`true` or `false`";
    forceCheck = isBool;
  };

  float = mkType {
    name = "float";
    description = "double-precision floating point (64-bit)";
    forceCheck = isFloat;
  };

  function = mkType {
    name = "function";
    description = "transforms input value to an output value";
    forceCheck = isLambda;
  };

  int = mkType {
    name = "int";
    description = "signed 64-bit integer (-2^63 to 2^63-1)";
    forceCheck = isInt;
  };

  lambda = types.function;

  list = mkType {
    name = "list";
    description = "ordered collection of untyped values";

    forceCheck = isList;
    transforms.overrides.mergeMethod = transformers.joinLists;
  };

  literalOf = v: mkType {
    name = "literal";
    description = "constant value";
    fullDefinitionName = "literal of ${toString v}";
    forceCheck = x: x == v;
  };

  null = mkType {
    name = "null";

    forceCheck = isNull;
    transforms.overrides.mergeMethod = transformers.staticNull;
  };

  path = mkType {
    name = "path";
    description = "filesystem path. can be relative with \".\"";
    forceCheck = isPath;
  };

  str = types.string;

  string = mkType {
    name = "string";
    description = "sequence of characters";
    forceCheck = isString;
  };
}
