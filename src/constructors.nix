{ errors, mkTypeTransforms, ... }:
{ transformers, ... }:
{
  applyMixins,
  runProcess,
  ...
}:
{
  mkType = {
    name,
    fullDefinitionName ? name,
    description ? null,

    transforms ? {},
    forceCheck ? null,
    # `forceCheck` is for forcibly checking if a value conforms to the type.
    # Normally, checks would be in `transform` to be lazy, but Union types
    # needs an absolute check to identify if a value conforms to a type.
  }@inputs:
  let
    type = {
      _type = "type";
      inherit name description fullDefinitionName;

      forceCheck =
        if inputs ? forceCheck then forceCheck
        else errors.typeErr.noForceCheck { inherit type; };

      eval = runProcess (mkTypeTransforms transforms);
    };
  in
    type;

  mkTypeTransforms = {
    overrides ? {},
    default ? [
      transformers.defaultValueObj
      (if overrides ? priority then overrides.priority else transformers.prioritizeLowerStep)
      (if overrides ? typeCheck then overrides.typeCheck else transformers.defaultTypeCheck)
      (if overrides ? mergeMethod then overrides.mergeMethod else transformers.noMerge)
    ],
    mixins ? []
  }:
    applyMixins mixins default;
}

