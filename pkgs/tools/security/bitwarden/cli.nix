{ lib
, stdenv
, buildNpmPackage
, nodejs_18
, fetchFromGitHub
, python3
, darwin
, nixosTests
}:

let
  buildNpmPackage' = buildNpmPackage.override { nodejs = nodejs_18; };
in buildNpmPackage' rec {
  pname = "bitwarden-cli";
  version = "2023.10.0";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "cli-v${version}";
    hash = "sha256-egXToXWfb9XV7JuCRBYJO4p/e+WOwMncPKz0oBgeALQ=";
  };

  npmDepsHash = "sha256-iO8ZozVl1vOOqowQARnRJWSFUFnau46+dKfcMSkyU3o=";

  nativeBuildInputs = [
    python3
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.cctools
  ];

  makeCacheWritable = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmBuildScript = "build:prod";

  npmWorkspace = "apps/cli";

  passthru.tests = {
    vaultwarden = nixosTests.vaultwarden.sqlite;
  };

  meta = with lib; {
    changelog = "https://github.com/bitwarden/clients/releases/tag/${src.rev}";
    description = "A secure and free password manager for all of your devices";
    homepage = "https://bitwarden.com";
    license = lib.licenses.gpl3Only;
    mainProgram = "bw";
    maintainers = with maintainers; [ dotlambda ];
  };
}
