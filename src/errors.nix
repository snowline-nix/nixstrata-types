{
  typeErr.noForceCheck = { type, ... }:
    let summary = "this type (`${type.name}`) has no force check"; in
    throw ''
      ${summary}

      This type doesn't provide a force check.

      Type: ${type.name}

      error: ${summary}
    '';
}
