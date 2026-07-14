# llama-cpp
# a wrapper around llama-cpp for simpler deployment
{
  lib,
  pkgs,
  name ? "llm-ollama",
  ...
}:
let
  model = import ./model.nix;
  pkg = if model.useROCM then pkgs.ollama-rocm else pkgs.ollama;
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [ pkg ];
  text = ''
    export HF_HOME="$HOME/.cache/huggingface"
    export TRANSFORMERS_CACHE="$HF_HOME/transformers"
    export HF_DATASETS_CACHE="$HF_HOME/datasets"
    export OLLAMA_HOST="0.0.0.0:${toString model.port}"
    export OLLAMA_NOHISTORY=1
    # export OLLAMA_CONTEXT_LENGTH=${toString (model.cacheGB * 1024)}
    ${pkgs.lib.getExe pkg} start
    ${pkgs.lib.getExe pkg} run hf.co/${model.model}
  '';
}
