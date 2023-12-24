{
  lib,
  fetchFromGitHub,
  bash,
  rustPlatform,
  just,
  dbus,
  rust,
  stdenv,
  xdg-desktop-portal-cosmic,
}:
rustPlatform.buildRustPackage rec {
  pname = "cosmic-session";
  version = "unstable-2023-11-13";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "e2d2732f819279b6f8e3f44234d59c7dc5c16721";
    sha256 = "sha256-K+h1BASQ3NJtL71tnW5DCdUALxo19k2glGLyZaCMwj0=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cosmic-notifications-util-0.1.0" = "sha256-GmTT7SFBqReBMe4GcNSym1YhsKtFQ/0hrDcwUqXkaBw=";
      "launch-pad-0.1.0" = "sha256-tnbSJ/GP9GTnLnikJmvb9XrJSgnUnWjadABHF43L1zc=";
    };
  };

  postPatch = ''
    substituteInPlace Justfile --replace '#!/usr/bin/env' "#!$(command -v env)"
    substituteInPlace Justfile --replace 'target/release/cosmic-session' "target/${
      rust.lib.toRustTargetSpecShort stdenv.hostPlatform
    }/release/cosmic-session"
    substituteInPlace data/start-cosmic --replace '#!/bin/bash' "#!${bash}/bin/bash"
    substituteInPlace data/start-cosmic --replace '/usr/bin/cosmic-session' "${
      placeholder "out"
    }/bin/cosmic-session"
    substituteInPlace data/start-cosmic --replace '/usr/bin/dbus-run-session' "${dbus}/bin/dbus-run-ssession"
    substituteInPlace src/main.rs --replace '/usr/libexec/xdg-desktop-portal-cosmic' "${xdg-desktop-portal-cosmic}/bin/xdg-desktop-portal-cosmic"
  '';

  postInstall = ''
    substituteInPlace $out/share/wayland-sessions/cosmic.desktop --replace '/usr/bin/start-cosmic' "$out/bin/start-cosmic"
  '';

  nativeBuildInputs = [ just ];
  buildInputs = [ ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
  ];

  passthru = {
    providedSessions = [ "cosmic" ];
  };

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-session";
    description = "Session manager for the COSMIC desktop environment";
    license = licenses.gpl3Only;
    mainProgram = "cosmic-session";
    maintainers = with maintainers; [
      a-kenji
      nyanbinary
    ];
    platforms = platforms.linux;
  };
}
