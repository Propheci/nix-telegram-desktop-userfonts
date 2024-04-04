{
    description = "Telegram Desktop Userfonts";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        systems.url = "github:nix-systems/default-linux";
    };

    outputs = { self, nixpkgs, systems }:
    let
        inherit (nixpkgs) lib;
        eachSystem = lib.genAttrs (import systems);
        pkgsFor = eachSystem (system:
            import nixpkgs {
                localSystem = system;
            }
        );
    in
    {
        packages = eachSystem (system: {
            telegram-desktop-userfonts = pkgsFor."${system}".telegram-desktop.overrideAttrs (old: {
                preConfigure = ''
                    for ttf in Telegram/lib_ui/fonts/*.ttf; do
                        rm $ttf
                        touch $ttf
                    done
                    sed -i 's/DemiBold/Bold/g' Telegram/lib_ui/ui/style/style_core_font.cpp
                '';

                cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_BUILD_TYPE=Release" ];
            });
        });
    };
}
