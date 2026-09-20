{
  nixlib-general,
  nixllization,
  nixstrata-transforms,

  ...
}@inputs:
let
  nt = nixstrata-transforms.lib;
  ng = nixlib-general.lib;
  nl = nixllization.lib;

  lib = {
    constructors = import ./constructors.nix lib nt nl;
    errors = import ./errors.nix;

    types =
      import ./types/scalar.nix lib nt ng //
      import ./types/compound.nix lib nt ng;

    inherit (lib.constructors)
      mkType
      mkTypeTransforms
      ;
  };
in
{ inherit lib inputs; }
