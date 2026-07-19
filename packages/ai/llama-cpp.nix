# llama-cpp
# a wrapper around llama-cpp for simpler deployment
{
  name ? "llm-openai",
  useROCM ? true,
  lib,
  callPackage,
  writeShellApplication,
  llama-cpp-rocm,
  llama-cpp,
  ...
}:
with builtins;
let
  config = import ./config.nix;
  pkg = if useROCM then llama-cpp-rocm else llama-cpp;
  model = callPackage ./_models/zeta.nix { };
in
writeShellApplication {
  # llm, open-ai compatible interface
  inherit name;
  runtimeInputs = [ pkg ];
  text = ''
    # set Hugging Face envvars
    export HF_HOME="$HOME/.cache/huggingface"
    export TRANSFORMERS_CACHE="$HF_HOME/transformers"
    export HF_DATASETS_CACHE="$HF_HOME/datasets"
    ${pkg}/bin/llama-server --list-devices
    # call llama-cpp
    ${pkg}/bin/llama-server  \
    --jinja \
    ${if config.useROCM then "--device ROCm0" else ""} \
    --port ${toString config.port} \
    --ctx-size  ${toString (config.cacheGB * 1024)} \
    -m ${model}
  '';
}
