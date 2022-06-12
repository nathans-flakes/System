{ pname
, version
, src
, binaryName
, desktopName
, autoPatchelfHook
, makeDesktopItem
, lib
, stdenv
, wrapGAppsHook
, alsaLib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libcxx
, libdrm
, libnotify
, libpulseaudio
, libuuid
, libX11
, libXScrnSaver
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libxcb
, libxshmfence
, mesa
, nspr
, nss
, pango
, systemd
, libappindicator-gtk3
, libdbusmenu
, writeScript
, common-updater-scripts
, electron
, nodePackages
, libgcc
, glibc
}:

let
  inherit binaryName;
in
stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    alsaLib
    autoPatchelfHook
    stdenv.cc.cc
    cups
    libdrm
    libuuid
    libXdamage
    libX11
    libXScrnSaver
    libXtst
    libxcb
    libxshmfence
    mesa
    nss
    wrapGAppsHook
    nodePackages.asar
    autoPatchelfHook
  ];

  buildInputs = [
    electron
    libgcc
    glibc
  ];

  dontWrapGApps = true;

  libPath = lib.makeLibraryPath [
    libcxx
    systemd
    libpulseaudio
    libdrm
    mesa
    stdenv.cc.cc
    alsaLib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libnotify
    libX11
    libXcomposite
    libuuid
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    nspr
    nss
    libxcb
    pango
    systemd
    libXScrnSaver
    libappindicator-gtk3
    libdbusmenu
    libgcc
  ];

  installPhase =
    let
      electron_exec = "${electron}/bin/electron";
    in
    ''
      mkdir -p $out/{bin,opt/${binaryName},share/pixmaps}
      mv * $out/opt/${binaryName}
      chmod +x $out/opt/${binaryName}/${binaryName}
      ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${pname}.png
      mkdir -p $out/share/applications
      ls $out/share/applications
      sed "s|OUTDIR|$out|" ${desktopItem}/share/applications/${pname}.desktop > $out/share/applications/${pname}.desktop 
      # Hacks for system electron
      asar e $out/opt/${binaryName}/resources/app.asar $out/opt/${binaryName}/resources/app
      rm $out/opt/${binaryName}/resources/app.asar
      sed -i "s|process.resourcesPath|'$out/opt/${binaryName}/resources'|" $out/opt/${binaryName}/resources/app/app_bootstrap/buildInfo.js
      sed -i "s|exeDir,|'$out/share/pixmaps',|" $out/opt/${binaryName}/resources/app/app_bootstrap/autoStart/linux.js
      asar p $out/opt/${binaryName}/resources/app $out/opt/${binaryName}/resources/app.asar --unpack-dir '**'

      # executable wrapper
      makeWrapper '${electron_exec}' "$out/bin/${binaryName}" \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland $out/opt/${binaryName}/resources/app.asar"\
        --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/"\
        --prefix LD_LIBRARY_PATH : ${libPath}
      ln -s $out/bin/${binaryName} $out/bin/${lib.strings.toLower binaryName}
    '';

  desktopItem =
    makeDesktopItem {
      name = pname;
      exec = "${binaryName}";
      icon = pname;
      inherit desktopName;
      genericName = meta.description;
      categories = [ "Network" "InstantMessaging" ];
      mimeTypes = [ "x-scheme-handler/discord" ];
    };

  passthru.updateScript = writeScript "discord-update-script" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl gnugrep common-updater-scripts
    set -eou pipefail;
    url=$(curl -sI "https://discordapp.com/api/download/${builtins.replaceStrings ["discord-" "discord"] ["" "stable"] pname}?platform=linux&format=tar.gz" | grep -oP 'location: \K\S+')
    version=''${url##https://dl*.discordapp.net/apps/linux/}
    version=''${version%%/*.tar.gz}
    update-source-version ${pname} "$version" --file=./pkgs/applications/networking/instant-messengers/discord/default.nix
  '';

  meta = with lib; {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    downloadPage = "https://discordapp.com/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ ldesgoui MP2E ];
    platforms = [ "x86_64-linux" ];
  };
}
