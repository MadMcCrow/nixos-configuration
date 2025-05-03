# luks-enroll is a simple script to enroll all the drives in your config with tpm and/or fido
# TODO :
#   maybe rewrite in python with poetry and as a python application
#   (also consider using C/C++ for this)
{
  wrapbash,
  systemd,
  libfido2,
  ...
}:
wrapbash {
  name = "luks-enroll";
  runtimeInputs = [
    systemd
    libfido2
  ];
}
