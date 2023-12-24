{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, mesa
, libglvnd
, libxkbcommon
, pipewire
, wayland
}:

rustPlatform.buildRustPackage rec {
  pname = "xdg-desktop-portal-cosmic";
  version = "unstable-2023-12-07";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = pname;
    rev = "24f5bc67bf73e1051a5bcb25605a67c74ff7eb34";
    hash = "sha256-DQGDZP7jlXeeIWHpHjPI3aOYY2LHRjE35MW+Yt5LpUc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "smithay-client-toolkit-0.18.0" = "sha256-2WbDKlSGiyVmi7blNBr2Aih9FfF2dq/bny57hoA4BrE=";
      "cosmic-protocols-0.1.0" = "sha256-AEgvF7i/OWPdEMi8WUaAg99igBwE/AexhAXHxyeJMdc=";
      "ashpd-0.7.0" = "sha256-jBuxKJ2ADBvkJPPv4gzmFlZFybrfZBkCjerzeKe2Tt4=";
      "libspa-0.7.2" = "sha256-QWOcNWzEyxfTdjUIB33s9dpWJ7Fsfmb5jd70CXOP/bw=";
    };
  };

  separateDebugInfo = true;

  nativeBuildInputs = [ rustPlatform.bindgenHook pkg-config ];
  buildInputs = [ libglvnd libxkbcommon mesa pipewire wayland ];

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client, which is always dlopen()ed except by the
  # obscure winit backend.
  RUSTFLAGS = map (a: "-C link-arg=${a}") [
    "-Wl,--push-state,--no-as-needed"
    "-lEGL"
    "-lwayland-client"
    "-Wl,--pop-state"
  ];

  postInstall = ''
    mkdir -p $out/share/{dbus-1/services,xdg-desktop-portal/portals}
    cp data/*.service $out/share/dbus-1/services/
    cp data/cosmic.portal $out/share/xdg-desktop-portal/portals/
  '';

  meta = with lib; {
    homepage = "https://github.com/pop-os/xdg-desktop-portal-cosmic";
    description = "XDG Desktop Portal for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nyanbinary ];
    platforms = platforms.linux;
  };
}
