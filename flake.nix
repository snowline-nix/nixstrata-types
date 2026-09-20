{
  description = "nixstrata-types";

  inputs.nixlib-general.url = "git+https://github.com/zudww/nixlib-general?ref=v0.3.0-a1";

  inputs.nixllization.url = "git+https://github.com/snowline-nix/nixllization?ref=v0.1.0-a4";
  inputs.nixllization.inputs.nixlib-general.follows = "nixlib-general";

  #inputs.nixstrata-transforms.url = "git+https://github.com/snowline-nix/nixstrata-transforms?ref=v0.1.0-a5";
  inputs.nixstrata-transforms.url = "github:snowline-nix/nixstrata-transforms/2098a1b7a975c4b5677221633c880dd23d222ba0";
  inputs.nixstrata-transforms.inputs.nixlib-general.follows = "nixlib-general";
  inputs.nixstrata-transforms.inputs.nixllization.follows = "nixllization";

  outputs = _: import ./src _;
}
