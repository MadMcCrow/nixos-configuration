# default options for ai model
# TODO : use a fetcher and package those models in nix
{
  useROCM = true;
  # unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF also works
  model = "adilkairolla/zeta-2.1-GGUF:Q5_K_M";
  cacheGB = 16;
  port = 1234;
}
