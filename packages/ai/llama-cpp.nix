# llama-cpp
# a wrapper around llama-cpp for simpler deployment
{
  lib,
  pkgs,
  name ? "llm-openai",
  useROCM ? true,
  # unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF also works
  model ? "adilkairolla/zeta-2.1-GGUF:Q5_K_M",
  cacheGB ? 16,
  port ? 1234,
  ...
} :
with builtins;
let
  pkg = if useROCM then pkgs.llama-cpp-rocm else pkgs.llama-cpp;
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
      ${if useROCM then "--device ROCm0" else ""} \
      --port ${toString port} \
      --ctx-size  ${toString (cacheGB * 1024)} \
      -hf ${model}
  '';
}
