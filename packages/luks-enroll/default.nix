# luks-enroll is a simple script to enroll all the drives in your config with tpm and/or fido
{ wrapbash, systemd, libfido2 , ... }:
wrapbash {
  name = "luks-enroll";
  runtimeInputs = [ systemd libfido2 ];
}