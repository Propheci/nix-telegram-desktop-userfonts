{
    description = "Telegram Desktop Userfonts";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    outputs = { self, nixpkgs }:
    let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
        packages = {
            telegram-desktop-userfonts = pkgs.telegram-desktop.overrideAttrs (old: {
                preConfigure = ''
                    for ttf in Telegram/lib_ui/fonts/*.ttf; do
                        rm $ttf
                        touch $ttf
                    done
                    sed -i 's/DemiBold/Bold/g' Telegram/lib_ui/ui/style/style_core_font.cpp
                '';

                cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_BUILD_TYPE=Release" ];
            });
        };
    };
}
