with builtins; {
  embedFile = { path, sha256 }: toString (fetchurl {
    url = "file://${toString path}";
    sha256 = sha256;
  });

  nixvim.lua = code: { __raw = code; };
}
