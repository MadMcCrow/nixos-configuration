# audio options :
{config, ... } :
{
  options.audio = {
    enable = mkDisableOption "audio support";
    # some intel drivers behave poorly so I left the ability to disable
    usePipewire = mkDisableOption "pipewire for audio";
  };
}
