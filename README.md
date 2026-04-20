# Non-OS

NonOS is the base of my systems. it could be considered "alternative defaults" for nixOS.

## modules :

All configuration modules are independant and only imported if necessary.
this is done so that non-imported modules don't get parsed if not in use (no web server parsing if no web server on the machine for example).

### desktop
KDE desktop (for now). this is made for having a nice linux desktop

### vm
module to turn a system into a VM

### extra
features not yet enabled, experimental

### web
a cool web/cloud server. linux only (relies on systemd). has no external dependencies.
