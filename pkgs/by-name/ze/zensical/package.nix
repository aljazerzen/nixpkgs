{
  lib,
  fetchFromGitHub,
  runCommand,
  rustPlatform,
  python3Packages,
  versionCheckHook,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "zensical";
  version = "0.0.5";
  pyproject = true;

  src =
    let
      zensical = fetchFromGitHub {
        owner = "aljazerzen";
        repo = "zensical";
        rev = "new-permissions";
        hash = "sha256-Fh7ZWpf49RHv9Wz+ZWLJO2FBEMzR/0LqhLN1blcma4s=";
      };
      ui = fetchFromGitHub {
        owner = "zensical";
        repo = "ui";
        rev = "3fe06b9ce12f4e7142d34d83cf3085d345318a43";
        hash = "sha256-CXj+C8GvBVrydUp8GjkX1857msclknHSXqyJ+BoBQvU=";
      };
    in
    runCommand "combined" { } ''
      mkdir -p $out
      cp -r ${zensical}/. $out/

      chmod u+w $out/python/zensical
      mkdir $out/python/zensical/templates
      cp -r ${ui}/dist/. $out/python/zensical/templates
    '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-ljNoAaqXAVbnF/9RbXdWvJAac8sh0W3v53YtgiNQEng=";
  };

  nativeBuildInputs = with rustPlatform; [
    maturinBuildHook
    cargoSetupHook
  ];

  dependencies = with python3Packages; [
    click
    deepmerge
    markdown
    pygments
    pymdown-extensions
    pyyaml
  ];

  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Static site generator for documentation";
    longDescription = ''
      Zensical is a modern static site generator designed to simplify
      building and maintaining project documentation.  It's built by
      the creators of Material for MkDocs and shares the same core
      design principles and philosophy – batteries included, easy to
      use, with powerful customization options.
    '';
    homepage = "https://zensical.org";
    changelog = "https://github.com/zensical/zensical/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aljazerzen ];
    mainProgram = "zensical";
  };
}
