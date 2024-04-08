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
        telegramOverride = (old: {
            pname = "telegram-desktop-userfonts";

            preConfigure = ''
                for ttf in Telegram/lib_ui/fonts/*.ttf; do
                    rm $ttf
                    touch $ttf
                done
                sed -i 's/DemiBold/Bold/g' Telegram/lib_ui/ui/style/style_core_font.cpp
            '';

            cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_BUILD_TYPE=Release" ];

            meta = with lib; {
                description = "Telegram Desktop which respects fontconfig";
                longDescription = ''
                  Desktop client for the Telegram messenger, based on the Telegram API and
                  the MTProto secure protocol.
                '';
                license = licenses.gpl3Only;
                platforms = platforms.all;
                homepage = "https://desktop.telegram.org/";
                changelog = "https://github.com/telegramdesktop/tdesktop/releases/tag/v${old.version}";
                mainProgram =  old.mainProgram;
            };
        });
    in
    {
        overlays = {
            default = (final: prev: {
                telegram-desktop = prev.telegram-desktop.overrideAttrs (telegramOverride);
            });
        };
        packages = eachSystem (system: {
            default = pkgsFor."${system}".telegram-desktop.overrideAttrs (telegramOverride);
        });
    };
}
