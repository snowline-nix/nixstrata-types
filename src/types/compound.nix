{
  types,

  mkType,
  ...
}:
{
  initializers,
  transformers,

  mkTypeTransformStep,
  mkTypeRemapStep,
  ...
}:
{
  allElems,
  isAttrset,
  isList,
  remapElems,
  joinStringsSep,
  ...
}:
let
  inherit (builtins)
    attrNames
    listToAttrs
    ;
in
{
  attrsOf = types.attrsetOf;

  attrsetOf = type: mkType {
    name = "attrset";
    description = "named collection of `${type.name}` value";
    fullDefinitionName = "attrset of ${type.name}s";

    forceCheck = x: isAttrset x && allElems (attrNames x) (v: type.forceCheck x.${v});

    transforms.overrides.typeCheck = transformers.customTypeCheck isAttrset;
    transforms.overrides.mergeMethod = transformers.attrsAsDecls;

    transforms.mixins = let
      transform = mkTypeTransformStep {
        identifier = "compoundValueEvals.lazyAttrs";
        operation = { declarations, context, ... }: listToAttrs (
          remapElems (attrNames declarations)
          (n: {
            name = n;
            value = type.eval (initializers.mkTypeTransformInit
              (context // {
                inherit type;
                values = declarations.${n};
                path = context.path ++ [ { type = "attribute"; address = n; } ];
              })
            );
          })
        );
      };
    in [
      (t: t ++ [ transform ])
    ];
  };

  listOf = type: mkType {
    name = "list";
    description = "ordered collection of `${type.name}` values";
    fullDefinitionName = "list of ${type.name}s";

    forceCheck = x: isList x && allElems (x2: type.forceCheck x2) x;

    transforms.overrides.typeCheck = transformers.customTypeCheck isList;
    transforms.overrides.mergeMethod = transformers.joinLists;

    transforms.mixins = let
      transform = mkTypeRemapStep {
        identifier = "compoundValueEvals.lazyElems";
        operation = { context, decl, ... }:
          type.eval (initializers.mkTypeTransformInit
            (context // {
              inherit type;
              values = [ decl ];
              path = context.path ++ [ { type = "element"; address = 0; } ];
            })
          );
      };
    in [
      (t: t ++ [ transform ])
    ];
  };

  # example usage:
  # ```nix
  # structOf {
  #   a = str;
  #   b = listOf str;
  # }
  # ```
  structOf = structDef:
    let structAttrNames = attrNames structDef; in
    mkType {
      name = "struct";
      description = "attrset with predefined attribute names and value types";
      fullDefinitionName =
        "struct of "
        + joinStringsSep ", " (
          remapElems
          structAttrNames
          (attr: "\"${attr}\" (${structDef.${attr}.fullDefinitionName})")
        );

      forceCheck = x:
        let xAttrNames = attrNames x; in
        !(isAttrset x)
        && xAttrNames == structAttrNames
        && allElems (name: structDef.${name}.forceCheck x.${name}) structAttrNames;

      transforms.overrides.typeCheck = transformers.lazyStructTypeCheck structAttrNames;
      transforms.overrides.mergeMethod = transformers.attrsAsDecls;

      transforms.mixins = let
        transform = mkTypeTransformStep {
          identifier = "compoundValueEvals.lazyStruct";
          operation = { declarations, context, ... }: listToAttrs (
            remapElems (attrNames declarations)
            (n: {
              name = n;
              value =
                let type = structDef.${n}; in
                type.eval (initializers.mkTypeTransformInit
                  (context // {
                    inherit type;
                    values = declarations.${n};
                    path = context.path ++ [ { type = "attribute"; address = n; } ];
                  })
                );
            })
          );
        };
      in [
        (t: t ++ [ transform ])
      ];
    };
}
