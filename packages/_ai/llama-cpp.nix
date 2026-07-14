# llama-cpp
# a wrapper around llama-cpp for simpler deployment
{
  lib,
  pkgs,
  name ? "llm-openai",
  ...
} :
with builtins;
let
  model = import ./model.nix;
  pkg = if model.useROCM then pkgs.llama-cpp-rocm else pkgs.llama-cpp;
in
pkgs.writeShellApplication {
  # llm, open-ai compatible interface
  inherit name;
  runtimeInputs = [pkg];
  text = ''
      # set Hugging Face envvars
      export HF_HOME="$HOME/.cache/huggingface"
      export TRANSFORMERS_CACHE="$HF_HOME/transformers"
      export HF_DATASETS_CACHE="$HF_HOME/datasets"
      ${pkg}/bin/llama-server --list-devices
      # call llama-cpp
      ${pkg}/bin/llama-server  \
      --jinja \
      ${if model.useROCM then "--device ROCm0" else ""} \
      --port ${toString model.port} \
      --ctx-size  ${toString (model.cacheGB * 1024)} \
      -hf ${model}
  '';
}
