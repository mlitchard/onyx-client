{

  inputs = {
    purs-nix.url = "github:ursi/purs-nix/ps-0.15";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    ps-tools.follows = "purs-nix/ps-tools";
  };
  outputs = { purs-nix, nixpkgs, utils, ... }@inputs: 
    utils.lib.eachDefaultSystem
      (system:
        let
	  main-project-flake = inputs.purs-nix;
          purs-nix = main-project-flake { inherit system; };
	  ps-tools = main-project-flake.inputs.ps-tools.legacyPackages.${system};
	  p = nixpkgs.legacyPackages.${system};

           ps =
             purs-nix.purs
               { dependencies =
                   [ "console"
                     "effect"
                     "prelude"
		     "halogen"
                   ];

                 dir = ./.;
               };
         in
         rec
         { apps.default =
             { type = "app";
               program = "${packages.default}/bin/hello";
             };
           packages =
             with ps;
             { default = app { name = "hello"; };
               bundle = bundle {};
               output = output {};
             };

           devShells.default =
             p.mkShell
               { 
	         buildInputs =
                   with p;
                   [ nodejs
                     (ps.command {bundle.esbuild.format = "iife";})
                     purs-nix.esbuild
                     purs-nix.purescript
                     ps-tools.for-0_15.purescript-language-server
                   ];
               };
         }
      );

}
