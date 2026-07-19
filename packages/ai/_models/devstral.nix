# unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF
args@{
  callPackage,
  ...
}:
callPackage ./hf.nix {
  owner = "unsloth";
  name = "Devstral-Small-2-24B-Instruct-2512-GGUF";
  filename = "Devstral-Small-2-24B-Instruct-2512-UD-Q4_K_XL.gguf";
  hash = "";
}
